import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

class Settings {
  static final float MaxVx = 8; //X方向の最大速度
  static final float MaxVy = 30;
  static final float JumpPower = 13; //ジャンプ時の初速度(Y軸)
  static final float Gravity = 0.5; //重力
  static final float GravityFalling = 1.2; //重力(落下時)
  static final float AxNormal = 0.2; //X方向加速度
  static final float AxBreak = 1.0; //ブレーキ時加速度
  static final float AxJumping = 0.1; //ジャンプ中のX方向加速度
  static final float CamEasingNormal = 0.1;
  static final float CamEasingGrounding = 0.3;
  static final float JumpAnticipationFrames = 3;
  static final boolean ShowTrail = false;
  static final boolean CamVerticalEasing = true;
  static final boolean ParallaxScrolling = true;
  static final boolean ShowCenterMarker = false;
  static final boolean AllowAerialJump = true;
  static final boolean AllowAerialWalk = true;

  float maxVx, maxVy;
  float jumpPower;
  float gravity;
  float gravityFalling;
  float axNormal;
  float axBreak;
  float axJumping;
  float camEasingNormal;
  float camEasingGrounding;
  float jumpAnticipationFrames;
  boolean showTrail;
  boolean camVerticalEasing;
  boolean parallaxScrolling;
  boolean showCenterMarker;
  boolean allowAerialJump;
  boolean allowAerialWalk;

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
