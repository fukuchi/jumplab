import controlP5.*;
import java.util.Map;
import java.lang.reflect.Field;

class Console {
  int x, y, w, h;
  ControlP5 ctlr;
  HashMap<String, Controller> widgets;
  HashMap<Integer, String> id2parameter;
  HashMap<String, int[]> indicators;
  Settings settings;
  boolean halfFilled = false;
  Controller lastWidget;
  int nextWidgetPosition_y;
  static final int widgetMargin_y = 6;
  NumIndicator numIndicator;

  Console(PApplet parent, int x, int y, int w, int h, Settings settings) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.settings = settings;

    ctlr = new ControlP5(parent);
    widgets = new HashMap<String, Controller>();
    id2parameter = new HashMap<Integer, String>();
    indicators = new HashMap<String, int[]>();

    ctlr.addTextlabel("JumperXY")
      .setPosition(x + 10, y + 10)
      .setText("Jumper X,Y");
    indicators.put("JumperXYvalue", new int[] {x + 80, y + 10});
    ctlr.addTextlabel("JumperVXY")
      .setPosition(x + 10, y + 30)
      .setText("Jumper VX,VY");
    indicators.put("JumperVXYvalue", new int[] {x + 80, y + 30});
    ctlr.addTextlabel("VerticalAcc")
      .setPosition(x + 10, y + 50)
      .setText("Vertical Acc");
    indicators.put("VerticalAccValue", new int[] {x + 80, y + 50});
    ctlr.addTextlabel("PropellingRemainingFrames")
      .setPosition(x + 10, y + 70)
      .setText("Propelling Remainig");
    indicators.put("PropellingRemainingFramesValue", new int[] {x + 98, y + 70});
    ctlr.addTextlabel("Jumping")
      .setPosition(x + 200, y + 10)
      .setText("Jumping: ");
    widgets.put("JumpingValue", ctlr.addTextlabel("JumpingValue")
      .setPosition(x + 260, y + 10)
      .setText("FALSE"));
    ctlr.addTextlabel("Propelling")
      .setPosition(x + 200, y + 30)
      .setText("Propelling: ");
    widgets.put("PropellingValue", ctlr.addTextlabel("PropellingValue")
      .setPosition(x + 260, y + 30)
      .setText("FALSE"));
    ctlr.addTextlabel("OnObstacle")
      .setPosition(x + 200, y + 50)
      .setText("On obstacle: ");
    widgets.put("OnObstacleValue", ctlr.addTextlabel("OnObstracleValue")
      .setPosition(x + 260, y + 50)
      .setText("FALSE"));

