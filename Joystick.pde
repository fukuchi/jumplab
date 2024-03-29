import net.java.games.input.*;
import org.gamecontrolplus.*;
import java.util.Map.Entry;

class Joystick {
  static final String joystickConfigVersion = "1.2";
  static final int MaxButtonNum = 12; // 12 would be enough for the most joysticks
  ArrayList<ControlDevice> devices;
  ControlDevice currentDevice;
  ControlSlider slider_x;
  JoyButton[] buttons;
  int prevAxisX = 0;
  boolean[] prevButtonPressed;
  boolean[] buttonPressed;
  static final float stickMargin = 0.2;
  String configFilename;
  HashMap<String, ButtonFunction[]> buttonAssignmentsMap;

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
  }

  Joystick(PApplet parent, String configFilename) {
    buttons = new JoyButton[MaxButtonNum];
    prevButtonPressed = new boolean[ButtonFunction.size];
    buttonPressed = new boolean[ButtonFunction.size];
    devices = new ArrayList<ControlDevice>();

    ControlIO ctrlio = ControlIO.getInstance(parent);
    for (ControlDevice dev : ctrlio.getDevices()) {
      if ((dev.getTypeID() & (GCP.STICK | GCP.GAMEPAD)) != 0) {
        devices.add(dev);
      }
    }
    this.configFilename = configFilename;
    loadConfig();
  }

  boolean loadConfig() {
    JSONObject configJson;
    buttonAssignmentsMap = new HashMap<String, ButtonFunction[]>();

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

    loadJoystickConfigs(configJson);

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

  void loadJoystickConfigs(JSONObject jsonObject) {
    JSONArray configsJson = jsonObject.getJSONArray("configs");
    if (configsJson == null) return;

    for (int i=0; i<configsJson.size(); i++) {
      JSONObject configJson = configsJson.getJSONObject(i);
      JSONArray buttonAssignmentsJson = configJson.getJSONArray("buttons");
      ArrayList<ButtonFunction> assignments = new ArrayList<ButtonFunction>();
      for (int j=0; j<buttonAssignmentsJson.size(); j++) {
        try {
          assignments.add(ButtonFunction.valueOf(buttonAssignmentsJson.getString(j)));
        }
        catch (IllegalArgumentException e) {
          System.err.println("Warning: unsupported button function was found ('" + buttonAssignmentsJson.getString(j) + "')");
        }
      }
      buttonAssignmentsMap.put(configJson.getString("name"), assignments.toArray(new ButtonFunction[0]));
    }
  }

  void saveConfig() {
    JSONObject configJson = new JSONObject();
    configJson.setString("lastSelected", currentDevice.getName());
    configJson.setString("version", joystickConfigVersion);
    JSONArray buttonAssignmentsJson = dumpButtonAssignmentsToJson();
    configJson.setJSONArray("configs", buttonAssignmentsJson);
    saveJSONObject(configJson, "data/" + configFilename);
  }

  JSONArray dumpButtonAssignmentsToJson() {
    JSONArray configsJson = new JSONArray();
    for (Entry<String, ButtonFunction[]> entry : buttonAssignmentsMap.entrySet()) {
      JSONObject configJson = new JSONObject();
      JSONArray buttonAssignmentsJson = new JSONArray();
      ButtonFunction[] functions = entry.getValue();
      for (ButtonFunction function : functions) {
        buttonAssignmentsJson.append(function.toString());
      }
      configJson.setString("name", entry.getKey());
      configJson.setJSONArray("buttons", buttonAssignmentsJson);
      configsJson.append(configJson);
    }
    return configsJson;
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

  void updateDuringPause() {
    if (currentDevice == null) return;
    currentDevice.update();
    buttonsUpdateWhilePausing();
  }

  void axesUpdate(int[] res) {
    if (gPause && !gStepForward) return;
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
      } else if (prevAxisX > 0) {
        res[1] = -1;
      }
      if (axisX < 0) {
        res[0] = 1;
      } else if (axisX > 0) {
        res[1] = 1;
      }
    }
    prevAxisX = axisX;
  }

  void buttonsUpdate(int[] res) {
    if (gPause && !gStepForward) {
      buttonsUpdateWhilePausing();
      return;
    }

    for (int i=0; i<ButtonFunction.size; i++) {
      prevButtonPressed[i] = buttonPressed[i];
      buttonPressed[i] = false;
    }
    for (int i=0; i<buttons.length; i++) {
      if (buttons[i] != null) {
        ButtonFunction func = buttons[i].buttonFunction;
        if (func != ButtonFunction.NONE) {
          if (buttons[i].getValue() > 0) {
            buttonPressed[func.ordinal()] |= true;
          }
        }
      }
    }
    for (int i=ButtonFunction.JUMP.ordinal(); i<=ButtonFunction.DASH.ordinal(); i++) {
      int s;
      if (prevButtonPressed[i]) {
        s = buttonPressed[i]?0:-1;
      } else {
        s = buttonPressed[i]?1:0;
      }
      res[i - ButtonFunction.JUMP.ordinal() + 2] = s;
    }
    for (int i=ButtonFunction.TOGGLE_TRAIL.ordinal(); i<ButtonFunction.size; i++) {
      if (buttonPressed[i] && !prevButtonPressed[i]) {
        gConsole.buttonFunctionActivated(ButtonFunction.getEnumByOrdinal(i));
      }
    }
  }

  void buttonsUpdateWhilePausing() {
    for (int i=0; i<ButtonFunction.size; i++) {
      if (ButtonFunction.isEnabledWhilePausing(i)) {
        prevButtonPressed[i] = buttonPressed[i];
        buttonPressed[i] = false;
      }
    }
    for (int i=0; i<buttons.length; i++) {
      if (buttons[i] != null) {
        ButtonFunction func = buttons[i].buttonFunction;
        if (func.isEnabledWhilePausing()) {
          if (buttons[i].getValue() > 0) {
            buttonPressed[func.ordinal()] |= true;
          }
        }
      }
    }
    for (int i=ButtonFunction.TOGGLE_TRAIL.ordinal(); i<ButtonFunction.size; i++) {
      if (ButtonFunction.isEnabledWhilePausing(i) && buttonPressed[i] && !prevButtonPressed[i]) {
        gConsole.buttonFunctionActivated(ButtonFunction.getEnumByOrdinal(i));
      }
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
    Arrays.fill(buttons, null);
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
    int buttonsNum = min(MaxButtonNum, currentDevice.getNumberOfButtons());
    for (int i=0; i<buttonsNum; i++) {
      buttons[i] = new JoyButton(currentDevice.getButton(i));
    }
    restoreConfig(currentDevice);

    return currentDevice;
  }

  void restoreConfig(ControlDevice device) {
    ButtonFunction[] buttonAssignments = buttonAssignmentsMap.get(device.getName());
    if (buttonAssignments == null) {
      int num = min(MaxButtonNum, device.getNumberOfButtons());
      buttonAssignments = new ButtonFunction[num];
      for (int i=0; i<num; i++) {
        if (i < 4) {
          buttons[i].buttonFunction = ButtonFunction.JUMP;
          buttonAssignments[i] = ButtonFunction.JUMP;
        } else {
          buttons[i].buttonFunction = ButtonFunction.NONE;
          buttonAssignments[i] = ButtonFunction.NONE;
        }
      }
      buttonAssignmentsMap.put(device.getName(), buttonAssignments);
    } else {
      int num = min(MaxButtonNum, device.getNumberOfButtons(), buttonAssignments.length);
      for (int i=0; i<num; i++) {
        buttons[i].buttonFunction = buttonAssignments[i];
      }
    }
  }

  int getCurrentDeviceIndex() {
    return devices.indexOf(currentDevice);
  }

  void assignButtonFunction(int buttonNum, ButtonFunction func) {
    if (buttons[buttonNum] != null) {
      buttons[buttonNum].buttonFunction = func;
    }
    ButtonFunction[] buttonAssignments = buttonAssignmentsMap.get(currentDevice.getName());
    if (buttonNum < buttonAssignments.length) {
      buttonAssignments[buttonNum] = func;
    }
  }
}
