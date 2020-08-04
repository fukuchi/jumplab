import net.java.games.input.*;
import org.gamecontrolplus.*;

class Joystick {
  ControlIO ctrlio;
  List<ControlDevice> devices;
  ControlDevice currentDevice;
  ControlSlider slider_x;
  ControlButton[] buttons;
  int prevAxisX = 0;
  boolean prevButtonPressed = false;
  static final float stickMargin = 0.2;

  Joystick(PApplet parent) {
    ctrlio = ControlIO.getInstance(parent);
    devices = new ArrayList<ControlDevice>();
    for (ControlDevice dev : ctrlio.getDevices()) {
      int controllerType = dev.getTypeID();
      if ((controllerType & (GCP.STICK | GCP.GAMEPAD)) == 0) continue;
      devices.add(dev);
    }

    buttons = new ControlButton[4];
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
    int axisX = 0;

    if (currentDevice == null) return;
    currentDevice.update();

    float axisXRawValue = slider_x.getValue();
    boolean buttonPressed = false;
    for (int i=0; i<buttons.length; i++) {
      if (buttons[i] != null) {
        if (buttons[i].getValue() > 0) buttonPressed |= true;
      }
    }
    if (axisXRawValue < -stickMargin) {
      axisX = -1;
    } else if (axisXRawValue > stickMargin) {
      axisX = 1;
    }
    res[0] = (prevAxisX == axisX)?0:1;
    res[1] = axisX;
    if (prevButtonPressed) {
      res[2] = buttonPressed?0:-1;
    } else {
      res[2] = buttonPressed?1:0;
    }
    prevButtonPressed = buttonPressed;
    prevAxisX = axisX;
  }

  ControlDevice selectDevice(int idx) {
    if (currentDevice != null) {
      currentDevice.close();
    }
    slider_x = null;
    for (int i=0; i<buttons.length; i++) {
      buttons[i] = null;
    }
    currentDevice = devices.get(idx);
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
      buttons[i] = currentDevice.getButton(i);
    }

    return currentDevice;
  }
}
