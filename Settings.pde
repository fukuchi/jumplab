import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;
import java.util.Collections;
import java.util.Comparator;

class Settings {
  float maxVx = 8; // Maximum horizontal velocity of the jumper.
  float maxVy = 30; // Maximum vertical velocity of the jumper. Limits only the falling motion.
  float jumpPower = 13; // Initial vertical velocity of a jump motion.
  float gravity = 0.5; // gravity when rising.
  float gravityFalling = 1.2; // gravity when falling.
  float axNormal = 0.2; // Horizontal acceleration in normal state.
  float axBrake = 1.0; // Horizontal acceleration when braking.
  float axJumping = 0.1; // Horizontal acceleration when jumping.
  float camEasingNormal = 0.1; // Smoothness of the camera motion in normal state.
  float camEasingGrounding = 0.3; // Smoothness of the camera motion when the jumper grounded.
  float jumpAnticipationFrames = 2; // Duration of the anticipation of jump motion in frames.
  float maxPropellingFrames = 30; // Maximum duration of propelled jump.
  float brakingAtTakeoff = 0.0; // Horizontal braking power at the takeoff.
  float verticalSpeedSustainLevel = 1.0; // Sustain level of the vertical speed when the button released.
  float collisionTolerance = 8; // Tolerance to automatically avoid blocks when jumping (in pixels).
  boolean showTrail = false; // Show the trail or not.
  boolean camVerticalEasing = true; // Ease the vertical camera motion or not.
  boolean parallaxScrolling = true; // Parallax scrolling or not.
  boolean showCenterMarker = false; // Show the center marker or not.
  boolean allowAerialJump = true; // Allow aerial jump or not.
  boolean allowAerialWalk = true; // Allow aerial walk or not.
  boolean constantRising = false; // Keep constant vertical velocity when rising.
  boolean haltedAndFall = false; // The horizontal motion is halted when the jumper goes off the foothold.

  ArrayList<String> booleanValues;
  ArrayList<String> floatValues;
  String[] allValues;

  String[] ignoredVariables = {"showTrail", "showCenterMarker", "camVerticalEasing", "parallaxScrolling"};

  HashMap<String, HashMap<String, Object>> presetStyles;

  String userSettingsFilename = "usersettings.json";
  String defaultSettingsFilename = "default.json";

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
    ArrayList<String> allValuesList = new ArrayList<String>();
    allValuesList.addAll(booleanValues);
    allValuesList.addAll(floatValues);
    allValues = allValuesList.toArray(new String[booleanValues.size() + floatValues.size()]);
  }

  void setPreset(String name) {
    HashMap<String, Object> preset = presetStyles.get(name);
    if (preset == null) {
      println("Preset '" + name + "' not found.");
      return;
    }
    for (String key : preset.keySet()) {
      try {
        Field variable = this.getClass().getDeclaredField(key);
        Object value = preset.get(key);
        variable.set(this, value);
      }
      catch (ReflectiveOperationException e) {
        System.err.println("Failed to get " + name + ".");
      }
    }
  }

  void load() {
    JSONArray stylesJson = null;

    presetStyles = new HashMap<String, HashMap<String, Object>>();

    /* Processing 3.5.4 does not return null if the file is not found
     and throws NullPointerException. As a workaround, we check the
     file exists or not before open the file. */
    BufferedReader reader;
    reader = createReader(userSettingsFilename);
    if (reader == null) {
      reader = createReader(defaultSettingsFilename);
      println("loading '" + defaultSettingsFilename + "'...");
    }
    if (reader != null) {
      stylesJson = new JSONArray(reader);
    }
    if (stylesJson == null) {
      System.err.println("Failed to load default presets.");
      return;
    }

    for (int i=0; i<stylesJson.size(); i++) {
      JSONObject styleJson = stylesJson.getJSONObject(i);
      String name = styleJson.getString("name");
      JSONObject data = styleJson.getJSONObject("data");
      HashMap<String, Object> presetMap = new HashMap<String, Object>();
      presetStyles.put(name, presetMap);
      for (Object key : data.keys()) {
        String variableName = (String)key;
        try {
          Field variable = this.getClass().getDeclaredField(variableName);
          Class variableType = variable.getType();
          if (variableType == Boolean.TYPE) {
            presetMap.put(variableName, data.getBoolean(variableName));
          } else if (variableType == Float.TYPE) {
            presetMap.put(variableName, data.getFloat(variableName));
          }
        }
        catch (ReflectiveOperationException e) {
          System.err.println("Failed to get " + name + ".");
        }
      }
    }
  }

  void updateCurrentPreset(String styleName) {
    HashMap<String, Object> presetMap = presetStyles.get(styleName);
    if (presetMap == null) {
      presetMap = new HashMap<String, Object>();
    }
    List<String> ignoredVariablesList = Arrays.asList(ignoredVariables);
    for (String name : allValues) {
      if (ignoredVariablesList.contains(name)) continue;
      try {
        Field variable = this.getClass().getDeclaredField(name);
        Class variableType = variable.getType();
        if (variableType == Boolean.TYPE) {
          presetMap.put(name, variable.getBoolean(this));
        } else if (variableType == Float.TYPE) {
          presetMap.put(name, variable.getFloat(this));
        }
      }
      catch (ReflectiveOperationException e) {
        System.err.println("Failed to get " + name + ".");
      }
    }
    presetStyles.put(styleName, presetMap);
  }

  void save(String styleName) {
    println("Saving " + styleName);
    updateCurrentPreset(styleName);

    List<String> keys = presetStylesKeys();
    JSONArray stylesJson = new JSONArray();
    int idx = 0;

    for (String name : keys) {
      JSONObject data = new JSONObject();
      HashMap<String, Object> presetMap = presetStyles.get(name);
      JSONObject styleJson = new JSONObject();
      for (String presetKey : presetMap.keySet()) {
        Object value = presetMap.get(presetKey);
        if (value instanceof Boolean) {
          data.setBoolean(presetKey, (Boolean)value);
        } else if (value instanceof Float) {
          data.setFloat(presetKey, (Float)value);
        }
      }
      styleJson.setString("name", name);
      styleJson.setJSONObject("data", data);
      stylesJson.setJSONObject(idx++, styleJson);
    }
    saveJSONArray(stylesJson, "data/" + userSettingsFilename);
  }

  List<String> presetStylesKeys() {
    ArrayList<String> keys = new ArrayList<String>(presetStyles.keySet());
    Collections.sort(keys, new Comparator<String>() {
      @Override public int compare(String s1, String s2) {
        int res = s1.compareToIgnoreCase(s2);
        return (res != 0)? res : s1.compareTo(s2);
      }
    }
    );
    return keys;
  }
}