    ctlr.addButton("reset")
      .setValue(1)
      .setPosition(x + 80, y + 90)
      .setSize(150, 20)
      .addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        resetButton(event);
      }
    }
    );

    nextWidgetPosition_y = y + 120;
    appendHalfwidthWidget("showTrail", ctlr.addToggle("Show trail")
      .setValue(settings.showTrail));
    appendHalfwidthWidget("showCenterMarker", ctlr.addToggle("Center marker")
      .setValue(settings.showCenterMarker));
    appendHalfwidthWidget("parallaxScrolling", ctlr.addToggle("Parallax scrolling")
      .setValue(settings.parallaxScrolling));
    appendHalfwidthWidget("camVerticalEasing", ctlr.addToggle("Camera easing")
      .setValue(settings.camVerticalEasing));
    appendHalfwidthWidget("allowAerialJump", ctlr.addToggle("Allow aerial jump")
      .setValue(settings.allowAerialJump));
    appendHalfwidthWidget("allowAerialWalk", ctlr.addToggle("Allow aerial walk")
      .setValue(settings.allowAerialWalk));
    appendHalfwidthWidget("constantRising", ctlr.addToggle("Constant rising")
      .setValue(settings.constantRising));
    appendHalfwidthWidget();
    appendHalfwidthWidget("maxVx", ctlr.addSlider("Max Vx")
      .setSize(80, 20)
      .setRange(1, 20));
    appendHalfwidthWidget("maxVy", ctlr.addSlider("Max Vy")
      .setSize(80, 20)
      .setRange(1, 80));
    appendFullwidthWidget("jumpPower", ctlr.addSlider("Jump Velocity")
      .setSize(150, 20)
      .setRange(1, 30));
    appendFullwidthWidget("jumpAnticipationFrames", ctlr.addSlider("Jump Anticipation Frames")
      .setSize(150, 20)
      .setRange(0, 9)
      .setNumberOfTickMarks(10)
      .showTickMarks(false));
    appendFullwidthWidget("brakingAtTakeoff", ctlr.addSlider("Braking at takeoff")
      .setSize(150, 20)
      .setRange(0, 1.0));
    appendFullwidthWidget("maxPropellingFrames", ctlr.addSlider("Maximum Propelling Duration")
      .setSize(150, 20)
      .setRange(1, 100)
      .setNumberOfTickMarks(100)
      .showTickMarks(false));
    appendFullwidthWidget("gravity", ctlr.addSlider("Gravity (rising)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("gravityFalling", ctlr.addSlider("Gravity (falling)")
      .setSize(150, 20)
      .setRange(0.01, 3));
    appendFullwidthWidget("verticalSpeedSustainLevel", ctlr.addSlider("Jump speed sustain level")
      .setSize(150, 20)
      .setRange(0, 1));
    appendFullwidthWidget("axNormal", ctlr.addSlider("X Accel (normal)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("axBrake", ctlr.addSlider("X Accel (braking)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("axJumping", ctlr.addSlider("X Accel (jumping)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("camEasingNormal", ctlr.addSlider("Camera Easing Coef (normal)")
      .setSize(150, 20)
      .setRange(0, 1));
    appendFullwidthWidget("camEasingGrounding", ctlr.addSlider("Camera Easing Coef (grounding)")
      .setSize(150, 20)
      .setRange(0, 1));

    for (String name : settings.booleanValues) {
      Controller widget = widgets.get(name);
      widget.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER);
      widget.setValueLabel(name);
    }
    int id = 100;
    for (String name : widgets.keySet()) {
      Controller widget = widgets.get(name);
      widget.setId(id);
      id2parameter.put(id, name);
      id++;
    }

    setValues();

    ctlr.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        parameterChange(event);
      }
    }
    );

    numIndicator = new NumIndicator();
  }

  void appendFullwidthWidget(String name, Controller widget) {
    if (halfFilled) {
      halfFilled = false;
      if (lastWidget != null) {
        nextWidgetPosition_y += lastWidget.getHeight() + widgetMargin_y;
      }
    }
    widget.setPosition(x + 10, nextWidgetPosition_y);
    widgets.put(name, widget);
    nextWidgetPosition_y += widget.getHeight() + widgetMargin_y;
    lastWidget = widget;
  }

  void appendHalfwidthWidget(String name, Controller widget) {
    if (!halfFilled) {
      widget.setPosition(x + 10, nextWidgetPosition_y);
      halfFilled = true;
    } else {
      widget.setPosition(x + 150, nextWidgetPosition_y);
      halfFilled = false;
      nextWidgetPosition_y += max(widget.getHeight(), lastWidget.getHeight()) + widgetMargin_y;
    }
    widgets.put(name, widget);
    lastWidget = widget;
  }

  void appendHalfwidthWidget() {
    if (halfFilled) {
      nextWidgetPosition_y += lastWidget.getHeight() + widgetMargin_y;
      halfFilled = false;
    }
  }

  void statusUpdate(Jumper jumper) {
    ((Textlabel)widgets.get("JumpingValue")).setText(jumper.jumping?"TRUE":"FALSE");
    ((Textlabel)widgets.get("PropellingValue")).setText(jumper.propelling?"TRUE":"FALSE");
    ((Textlabel)widgets.get("OnObstacleValue")).setText(jumper.onObstacle?"TRUE":"FALSE");
  }

  void drawStatus(Jumper jumper) {
    drawNumIndicator("JumperXYvalue", String.format("%7.2f,%7.2f", jumper.x, jumper.y));
    drawNumIndicator("JumperVXYvalue", String.format("% 7.2f,% 7.2f", jumper.vx, jumper.vy));
    drawNumIndicator("VerticalAccValue", String.format("% 7.2f", jumper.verticalAcc));
    drawNumIndicator("PropellingRemainingFramesValue", String.format("%4d", jumper.propellingRemainingFrames));
  }

  void drawNumIndicator(String name, String str) {
    int[] pos = indicators.get(name);
    numIndicator.text(str, pos[0], pos[1]);
  }

  void setValues() {
    for (String name : settings.booleanValues) {
      Toggle toggle = (Toggle)widgets.get(name);
      if (toggle != null) {
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          toggle.setValue((Boolean)(f.get(settings))?1:0);
        } 
        catch (ReflectiveOperationException e) {
          println("Failed to set " + name + ".");
        }
      }
    }
    for (String name : settings.floatValues) {
      Slider slider = (Slider)widgets.get(name);
      if (slider != null) {
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          slider.setValue((float)f.get(settings));
        } 
        catch (ReflectiveOperationException e) {
          println("Failed to set " + name + ".");
        }
      }
    }
  }

  void parameterChange(CallbackEvent event) {
    Controller widget = event.getController();
    if (widget instanceof Toggle) {
      if (event.getAction() == ControlP5.ACTION_PRESS) {
        String name = id2parameter.get(event.getController().getId());
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          f.set(settings, widget.getValue() > 0);
        } 
        catch (ReflectiveOperationException e) {
          println("Failed to set " + name + ".");
        }
      }
    } else if (event.getController() instanceof Slider) {
      int action = event.getAction();
      if (action == ControlP5.ACTION_MOVE || action == ControlP5.ACTION_RELEASE || action == ControlP5.ACTION_RELEASE_OUTSIDE) {
        String name = id2parameter.get(event.getController().getId());
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          f.set(settings, widget.getValue());
        } 
        catch (ReflectiveOperationException e) {
          println("Failed to set " + name + ".");
        }
      }
    }
  }

  void resetButton(CallbackEvent event) {
    if (event.getAction() == ControlP5.ACTION_CLICK) {
      settings.resetSettings();
      setValues();
    }
  }
}
