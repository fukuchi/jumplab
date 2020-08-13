import java.util.LinkedHashMap;

enum ButtonFunction {
  NONE("None"), JUMP("Jump"), TOGGLE_TRAIL("Toggle show Trail"), TOGGLE_CAMERA("Toggle show Camera Marker");

  private final String label;

  private ButtonFunction(final String label) {
    this.label = label;
  }

  String getLabel() {
    return label;
  }

  private static final List<String> labels;
  private static final Map<String, Object> valuesMap;
  static {
    labels = new ArrayList<String>();
    valuesMap = new LinkedHashMap<String, Object>();
    for (ButtonFunction func : ButtonFunction.values()) {
      labels.add(func.getLabel());
      valuesMap.put(func.getLabel(), func);
    }
  }

  static List<String> getLabels() {
    return labels;
  }

  static Map<String, Object> getValuesMap() {
    return valuesMap;
  }

  private static final int size = ButtonFunction.values().length;
}
