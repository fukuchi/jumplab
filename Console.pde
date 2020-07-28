import controlP5.*;
import java.util.Map;
import java.lang.reflect.Field;

class Console {
  int x, y, w, h;
  ControlP5 ctlr;
  HashMap<String, Controller> widgets;
  HashMap<Integer, String> id2parameter;
  Settings settings;
  int lastWidget_y;

  Console(PApplet parent, int x, int y, int w, int h, Settings settings) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.settings = settings;

    ctlr = new ControlP5(parent);
    widgets = new HashMap<String, Controller>();
    id2parameter = new HashMap<Integer, String>();

    ctlr.addTextlabel("JumperXY")
      .setPosition(x + 10, y + 10)
      .setText("Jumper X,Y");
    widgets.put("JumperXYvalue", ctlr.addTextlabel("JumperXYvalue")
      .setPosition(x + 80, y + 10)
      .setText("0000,0000"));
    ctlr.addTextlabel("JumperVXY")
      .setPosition(x + 10, y + 30)
      .setText("Jumper VX,VY");
    widgets.put("JumperVXYvalue", ctlr.addTextlabel("JumperVXYvalue")
      .setPosition(x + 80, y + 30)
      .setText("0000,0000"));
    ctlr.addTextlabel("VerticalAcc")
      .setPosition(x + 10, y + 60)
      .setText("Vertical Acc");
    widgets.put("VerticalAccValue", ctlr.addTextlabel("VerticalAccValue")
      .setPosition(x + 80, y + 60)
      .setText("0000.00"));
    ctlr.addTextlabel("Jumping")
      .setPosition(x + 160, y + 10)
      .setText("Jumping: ");
    widgets.put("JumpingValue", ctlr.addTextlabel("JumpingValue")
      .setPosition(x + 220, y + 10)
      .setText("false"));
    ctlr.addTextlabel("OnObstacle")
      .setPosition(x + 160, y + 30)
      .setText("On obstacle: ");
    widgets.put("OnObstacleValue", ctlr.addTextlabel("OnObstracleValue")
      .setPosition(x + 220, y + 30)
      .setText("false"));
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
    widgets.put("showTrail", ctlr.addToggle("Show trail")
      .setPosition(x + 20, y + 120)
      .setValue(settings.showTrail));
    widgets.put("showCenterMarker", ctlr.addToggle("Center marker")
      .setPosition(x + 150, y + 120)
      .setValue(settings.showTrail));
    widgets.put("parallaxScrolling", ctlr.addToggle("Parallax scrolling")
      .setPosition(x + 20, y + 150)
      .setValue(settings.showTrail));
    widgets.put("camVerticalEasing", ctlr.addToggle("Camera easing")
      .setPosition(x + 150, y + 150)
      .setValue(settings.showTrail));
    widgets.put("allowAerialJump", ctlr.addToggle("Allow aerial jump")
      .setPosition(x + 20, y + 180)
      .setValue(settings.showTrail));
    widgets.put("allowAerialWalk", ctlr.addToggle("Allow aerial walk")
      .setPosition(x + 150, y + 180)
      .setValue(settings.showTrail));
    widgets.put("maxVx", ctlr.addSlider("Max Vx")
      .setPosition(x + 10, y + 230)
      .setSize(80, 20)
      .setRange(1, 20));
    widgets.put("maxVy", ctlr.addSlider("Max Vy")
      .setPosition(x + 140, y + 230)
      .setSize(80, 20)
      .setRange(1, 80));
    lastWidget_y = y + 230;
    appendFullwidthWidget("jumpPower", ctlr.addSlider("Jump Velocity")
      .setSize(150, 20)
      .setRange(1, 30));
    appendFullwidthWidget("jumpAnticipationFrames", ctlr.addSlider("Jump Anticipation Frames")
      .setSize(150, 20)
      .setRange(0, 9)
      .setNumberOfTickMarks(10)
      .showTickMarks(false));
    appendFullwidthWidget("gravity", ctlr.addSlider("Gravity (rising)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("gravityFalling", ctlr.addSlider("Gravity (falling)")
      .setSize(150, 20)
      .setRange(0.01, 3));
    appendFullwidthWidget("axNormal", ctlr.addSlider("X Accel (normal)")
      .setSize(150, 20)
      .setRange(0, 3));
    appendFullwidthWidget("axBreak", ctlr.addSlider("X Accel (breaking)")
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
  }

  void appendFullwidthWidget(String name, Controller widget) {
    lastWidget_y += 30;
    widget.setPosition(x + 10, lastWidget_y);
    widgets.put(name, widget);
  }

  void statusUpdate(Jumper jumper) {
    ((Textlabel)widgets.get("JumperXYvalue")).setText(String.format("%4.2f,%4.2f", jumper.x, jumper.y));
    ((Textlabel)widgets.get("JumperVXYvalue")).setText(String.format("%-2.2f,%-2.2f", jumper.vx, jumper.vy));
    ((Textlabel)widgets.get("VerticalAccValue")).setText(String.format("%-2.2f", jumper.verticalAcc));

    ((Textlabel)widgets.get("JumpingValue")).setText(jumper.jumping?"true":"false");
    ((Textlabel)widgets.get("OnObstacleValue")).setText(jumper.onObstacle?"true":"false");
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
      if (event.getAction() == ControlP5.ACTION_CLICK) {
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
