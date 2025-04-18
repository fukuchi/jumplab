import controlP5.*;
import controlP5.Controller;
import java.util.Map;
import java.util.Map.Entry;
import java.lang.reflect.Field;
import java.util.Arrays;

class Console {
  int x, y, w, h;
  ControlP5 ctlr;
  HashMap<String, Controller> widgets;
  HashMap<Integer, String> id2parameter;
  HashMap<String, int[]> indicators;
  HashMap<String, Integer> buttonFunctionSelectorsMap;
  StyleManager styles;
  Settings settings;
  boolean halfFilled = false;
  Controller lastWidget;
  int nextWidgetPosition_y;
  static final int widgetMargin_y = 6;
  NumIndicator numIndicator;
  ChartCanvas chart;
  int chartJumperXIdx;
  int chartJumperYIdx;
  int chartCameraXIdx;
  int chartCameraYIdx;
  String currentTab = "global";
  CColor scrollableListItemColor = new CColor().setBackground(color(32, 64, 192));

  Console(PApplet parent, int x, int y, int w, int h, StyleManager styles, Settings settings) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.styles = styles;
    this.settings = settings;

    ctlr = new ControlP5(parent);
    widgets = new HashMap<String, Controller>();
    id2parameter = new HashMap<Integer, String>();
    indicators = new HashMap<String, int[]>();
    buttonFunctionSelectorsMap = new HashMap<String, Integer>();

