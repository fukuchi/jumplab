import java.util.Set;

class Preset {
  private String name;
  private boolean modifiable;
  private HashMap<String, Object> data;

  Preset(JSONObject json) {
    name = json.getString("name");
    modifiable = json.getBoolean("modifiable", true);
    data = new HashMap<String, Object>();

    JSONObject jsonData = json.getJSONObject("data");
    for (Object key : jsonData.keys()) {
      String variableName = (String)key;
      if (Settings.booleanValues.contains(variableName)) {
        data.put(variableName, jsonData.getBoolean(variableName));
      } else if (Settings.floatValues.contains(variableName)) {
        data.put(variableName, jsonData.getFloat(variableName));
      }
    }
  }

  Preset(String name) {
    this.name = name;
    modifiable = true;
  }
  
  String getName() {
    return name;
  }
  
  boolean isModifiable() {
    return modifiable;
  }
  
  Set<String> keySet() {
    return data.keySet();
  }
  
  Object get(String key) {
    return data.get(key);
  }

  boolean update(Settings settings) {
    if (modifiable) {
      data = settings.toHashMap();
      return true;
    }
    return false;
  }

  JSONObject toJson() {
    JSONObject json = new JSONObject();
    json.setString("name", name);
    json.setBoolean("modifiable", modifiable);

    JSONObject jsonData = new JSONObject();
    for (String key : data.keySet()) {
      jsonData.put(key, data.get(key));
    }
    json.setJSONObject("data", jsonData);

    return json;
  }
}
