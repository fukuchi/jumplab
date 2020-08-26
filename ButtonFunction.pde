import java.util.LinkedHashMap;

enum ButtonFunction {
  NONE("None"), JUMP("Jump"), DASH("Dash"), TOGGLE_TRAIL("Toggle show Trail"), TOGGLE_CAMERA("Toggle show Camera Marker"), 
    NEXT_STYLE("Next style"), PREV_STYLE("Previous style"), PAUSE("Pause"), STEP_FORWARD("Step forward");

  private final String label;

  private ButtonFunction(final String label) {
    this.label = label;
  }

  String getLabel() {
    return label;
  }

  private static final Map<String, Object> valuesMap;
  private static final ButtonFunction[] reverseLookupTable;
  private static final boolean[] enabledWhilePausing;
  private static final int size = ButtonFunction.values().length;
  static {
    valuesMap = new LinkedHashMap<String, Object>();
    for (ButtonFunction func : ButtonFunction.values()) {
      valuesMap.put(func.getLabel(), func);
    }
    reverseLookupTable = ButtonFunction.values();
    enabledWhilePausing = new boolean[size];
    enabledWhilePausing[PAUSE.ordinal()] = true;
    enabledWhilePausing[STEP_FORWARD.ordinal()] = true;
  }

  static Map<String, Object> getValuesMap() {
    return valuesMap;
  }

  static ButtonFunction getEnumByOrdinal(int o) {
    return reverseLookupTable[o];
  }

  boolean isEnabledWhilePausing() {
    return enabledWhilePausing[ordinal()];
  }

  static boolean isEnabledWhilePausing(int o) {
    return enabledWhilePausing[o];
  }
}