    ctlr.getTab("default").setLabel("Jump1");
    ctlr.addTab("Jump2");
    ctlr.addTab("Camera");
    ctlr.addTab("Character");
    ctlr.addTab("Joystick");
    ctlr.addTab("Chart");
    ctlr.addTab("Misc");
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
      .moveTo("global"));

    ctlr.addTextlabel("Preset Label")
      .setPosition(x + 10, y + 95)
      .setText("STYLES")
      .moveTo("global");
    ScrollableList slist = ctlr.addScrollableList("Styles List")
      .setBackgroundColor(color(192))
      .setPosition(x + 60, y + 90)
      .setSize(150, 100)
      .setBarHeight(20)
      .setItemHeight(15)
      .setItems(styles.keyList())
      .moveTo("global")
      .plugTo(this, "styleSelected");
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
      .setRange(1, 20));
    appendHalfwidthWidget("maxVy", ctlr.addSlider("Max Vy")
      .setRange(1, 80));
    appendFullwidthWidget("jumpVelocity", ctlr.addSlider("Jump Velocity")
      .setRange(1, 30));
    appendFullwidthWidget("jumpVelocityBonus", ctlr.addSlider("Jump Velocity Bonus")
      .setRange(0, 0.5));
    appendFullwidthWidget("jumpAnticipationFrames", ctlr.addSlider("Jump Anticipation Frames")
      .setRange(0, 14)
      .setNumberOfTickMarks(15)
      .showTickMarks(false));
    appendFullwidthWidget("vxAdjustmentAtTakeoff", ctlr.addSlider("VX Adjustment at Takeoff")
      .setRange(-1.0, 1.0)
      .setSliderMode(Slider.FLEXIBLE));
    appendFullwidthWidget("maxPropellingFrames", ctlr.addSlider("Maximum Propelling Duration")
      .setRange(0, 100)
      .setNumberOfTickMarks(101)
      .showTickMarks(false));
    appendFullwidthWidget("gravity", ctlr.addSlider("Gravity (rising)")
      .setRange(0, 2));
    appendFullwidthWidget("gravityFalling", ctlr.addSlider("Gravity (falling)")
      .setRange(0.01, 2));
    appendFullwidthWidget("verticalSpeedSustainLevel", ctlr.addSlider("Jump Speed Sustain Level")
      .setRange(0, 1));
    appendFullwidthWidget("axNormal", ctlr.addSlider("X Accel (normal)")
      .setRange(0, 3));
    appendFullwidthWidget("axBrake", ctlr.addSlider("X Accel (braking)")
      .setRange(0, 3));
    appendFullwidthWidget("axJumping", ctlr.addSlider("X Accel (jumping)")
      .setRange(0, 3));
    appendFullwidthWidget("collisionTolerance", ctlr.addSlider("Collision Tolerance")
      .setRange(0, 24)
      .setNumberOfTickMarks(25)
      .showTickMarks(false));

    setTab("Jump2");
    nextWidgetPosition_y = y + 175;
    appendHalfwidthWidget("allowWallJump", ctlr.addToggle("Allow wall jump"));
    appendHalfwidthWidget("allowWallSlide", ctlr.addToggle("Allow wall slide"));
    appendFullwidthWidget("wallJumpSpeedRatio", ctlr.addSlider("Wall jump speed ratio")
      .setRange(0, 1));
    appendHalfwidthWidget("maxVxDashing", ctlr.addSlider("Max Vx Dashing")
      .setRange(1, 20));
    appendFullwidthWidget("axNormalDashing", ctlr.addSlider("X Accel (normal, dashing)")
      .setRange(0, 3));
    appendFullwidthWidget("vCollisionTolerance", ctlr.addSlider("Vertical Collision Tolerance")
      .setRange(0, 24)
      .setNumberOfTickMarks(25)
      .showTickMarks(false));

    // Settings of Camera motion
    setTab("Camera");
    nextWidgetPosition_y = y + 175;
    appendHalfwidthWidget("showCameraMarker", ctlr.addToggle("Camera marker"));
    appendHalfwidthWidget("cameraEasing_x", ctlr.addToggle("Camera easing X"));
    appendHalfwidthWidget("forwardFocus", ctlr.addToggle("Forward focus"));
    appendHalfwidthWidget("cameraEasing_y", ctlr.addToggle("Camera easing Y"));
    appendHalfwidthWidget("projectedFocus", ctlr.addToggle("Projected focus"));
    appendHalfwidthWidget("platformSnapping", ctlr.addToggle("Platform snapping"));
    appendFullwidthWidget("cameraEasingNormal_x", ctlr.addSlider("Camera X Easing Coef (normal)")
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraEasingNormal_y", ctlr.addSlider("Camera Y Easing Coef (normal)")
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraEasingGrounding_y", ctlr.addSlider("Camera Y Easing Coef (grounding)")
      .setRange(0.01, 0.5));
    appendFullwidthWidget("cameraWindow_w", ctlr.addSlider("Camera Window Width")
      .setRange(0, 400));
    appendFullwidthWidget("cameraWindow_h", ctlr.addSlider("Camera Window Height")
      .setRange(0, 400));
    appendFullwidthWidget("focusDistance", ctlr.addSlider("Focus Distance")
      .setRange(0, 400));
    appendFullwidthWidget("focusingSpeed", ctlr.addSlider("Focusing Speed")
      .setRange(0, 10));
    appendFullwidthWidget("focusResettingSpeed", ctlr.addSlider("Focus Resetting Speed")
      .setRange(0, 10));
    appendFullwidthWidget("bgScrollRatio", ctlr.addSlider("BG Scroll Speed")
      .setRange(0, 1));

    // Settings of character
    setTab("Character");
    nextWidgetPosition_y = y + 175;
    Textlabel label = ctlr.addTextlabel("Select Character", "SELECT CHARACTER:");
    label.getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM);
    appendFullwidthWidget(null, label);
    ScrollableList characterList = ctlr.addScrollableList("Character List")
      .setBackgroundColor(color(192))
      .setSize(280, 100)
      .setBarHeight(20)
      .setItemHeight(15)
      .setItems(gMasao.proportionLabels)
      .setValue(1)
      .plugTo(this, "characterSelected");
    appendFullwidthWidget("selectedCharacter", characterList);

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
    setItemsColor(joylist, scrollableListItemColor);

    for (int i=Joystick.MaxButtonNum-1; i>=0; i--) {
      label = ctlr.addTextlabel("Button_" + i);
      label.setText("Button " + i)
        .setPosition(x + 10, y + 235 + i * 25)
        .moveTo("Joystick");
      String listLabel = buttonFunctionListName(i);
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
      lockWidget(buttonFunctionList);
      buttonFunctionSelectorsMap.put(listLabel, i);
    }
    joylist.bringToFront();
    int currentJoystickIdx = gJoystick.getCurrentDeviceIndex();
    if (currentJoystickIdx >= 0) joylist.setValue(currentJoystickIdx);

    // Chart tab
    setTab("Chart");
    chart = new ChartCanvas(settings, x + 10, y + 175, w - 20, 300);
    chartJumperXIdx = chart.addSeries("Jumper X");
    chartJumperYIdx = chart.addSeries("Jumper Y");
    chartCameraXIdx = chart.addSeries("Camera X");
    chartCameraYIdx = chart.addSeries("Camera Y");
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
    appendHalfwidthWidget("showBoundingBox", ctlr.addToggle("Show bounding box"));
    appendHalfwidthWidget();

    label = ctlr.addTextlabel("Level", "LEVEL");
    label.getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM);
    appendFullwidthWidget(null, label);
    appendHalfwidthWidget("reloadLevel", ctlr.addButton("Reload Level"));

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

    ctlr.get(ScrollableList.class, "Styles List").bringToFront().setValue(0);
    setControllerValues();

    ctlr.addCallback(new CallbackListener() {
      public void controlEvent(CallbackEvent event) {
        parameterChange(event);
      }
    }
    );

    numIndicator = new NumIndicator();

    ctlr.setAutoDraw(false);
  }

  void appendFullwidthWidget(String name, Controller widget) {
    if (halfFilled) {
      halfFilled = false;
      if (lastWidget != null) {
        nextWidgetPosition_y += lastWidget.getHeight() + widgetMargin_y;
      }
    }
    if (widget instanceof Slider) {
      widget.setSize(150, 20);
    }
    widget.setPosition(x + 10, nextWidgetPosition_y);
    widget.moveTo(currentTab);
    if (name != null) widgets.put(name, widget);
    nextWidgetPosition_y += widget.getHeight() + widgetMargin_y;
    lastWidget = widget;
  }

  void appendHalfwidthWidget(String name, Controller widget) {
    if (widget instanceof Slider) {
      widget.setSize(80, 20);
    }
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
    chart.updateSeries(chartJumperXIdx, jumper.center_x() / level.w);
    chart.updateSeries(chartJumperYIdx, 1.0 - jumper.center_y() / level.h);
    chart.updateSeries(chartCameraXIdx, camera.x / level.w);
    chart.updateSeries(chartCameraYIdx, 1.0 - camera.y / level.h);
    chart.updateChart();
  }

  void draw(Jumper jumper) {
    ctlr.draw();
    drawStatus(jumper);
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
    for (String name : Settings.listVariables) {
      ScrollableList slist = (ScrollableList)widgets.get(name);
      if (slist != null) {
        try {
          Field f = Class.forName("jumplab$Settings").getDeclaredField(name);
          String s = (String)f.get(settings);
          int idx = Arrays.asList(gMasao.proportionLabels).indexOf(s);
          if (idx >= 0) {
            slist.setValue(idx);
          } else {
            System.err.println("Invalid character name is found: " + s);
          }
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
      if (event.getAction() == ControlP5.ACTION_BROADCAST) {
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
          styles.upsert(styleName, settings);
          styles.save(userSettingsFilename);
          List<String> styleNames = styles.keyList();
          int idx = styleNames.indexOf(styleName);
          if (idx < 0) idx = 0; // if not found, choose the default.
          ScrollableList slist = ctlr.get(ScrollableList.class, "Styles List");
          slist.setItems(styleNames).setValue(idx);
          setItemsColor(slist, scrollableListItemColor);
        } else if (name == "Reload Level") {
          gLevel.loadLevel();
          gCamera.updateLevelImage();
          gMasao.adjustPosition();
        }
      }
    } else if (widget instanceof Textfield) {
      String name = event.getController().getLabel();
      if (name == "style name") {
        if (event.getAction() == ControlP5.ACTION_LEAVE) {
          String styleName = ((Textfield)widget).getText();
          changeSaveButtonStatus(styles.isModifiable(styleName));
        }
      }
    } else if (widget instanceof ScrollableList) {
      String name = event.getController().getName();
      if (name.matches(buttonFunctionListName("([0-9]*)"))) {
        if (event.getAction() == ControlP5.ACTION_BROADCAST) {
          assignButtonFunction(name, (ScrollableList)widget, (int)event.getController().getValue());
        }
      }
    }
  }

  void styleSelected(int value) {
    String key = styles.keyList().get(value);
    Textfield styleName = ctlr.get(Textfield.class, "style name");
    styleName.setValue(key);
    settings.load(styles.get(key));
    setControllerValues();
    changeSaveButtonStatus(styles.isModifiable(key));
  }

  void styleNameChanged(String str) {
    changeSaveButtonStatus(styles.isModifiable(str));
  }

  void changeSaveButtonStatus(boolean modifiable) {
    Button saveButton = ctlr.get(Button.class, "Save");
    if (modifiable) {
      unlockWidget(saveButton);
    } else {
      lockWidget(saveButton);
    }
  }

  void characterSelected(int value) {
    gMasao.setImages(value);
  }

  void joystickSelected(int value) {
    gJoystick.selectDevice(value);
    gJoystick.saveConfig();
    setButtonAssignmentsValue();
  }

  void setButtonAssignmentsValue() {
    for (int i=0; i<Joystick.MaxButtonNum; i++) {
      ScrollableList buttonFunctionList = ctlr.get(ScrollableList.class, buttonFunctionListName(i));
      if (gJoystick.buttons[i] != null) {
        unlockWidget(buttonFunctionList);
        int n = gJoystick.buttons[i].buttonFunction.ordinal();
        buttonFunctionList.setValue(n);
      } else {
        buttonFunctionList.setValue(0);
        lockWidget(buttonFunctionList);
      }
    }
  }

  void assignButtonFunction(String name, ScrollableList widget, int index) {
    gJoystick.assignButtonFunction(buttonFunctionSelectorsMap.get(name), (ButtonFunction) widget.getItem(index).get("value"));
    gJoystick.saveConfig();
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

  void lockWidget(Controller widget) {
    widget.lock();
    widget.setColorBackground(color(192, 192, 192));
    widget.setColorForeground(color(128, 128, 128));
  }

  void unlockWidget(Controller widget) {
    widget.unlock();
    CColor mainColor = ControlP5.getColor();
    widget.setColorBackground(mainColor.getBackground());
    widget.setColorForeground(mainColor.getForeground());
  }

  void buttonFunctionActivated(ButtonFunction func) {
    switch(func) {
    case TOGGLE_TRAIL:
      toggleShowTrail();
      break;
    case TOGGLE_CAMERA:
      toggleShowCameraMarker();
      break;
    case NEXT_STYLE:
      shiftStyle(1);
      break;
    case PREV_STYLE:
      shiftStyle(-1);
      break;
    case PAUSE:
      togglePause();
      break;
    case STEP_FORWARD:
      pressStepForward();
      break;
    default:
      break;
    }
  }

  void toggleButton(String name) {
    Toggle button = (Toggle)widgets.get(name);
    button.toggle();
  }

  void toggleShowTrail() {
    toggleButton("showTrail");
  }

  void toggleShowCameraMarker() {
    toggleButton("showCameraMarker");
  }

  void togglePause() {
    gPause ^= true;
  }

  void pressStepForward() {
    gStepForward = true;
  }

  void shiftStyle(int dir) {
    ScrollableList slist = ctlr.get(ScrollableList.class, "Styles List");
    int slistItemsNum = slist.getItems().size();
    int newValue = ((int)slist.getValue() + dir + slistItemsNum) % slistItemsNum;
    slist.setValue(newValue);
  }

  String buttonFunctionListName(int i) {
    return "Button " + i + " feature";
  }

  String buttonFunctionListName(String regexp) {
    return "Button " + regexp + " feature";
  }

  boolean keyPressed() {
    if (key == 'p') {
      togglePause();
      return true;
    } else if (key == '.') {
      pressStepForward();
    }

    return false;
  }

  boolean keyReleased() {
    return false;
  }
}
