import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

static class Settings {
  static final float MaxVx = 8; // Maximum horizontal velocity of the jumper.
  static final float MaxVy = 30; // Maximum vertical velocity of the jumper. Limits only the falling motion.
  static final float JumpPower = 13; // Initial vertical velocity of a jump motion.
  static final float Gravity = 0.5; // gravity when rising.
  static final float GravityFalling = 1.2; // gravity when falling.
  static final float AxNormal = 0.2; // Horizontal acceleration in normal state.
  static final float AxBrake = 1.0; // Horizontal acceleration when braking.
  static final float AxJumping = 0.1; // Horizontal acceleration when jumping.
  static final float CamEasingNormal = 0.1; // Smoothness of the camera motion in normal state.
  static final float CamEasingGrounding = 0.3; // Smoothness of the camera motion when the jumper grounded.
  static final float JumpAnticipationFrames = 2; // Duration of the anticipation of jump motion in frames.
  static final float MaxPropellingFrames = 60; // Maximum duration of propelled jump.
  static final float BrakingAtTakeoff = 0.0; // Horizontal braking power at the takeoff.
  static final boolean ShowTrail = false; // Show the trail or not.
  static final boolean CamVerticalEasing = true; // Ease the vertical camera motion or not.
  static final boolean ParallaxScrolling = true; // Parallax scrolling or not.
  static final boolean ShowCenterMarker = false; // Show the center marker or not.
  static final boolean AllowAerialJump = true; // Allow aerial jump or not.
  static final boolean AllowAerialWalk = true; // Allow aerial walk or not.
  static final boolean ConstantRising = false; // Keep constant vertical velocity when rising.

  float maxVx, maxVy;
  float jumpPower;
  float gravity;
  float gravityFalling;
  float axNormal;
  float axBrake;
  float axJumping;
  float camEasingNormal;
  float camEasingGrounding;
  float jumpAnticipationFrames;
  float maxPropellingFrames;
  float brakingAtTakeoff;
  boolean showTrail;
  boolean camVerticalEasing;
  boolean parallaxScrolling;
  boolean showCenterMarker;
  boolean allowAerialJump;
  boolean allowAerialWalk;
  boolean constantRising;

  ArrayList<String> booleanValues;
  ArrayList<String> floatValues;

  Settings() {
    booleanValues = new ArrayList<String>();
    floatValues = new ArrayList<String>();
    Field[] allVariables = this.getClass().getDeclaredFields();
    for (Field f : allVariables) {
      if (!Modifier.isStatic(f.getModifiers())) {
        if (f.getType() == Boolean.TYPE) {
          booleanValues.add(f.getName());
        } else if (f.getType() == Float.TYPE) {
          floatValues.add(f.getName());
        }
      }
    }
    resetSettings();
  }

  void resetSettings() {
    ArrayList<String> allValues = new ArrayList<String>();
    allValues.addAll(booleanValues);
    allValues.addAll(floatValues);
    for (String name : allValues) {
      String staticName = name.substring(0, 1).toUpperCase() + name.substring(1);
      try {
        Field variable = this.getClass().getDeclaredField(name);
        Field staticVariable = this.getClass().getDeclaredField(staticName);
        variable.set(this, staticVariable.get(this));
      }         
      catch (ReflectiveOperationException e) {
        println("Failed to get " + name + ".");
      }
    }
  }
}
