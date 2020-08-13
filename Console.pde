import controlP5.*;
import controlP5.Controller;
import java.util.Map;
import java.util.Map.Entry;
import java.lang.reflect.Field;

class Console {
  int x, y, w, h;
  ControlP5 ctlr;
  HashMap<String, Controller> widgets;
  HashMap<Integer, String> id2parameter;
  HashMap<String, int[]> indicators;
  HashMap<String, Integer> buttonFunctionSelectorsMap;
  PresetManager presets;
  Settings settings;
  boolean halfFilled = false;
  Controller lastWidget;
  int nextWidgetPosition_y;
  static final int widgetMargin_y = 6;
  NumIndicator numIndicator;
  ChartCanvas chart;
  String currentTab = "global";
  CColor scrollableListItemColor = new CColor().setBackground(color(32, 64, 192));

  Console(PApplet parent, int x, int y, int w, int h, PresetManager presets, Settings settings) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.presets = presets;
    this.settings = settings;

    ctlr = new ControlP5(parent);
    widgets = new HashMap<String, Controller>();
    id2parameter = new HashMap<Integer, String>();
    indicators = new HashMap<String, int[]>();
    buttonFunctionSelectorsMap = new HashMap<String, Integer>();

    ctlr.addTab("Camera")
      .setId(2)
      .activateEvent(true);
    ctlr.addTab("Joystick")
      .setId(3)
      .activateEvent(true);
    ctlr.addTab("Chart")
      .setId(4)
      .activateEvent(true);
    ctlr.addTab("Misc")
      .setId(5)
      .activateEvent(true);
    ctlr.getTab("default")
      .setLabel("Jump")
      .setId(1)
      .activateEvent(true);
    ctlr.getWindow().setPositionOfTabs(x + 10, y + 150);
    stroke(255);
    ctlr.addTextlabel("ProgramTitle")
      .setPosition(x + 10, y + 5)
      .setText("JumpLab ver. " + gVersionString)
      .moveTo("global");
    ctlr.addTextlabel("JumperXY")
      .setPosition(x + 10, y + 25)
      .setText("Jumper X,Y")
      .moveTo("global");
    indicators.put("JumperXYvalue", new int[] {x + 80, y + 25});
    ctlr.addTextlabel("JumperVXY")
      .setPosition(x + 10, y + 40)
      .setText("Jumper VX,VY")
      .moveTo("global");
    indicators.put("JumperVXYvalue", new int[] {x + 80, y + 40});
    ctlr.addTextlabel("JumperAXY")
      .setPosition(x + 10, y + 55)
      .setText("Jumper AX,AY")
      .moveTo("global");
    indicators.put("JumperAXYValue", new int[] {x + 80, y + 55});
    ctlr.addTextlabel("PropellingRemainingFrames")
      .setPosition(x + 10, y + 70)
      .setText("Propelling Remaining")
      .moveTo("global");
    indicators.put("PropellingRemainingFramesValue", new int[] {x + 98, y + 70});
    ctlr.addTextlabel("FPS")
      .setPosition(x + 200, y + 70)
      .setText("FPS")
      .moveTo("global");
    ctlr.addFrameRate().setInterval(10).setPosition(x + 260, y + 70).moveTo("global");
    ctlr.addTextlabel("Jumping")
      .setPosition(x + 200, y + 25)
      .setText("Jumping")
      .moveTo("global");
    widgets.put("JumpingValue", ctlr.addTextlabel("JumpingValue")
      .setPosition(x + 260, y + 25)
      .moveTo("global"));
    ctlr.addTextlabel("Propelling")
      .setPosition(x + 200, y + 40)
      .setText("Propelling")
      .moveTo("global");
    widgets.put("PropellingValue", ctlr.addTextlabel("PropellingValue")
      .setPosition(x + 260, y + 40)
      .moveTo("global"));
    ctlr.addTextlabel("OnObstacle")
      .setPosition(x + 200, y + 55)
      .setText("On obstacle")
      .moveTo("global");
    widgets.put("OnObstacleValue", ctlr.addTextlabel("OnObstracleValue")
      .setPosition(x + 260, y + 55)
      .setText("FALSE")
      .moveTo("global"));

    ctlr.addTextlabel("Preset Label")
      .setPosition(x + 10, y + 95)
      .setText("PRESET STYLES")
      .moveTo("global");
    ScrollableList slist = ctlr.addScrollableList("Preset Styles")
      .setBackgroundColor(color(192))
      .setPosition(x + 90, y + 90)
      .setSize(150, 100)
      .setBarHeight(20)
      .setItemHeight(15)
      .setItems(presets.keyList())
      .moveTo("global")
      .plugTo(this, "presetSelected");
    slist.getValueLabel().toUpperCase(false);
    slist.getCaptionLabel().toUpperCase(false);
    setItemsColor(slist, scrollableListItemColor);

