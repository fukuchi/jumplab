import net.java.games.input.*;
import org.gamecontrolplus.*;

class Joystick {
  ControlIO ctrlio;
  List<ControlDevice> devices;
  ControlDevice currentDevice;
  ControlSlider slider_x;
  JoyButton[] buttons;
  int prevAxisX = 0;
  boolean[] prevButtonPressed;
  boolean[] buttonPressed;
  static final float stickMargin = 0.2;
  String configFilename;

  private class JoyButton {
    ControlButton ctlrButton;
    ButtonFunction buttonFunction;

    JoyButton(ControlButton button) {
      this(button, ButtonFunction.NONE);
    }

    JoyButton(ControlButton button, ButtonFunction func) {
      ctlrButton = button;
      buttonFunction = func;
    }

    float getValue() {
      return ctlrButton.getValue();
    }

    JoyButton setFunction(ButtonFunction func) {
      buttonFunction = func;
      return this;
    }

    ButtonFunction getFunction() {
      return buttonFunction;
    }
  }

  Joystick(PApplet parent, String configFilename) {
    buttons = new JoyButton[12]; // 12 would be enough for the most joysticks
    prevButtonPressed = new boolean[ButtonFunction.size];
    buttonPressed = new boolean[ButtonFunction.size];
    ctrlio = ControlIO.getInstance(parent);
    devices = new ArrayList<ControlDevice>();
    for (ControlDevice dev : ctrlio.getDevices()) {
      int controllerType = dev.getTypeID();
      if ((controllerType & (GCP.STICK | GCP.GAMEPAD)) == 0) continue;
      devices.add(dev);
    }
    this.configFilename = configFilename;
    loadConfig();
  }

  boolean loadConfig() {
    JSONObject configJson;

    /* Processing 3.5.4 does not return null if the file is not found
     and throws NullPointerException. As a workaround, we check the
     file exists or not before open the file. */
    BufferedReader reader;
    reader = createReader(configFilename);
    if (reader == null) {
      return false;
    }
    println("loading '" + configFilename + "'...");

    try {
      configJson = new JSONObject(reader);
      reader.close();
    }
    catch (IOException e) {
      e.printStackTrace();
      return false;
    }
    catch (RuntimeException e) {
      System.err.println("Failed to load '" + configFilename + "'.");
      e.printStackTrace();
      return false;
    }

    String lastSelectedDeviceName = configJson.getString("lastSelected", null);
    if (lastSelectedDeviceName != null) {
      for (ControlDevice dev : devices) {
        if (dev.getName().equals(lastSelectedDeviceName)) {
          selectDevice(dev);
          break;
        }
      }
    }

    return true;
  }

  void saveConfig() {
    JSONObject configJson = new JSONObject();
    configJson.setString("lastSelected", currentDevice.getName());
    saveJSONObject(configJson, "data/" + configFilename);
  }

  List<String> getJoystickNames(int maxLength) {
    ArrayList<String> list = new ArrayList<String>();
    for (ControlDevice dev : devices) {
      String name = dev.getName();
      if (name.length() > maxLength) {
        name = name.substring(0, maxLength - 3) + "...";
      }
      list.add(name);
    }
    return list;
  }

  void update(int[] res) {
    if (currentDevice == null) return;
    currentDevice.update();
    axesUpdate(res);
    buttonsUpdate(res);
  }

  void axesUpdate(int[] res) {
    int axisX = 0;
    float axisXRawValue = slider_x.getValue();

    if (axisXRawValue < -stickMargin) {
      axisX = -1;
    } else if (axisXRawValue > stickMargin) {
      axisX = 1;
    }
    if (prevAxisX == axisX) {
      res[0] = 0;
      res[1] = 0;
    } else {
      if (prevAxisX < 0) {
        res[0] = -1;
      }
      if (prevAxisX > 0) {
        res[1] = -1;
      }
      if (axisX < 0) {
        res[0] = 1;
      }
      if (axisX > 0) {
        res[1] = 1;
      }
    }
    prevAxisX = axisX;
  }

  void buttonsUpdate(int[] res) {
    for (int i=0; i<ButtonFunction.size; i++) {
      prevButtonPressed[i] = buttonPressed[i];
      buttonPressed[i] = false;
    }
    for (int i=0; i<buttons.length; i++) {
      if (buttons[i] != null) {
        ButtonFunction func = buttons[i].getFunction();
        if (func != ButtonFunction.NONE) {
          if (buttons[i].getValue() > 0) {
            buttonPressed[func.ordinal()] |= true;
          }
        }
      }
    }
    if (prevButtonPressed[ButtonFunction.JUMP.ordinal()]) {
      res[2] = buttonPressed[ButtonFunction.JUMP.ordinal()]?0:-1;
    } else {
      res[2] = buttonPressed[ButtonFunction.JUMP.ordinal()]?1:0;
    }
    if (buttonPressed[ButtonFunction.TOGGLE_TRAIL.ordinal()] && !prevButtonPressed[ButtonFunction.TOGGLE_TRAIL.ordinal()]) {
      gConsole.toggleShowTrail();
    }
    if (buttonPressed[ButtonFunction.TOGGLE_CAMERA.ordinal()] && !prevButtonPressed[ButtonFunction.TOGGLE_CAMERA.ordinal()]) {
      gConsole.toggleShowCameraMarker();
    }
  }

  ControlDevice selectDevice(int idx) {
    return selectDevice(devices.get(idx));
  }

  ControlDevice selectDevice(ControlDevice device) {
    if (currentDevice != null) {
      currentDevice.close();
    }
    slider_x = null;
    for (int i=0; i<buttons.length; i++) {
      buttons[i] = null;
    }
    currentDevice = device;
    currentDevice.open();
    int sliders = currentDevice.getNumberOfSliders();
    for (int i=0; i<sliders; i++) {
      ControlSlider s = currentDevice.getSlider(i);
      if (s.getName().matches("[xX].*")) { // workaround needed because GCP hides the component's identifier.
        slider_x = s;
        break;
      }
    }
    int buttonsNum = min(buttons.length, currentDevice.getNumberOfButtons());
    for (int i=0; i<buttonsNum; i++) {
      buttons[i] = new JoyButton(currentDevice.getButton(i));
    }

    return currentDevice;
  }

  int getCurrentDeviceIndex() {
    for (int i=0; i<devices.size(); i++) {
      if (currentDevice == devices.get(i)) {
        return i;
      }
    }
    return -1;
  }

  void assignButtonFunction(int buttonNum, ButtonFunction func) {
    buttons[buttonNum].setFunction(func);
  }
}
