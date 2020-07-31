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
      .setPosition(x + 10, y + 25)
      .setText("Jumper VX,VY");
    indicators.put("JumperVXYvalue", new int[] {x + 80, y + 25});
    ctlr.addTextlabel("VerticalAcc")
      .setPosition(x + 10, y + 40)
      .setText("Vertical Acc");
    indicators.put("VerticalAccValue", new int[] {x + 80, y + 40});
    ctlr.addTextlabel("PropellingRemainingFrames")
      .setPosition(x + 10, y + 55)
      .setText("Propelling Remainig");
    indicators.put("PropellingRemainingFramesValue", new int[] {x + 98, y + 55});
    ctlr.addTextlabel("FPS")
      .setPosition(x + 10, y + 70)
      .setText("FPS");
    ctlr.addFrameRate().setInterval(10).setPosition(x + 50, y + 70);
    ctlr.addTextlabel("Jumping")
      .setPosition(x + 200, y + 10)
      .setText("Jumping");
    widgets.put("JumpingValue", ctlr.addTextlabel("JumpingValue")
      .setPosition(x + 260, y + 10));
    ctlr.addTextlabel("Propelling")
      .setPosition(x + 200, y + 25)
      .setText("Propelling");
    widgets.put("PropellingValue", ctlr.addTextlabel("PropellingValue")
      .setPosition(x + 260, y + 25));
    ctlr.addTextlabel("OnObstacle")
      .setPosition(x + 200, y + 40)
      .setText("On obstacle");
    widgets.put("OnObstacleValue", ctlr.addTextlabel("OnObstracleValue")
      .setPosition(x + 260, y + 40)
      .setText("FALSE"));

    ctlr.addTextlabel("Preset Label")
      .setPosition(x + 10, y + 95)
      .setText("PRESET STYLES");
    ScrollableList slist = ctlr.addScrollableList("Preset Styles")
      .setPosition(x + 90, y + 90)
      .setSize(150, 100)
      .setBarHeight(20)
      .setItemHeight(15)
      .setItems(settings.presetStylesKeys())
      .plugTo(this, "presetChanged");
    slist.getValueLabel().toUpperCase(false);
    slist.getCaptionLabel().toUpperCase(false);

    Textfield textfield = ctlr.addTextfield("style name")
      .setPosition(x + 60, y + 120)
      .setSize(150, 20);
    textfield.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER);
    textfield.getCaptionLabel().setPadding(5, 0);
    slist.getValueLabel().setFont(textfield.getValueLabel().getFont()); // workaround to get defaultFontForText
    slist.getCaptionLabel().setFont(textfield.getValueLabel().getFont());
    ctlr.addButton("Save")
      .setPosition(x + 220, y + 120)
      .setSize(60, 20);

    nextWidgetPosition_y = y + 150;
    appendHalfwidthWidget("showTrail", ctlr.addToggle("Show trail"));
    appendHalfwidthWidget("showCenterMarker", ctlr.addToggle("Center marker"));
    appendHalfwidthWidget("parallaxScrolling", ctlr.addToggle("Parallax scrolling"));
    appendHalfwidthWidget("camVerticalEasing", ctlr.addToggle("Camera easing"));
    appendHalfwidthWidget("allowAerialJump", ctlr.addToggle("Allow aerial jump"));
    appendHalfwidthWidget("allowAerialWalk", ctlr.addToggle("Allow aerial walk"));
    appendHalfwidthWidget("constantRising", ctlr.addToggle("Constant rising"));
    appendHalfwidthWidget("haltedAndFall", ctlr.addToggle("Halted and fall"));
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
    appendFullwidthWidget("collisionTolerance", ctlr.addSlider("Collision Tolerance")
      .setSize(150, 20)
      .setRange(0, 24)
      .setNumberOfTickMarks(25)
      .showTickMarks(false));
    appendFullwidthWidget("camEasingNormal", ctlr.addSlider("Camera Easing Coef (normal)")
      .setSize(150, 20)
      .setRange(0, 1));
    appendFullwidthWidget("camEasingGrounding", ctlr.addSlider("Camera Easing Coef (grounding)")
      .setSize(150, 20)
      .setRange(0, 1));

    for (String name : settings.booleanValues) {
      Label caption = widgets.get(name).getCaptionLabel();
      caption.align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER);
      caption.setPadding(5, 0);
    }

    int id = 100;
    for (String name : widgets.keySet()) {
      Controller widget = widgets.get(name);
      widget.setId(id);
      id2parameter.put(id, name);
      id++;
    }

    ctlr.get(ScrollableList.class, "Preset Styles").bringToFront().setValue(0);
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
          System.err.println("Failed to set " + name + ".");
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
          System.err.println("Failed to set " + name + ".");
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
          System.err.println("Failed to set " + name + ".");
        }
      }
    } else if (widget instanceof Slider) {
      int action = event.getAction();
      if (action == ControlP5.ACTION_MOVE || action == ControlP5.ACTION_RELEASE || action == ControlP5.ACTION_RELEASE_OUTSIDE) {
        String name = id2parameter.get(event.getController().getId());
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          f.set(settings, widget.getValue());
        }
        catch (ReflectiveOperationException e) {
          System.err.println("Failed to set " + name + ".");
        }
      }
    } else if (widget instanceof Button) {
      if (event.getAction() == ControlP5.ACTION_CLICK) {
        String name = event.getController().getLabel();
        if (name == "Save") {
          String styleName = ctlr.get(Textfield.class, "style name").getText();
          if (styleName.isEmpty()) styleName = "Untitled";
          settings.save(styleName);
          List<String> styleNames = settings.presetStylesKeys();
          int idx = styleNames.indexOf(styleName);
          if (idx < 0) idx = 0;
          ctlr.get(ScrollableList.class, "Preset Styles").setItems(styleNames).setValue(idx);
        }
      }
    }
  }

  void presetChanged(int value) {
    String key = settings.presetStylesKeys().get(value);
    Textfield styleName = ctlr.get(Textfield.class, "style name");
    styleName.setValue(key);
    settings.setPreset(key);
    setValues();
  }
}