    Textfield textfield = ctlr.addTextfield("style name")
      .setPosition(x + 60, y + 120)
      .setSize(150, 20)
      .setAutoClear(false)
      .moveTo("global")
      .plugTo(this, "styleNameChanged");
    textfield.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER);
    textfield.getCaptionLabel().setPadding(5, 0);
    slist.getValueLabel().setFont(textfield.getValueLabel().getFont()); // workaround to get defaultFontForText
    slist.getCaptionLabel().setFont(textfield.getValueLabel().getFont());
    ctlr.addButton("Save")
      .setPosition(x + 220, y + 120)
      .setSize(60, 20)
      .moveTo("global");

    // Settings of jumping
    setTab("default");
    nextWidgetPosition_y = y + 175;
    appendHalfwidthWidget("showTrail", ctlr.addToggle("Show trail"));
    appendHalfwidthWidget("stopAndFall", ctlr.addToggle("Stop and fall"));
    appendHalfwidthWidget("allowAerialJump", ctlr.addToggle("Allow aerial jump"));
    appendHalfwidthWidget("allowAerialWalk", ctlr.addToggle("Allow aerial walk"));
    appendHalfwidthWidget("allowAerialTurn", ctlr.addToggle("Allow aerial turn"));
    appendHalfwidthWidget();
    appendHalfwidthWidget("maxVx", ctlr.addSlider("Max Vx")
      .setSize(80, 20)
      .setRange(1, 20));
    appendHalfwidthWidget("maxVy", ctlr.addSlider("Max Vy")
      .setSize(80, 20)
      .setRange(1, 80));
    appendFullwidthWidget("jumpVelocity", ctlr.addSlider("Jump Velocity")
      .setSize(150, 20)
      .setRange(1, 30));
    appendFullwidthWidget("jumpVelocityBonus", ctlr.addSlider("Jump Velocity Bonus")
      .setSize(150, 20)
      .setRange(0, 0.5));
    appendFullwidthWidget("jumpAnticipationFrames", ctlr.addSlider("Jump Anticipation Frames")
      .setSize(150, 20)
      .setRange(0, 14)
      .setNumberOfTickMarks(15)
      .showTickMarks(false));
    appendFullwidthWidget("vxAdjustmentAtTakeoff", ctlr.addSlider("VX Adjustment at Takeoff")
      .setSize(150, 20)
      .setRange(-1.0, 1.0)
      .setSliderMode(Slider.FLEXIBLE));
    appendFullwidthWidget("maxPropellingFrames", ctlr.addSlider("Maximum Propelling Duration")
      .setSize(150, 20)
      .setRange(0, 100)
      .setNumberOfTickMarks(101)
      .showTickMarks(false));
    appendFullwidthWidget("gravity", ctlr.addSlider("Gravity (rising)")
      .setSize(150, 20)
      .setRange(0, 2));
    appendFullwidthWidget("gravityFalling", ctlr.addSlider("Gravity (falling)")
      .setSize(150, 20)
      .setRange(0.01, 2));
    appendFullwidthWidget("verticalSpeedSustainLevel", ctlr.addSlider("Jump Speed Sustain Level")
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

    // Settings of Camera motion
    setTab("Camera");
    nextWidgetPosition_y = y + 175;
    appendHalfwidthWidget("showCameraMarker", ctlr.addToggle("Camera marker"));
    appendHalfwidthWidget("parallaxScrolling", ctlr.addToggle("Parallax scrolling"));
    appendHalfwidthWidget("cameraEasing_x", ctlr.addToggle("Camera easing X"));
    appendHalfwidthWidget("cameraEasing_y", ctlr.addToggle("Camera easing Y"));
    appendHalfwidthWidget("forwardFocus", ctlr.addToggle("Forward focus"));
    appendHalfwidthWidget("platformSnapping", ctlr.addToggle("Platform snapping"));
    appendHalfwidthWidget("projectedFocus", ctlr.addToggle("Projected focus"));
    appendFullwidthWidget("cameraEasingNormal_x", ctlr.addSlider("Camera X Easing Coef (normal)")
      .setSize(150, 20)
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraEasingNormal_y", ctlr.addSlider("Camera Y Easing Coef (normal)")
      .setSize(150, 20)
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraEasingGrounding_y", ctlr.addSlider("Camera Y Easing Coef (grounding)")
      .setSize(150, 20)
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraWindow_w", ctlr.addSlider("Camera Window Width")
      .setSize(150, 20)
      .setRange(0, 400));
    appendFullwidthWidget("cameraWindow_h", ctlr.addSlider("Camera Window Height")
      .setSize(150, 20)
      .setRange(0, 400));
    appendFullwidthWidget("focusDistance", ctlr.addSlider("Focus Distance")
      .setSize(150, 20)
      .setRange(0, 400));
    appendFullwidthWidget("focusingSpeed", ctlr.addSlider("Focusing Speed")
      .setSize(150, 20)
      .setRange(0, 30));

    // Settings of joystick
    setTab("Joystick");
    nextWidgetPosition_y = y + 175;
    appendFullwidthWidget(null, ctlr.addTextlabel("Select Joystick")
      .setText("SELECT JOYSTICK:"));
    ScrollableList joylist = ctlr.addScrollableList("Joystick List")
      .setBackgroundColor(color(192))
      .setSize(280, 100)
      .setBarHeight(20)
      .setItemHeight(15)
      .setItems(gJoystick.getJoystickNames(60))
      .plugTo(this, "joystickSelected");
    joylist.getValueLabel().toUpperCase(false);
    joylist.getCaptionLabel().toUpperCase(false);
    joylist.getValueLabel().setFont(textfield.getValueLabel().getFont()); // workaround to get defaultFontForText
    joylist.getCaptionLabel().setFont(textfield.getValueLabel().getFont());
    appendFullwidthWidget("joystickList", joylist);
    int currentJoystickIdx = gJoystick.getCurrentDeviceIndex();
    if (currentJoystickIdx >= 0) joylist.setValue(currentJoystickIdx);
    setItemsColor(joylist, scrollableListItemColor);

    for (int i=gJoystick.buttons.length-1; i>=0; i--) {
      Textlabel label = ctlr.addTextlabel("Button_" + i);
      label.setText("Button " + i)
        .setPosition(x + 10, y + 235 + i * 25)
        .moveTo("Joystick");
      String listLabel = "Button " + i + " feature";
      ScrollableList buttonFunctionList = ctlr.addScrollableList(listLabel)
        .setBackgroundColor(color(192))
        .setSize(150, 100)
        .setBarHeight(20)
        .setItemHeight(15)
        .setPosition(x + 80, y + 230 + i * 25)
        .setItems(ButtonFunction.getValuesMap())
        .setValue(0)
        .moveTo("Joystick");
      setItemsColor(buttonFunctionList, scrollableListItemColor);
      buttonFunctionSelectorsMap.put(listLabel, i);
    }
    joylist.bringToFront();

    // Chart tab
    setTab("Chart");
    chart = new ChartCanvas(settings, x + 10, y + 175, w - 20, 300);
    chart.addSeries("Jumper X");
    chart.addSeries("Jumper Y");
    chart.addSeries("Camera X");
    chart.addSeries("Camera Y");
    chart.pre();
    ctlr.getTab("Chart").addCanvas(chart);
    nextWidgetPosition_y = y + 480;
    Toggle toggle = ctlr.addToggle("Show Velocity");
    toggle.plugTo(this, "showVelocityChartChanged");
    appendHalfwidthWidget("showVelocityChart", toggle);

    // Misc tab
    setTab("Misc");
    nextWidgetPosition_y = y + 175;
    appendHalfwidthWidget("showAfterimage", ctlr.addToggle("Show afterimage"));
    appendHalfwidthWidget("showInputStatus", ctlr.addToggle("Show input status"));

    for (Entry<String, Controller> entry : widgets.entrySet()) {
      Controller widget = entry.getValue();
      if (widget instanceof Toggle) {
        Label caption = widget.getCaptionLabel();
        caption.align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER);
        caption.setPadding(5, 0);
      }
    }

    int id = 100;
    for (Entry<String, Controller> entry : widgets.entrySet()) {
      Controller widget = entry.getValue();
      widget.setId(id);
      id2parameter.put(id, entry.getKey());
      id++;
    }

    ctlr.get(ScrollableList.class, "Preset Styles").bringToFront().setValue(0);
    setControllerValues();

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
    widget.moveTo(currentTab);
    if (name != null) widgets.put(name, widget);
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
    widget.moveTo(currentTab);
    if (name != null) widgets.put(name, widget);
    lastWidget = widget;
  }

  void appendHalfwidthWidget() {
    if (halfFilled) {
      nextWidgetPosition_y += lastWidget.getHeight() + widgetMargin_y;
      halfFilled = false;
    }
  }

  void statusUpdate(Jumper jumper, Level level, Camera camera) {
    ((Textlabel)widgets.get("JumpingValue")).setText(jumper.jumping?"TRUE":"FALSE");
    ((Textlabel)widgets.get("PropellingValue")).setText(jumper.propelling?"TRUE":"FALSE");
    ((Textlabel)widgets.get("OnObstacleValue")).setText(jumper.onObstacle?"TRUE":"FALSE");
    chart.updateSeries("Jumper X", (jumper.x + Jumper.w / 2) / level.w);
    chart.updateSeries("Jumper Y", 1.0 - (jumper.y + Jumper.h / 2) / level.h);
    chart.updateSeries("Camera X", camera.x / level.w);
    chart.updateSeries("Camera Y", 1.0 - camera.y / level.h);
    chart.updateChart();
  }

  void drawStatus(Jumper jumper) {
    drawNumIndicator("JumperXYvalue", String.format("%7.2f,%7.2f", jumper.x, jumper.y));
    drawNumIndicator("JumperVXYvalue", String.format("% 7.2f,% 7.2f", jumper.vx, jumper.vy));
    drawNumIndicator("JumperAXYValue", String.format("% 7.2f,% 7.2f", jumper.vx - jumper.pvx, jumper.vy - jumper.pvy));
    drawNumIndicator("PropellingRemainingFramesValue", String.format("%4d", jumper.propellingRemainingFrames));
    drawButtonsStatus();
  }

  void drawButtonsStatus() {
    if (ctlr.getTab("Joystick").isActive()) {
      stroke(255);
      for (int i=0; i<gJoystick.buttons.length; i++) {
        if (gJoystick.buttons[i] != null) {
          if (gJoystick.buttons[i].getValue() > 0) {
            fill(255, 255, 0);
          } else {
            fill(64, 64, 0);
          }
        } else {
          fill(128);
        }
        rect (x + 60, y + 234 + i * 25, 10, 10);
      }
    }
  }

  void drawNumIndicator(String name, String str) {
    int[] pos = indicators.get(name);
    numIndicator.text(str, pos[0], pos[1]);
  }

  void setControllerValues() {
    for (String name : Settings.booleanVariables) {
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
    for (String name : Settings.floatVariables) {
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
          presets.upsert(styleName, settings);
          presets.save(userSettingsFilename);
          List<String> presetNames = presets.keyList();
          int idx = presetNames.indexOf(styleName);
          if (idx < 0) idx = 0; // if not found, choose the default.
          ScrollableList slist = ctlr.get(ScrollableList.class, "Preset Styles");
          slist.setItems(presetNames).setValue(idx);
          setItemsColor(slist, scrollableListItemColor);
        }
      }
    } else if (widget instanceof Textfield) {
      String name = event.getController().getLabel();
      if (name == "style name") {
        if (event.getAction() == ControlP5.ACTION_LEAVE) {
          String styleName = ((Textfield)widget).getText();
          changeSaveButtonStatus(presets.isModifiable(styleName));
        }
      }
    } else if (widget instanceof ScrollableList) {
      String name = event.getController().getName();
      if (name.matches("Button ([0-9]*) feature")) {
        if (event.getAction() == ControlP5.ACTION_BROADCAST) {
          assignButtonFunction(name, (ScrollableList)widget, (int)event.getController().getValue());
        }
      }
    }
  }

  void presetSelected(int value) {
    String key = presets.keyList().get(value);
    Textfield styleName = ctlr.get(Textfield.class, "style name");
    styleName.setValue(key);
    settings.load(presets.get(key));
    setControllerValues();
    changeSaveButtonStatus(presets.isModifiable(key));
  }

  void styleNameChanged(String str) {
    changeSaveButtonStatus(presets.isModifiable(str));
  }

  void changeSaveButtonStatus(boolean modifiable) {
    Button saveButton = ctlr.get(Button.class, "Save");
    if (modifiable) {
      saveButton.unlock();
      CColor mainColor = ControlP5.getColor();
      saveButton.setColorBackground(mainColor.getBackground());
      saveButton.setColorForeground(mainColor.getForeground());
    } else {
      saveButton.lock();
      saveButton.setColorBackground(color(192, 192, 192));
      saveButton.setColorForeground(color(128, 128, 128));
    }
  }

  void joystickSelected(int value) {
    gJoystick.selectDevice(value);
    gJoystick.saveConfig();
  }

  void assignButtonFunction(String name, ScrollableList widget, int index) {
    gJoystick.assignButtonFunction(buttonFunctionSelectorsMap.get(name), (ButtonFunction) widget.getItem(index).get("value"));
  }

  void showVelocityChartChanged() {
    chart.showVelocityChartChanged();
  }

  void setTab(String name) {
    currentTab = name;
    halfFilled = false;
  }

  void setItemsColor(ScrollableList list, CColor col) {
    for (Object itemPtr : list.getItems()) {
      Map<String, Object> item = (Map<String, Object>)itemPtr;
      item.put("color", col);
    }
  }
}
