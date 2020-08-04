import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;

static class Settings {
  // Jump parameters
  boolean showTrail = false; // Show the trail or not.
  boolean allowAerialJump = true; // Allow aerial jump or not.
  boolean allowAerialWalk = true; // Allow aerial walk or not.
  boolean constantRising = false; // Keep constant vertical velocity when rising.
  boolean haltedAndFall = false; // The horizontal motion is halted when the jumper goes off the foothold.
  float maxVx = 8; // Maximum horizontal velocity of the jumper.
  float maxVy = 30; // Maximum vertical velocity of the jumper. Limits only the falling motion.
  float jumpPower = 13; // Initial vertical velocity of a jump motion.
  float jumpPowerBonus = 0;// The faster run gives an initial jump velocity bonus that allows a higher jump.
  float jumpAnticipationFrames = 2; // Duration of the anticipation of jump motion in frames.
  float vxAdjustmentAtTakeoff = 0.0; // Horizontal velocity adjustment at the takeoff.
  float maxPropellingFrames = 30; // Maximum duration of propelled jump.
  float gravity = 0.5; // gravity when rising.
  float gravityFalling = 1.2; // gravity when falling.
  float verticalSpeedSustainLevel = 1.0; // Sustain level of the vertical speed when the button released.
  float axNormal = 0.2; // Horizontal acceleration in normal state.
  float axBrake = 1.0; // Horizontal acceleration when braking.
  float axJumping = 0.1; // Horizontal acceleration when jumping.
  float collisionTolerance = 8; // Tolerance to automatically avoid blocks when jumping (in pixels).

  // Camera parameters
  boolean showCameraMarker = false; // Show the center marker or not.
  boolean parallaxScrolling = true; // Parallax scrolling or not.
  boolean cameraEasing_x = false; // Ease the horizon camera motion or not.
  boolean cameraEasing_y = true; // Ease the vertical camera motion or not.
  boolean forwardFocus = false; //  Shift the focus to the front of the jumper to enable wide forward view.
  boolean platformSnapping = false; // Halt the vertical camera motion when the jumper is jumping.
  float cameraEasingNormal_x = 0.1; // Smoothness of the horizontal camera motion in normal state.
  float cameraEasingNormal_y = 0.1; // Smoothness of the vertical camera motion in normal state.
  float cameraEasingGrounding_y = 0.3; // Smoothness of the camera motion when the jumper grounded.
  float cameraWindow_h = 0; // Height of the camera window.
  float cameraWindow_w = 0; // Width of the camera window.
  float focusDistance = 100; // Distance to the focal point.
  float focusingSpeed = 5; // Velocity of the focal point movement.

  static ArrayList<String> booleanVariables;
  static ArrayList<String> floatVariables;
  static List<String> ignoredVariables = Arrays.asList("showTrail", "showCameraMarker");

  static {
    booleanVariables = new ArrayList<String>();
    floatVariables = new ArrayList<String>();
    Field[] allVariables = Settings.class.getDeclaredFields();
    for (Field f : allVariables) {
      if (!Modifier.isStatic(f.getModifiers())) {
        if (f.getType() == Boolean.TYPE) {
          booleanVariables.add(f.getName());
        } else if (f.getType() == Float.TYPE) {
          floatVariables.add(f.getName());
        }
      }
    }
  }

  Settings() {
    // Nothing to do at this momemnt. Just a placeholder.
  }

  void load(Preset preset) {
    for (String key : preset.keySet()) {
      try {
        Field variable = this.getClass().getDeclaredField(key);
        Object value = preset.get(key);
        variable.set(this, value);
      }
      catch (ReflectiveOperationException e) {
        System.err.println("Failed to get " + key + " of " + preset.getName() + ".");
      }
    }
  }

  HashMap<String, Object> toHashMap() {
    HashMap<String, Object> map = new HashMap<String, Object>();
    for (String variableName : booleanVariables) {
      if (ignoredVariables.contains(variableName)) continue;
      try {
        Field variable = this.getClass().getDeclaredField(variableName);
        map.put(variableName, variable.getBoolean(this));
      }
      catch (ReflectiveOperationException e) {
        System.err.println("Failed to get " + variableName + " from the current settings.");
      }
    }
    for (String variableName : floatVariables) {
      if (ignoredVariables.contains(variableName)) continue;
      try {
        Field variable = this.getClass().getDeclaredField(variableName);
        map.put(variableName, variable.getFloat(this));
      }
      catch (ReflectiveOperationException e) {
        System.err.println("Failed to get " + variableName + " from the current settings.");
      }
    }
    return map;
  }
}
