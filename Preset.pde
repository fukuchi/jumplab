import java.util.Set;
import java.time.OffsetDateTime;

class Preset {
  private String name;
  private boolean modifiable;
  private HashMap<String, Object> data;
  private OffsetDateTime lastModified;

  Preset(JSONObject json) {
    name = json.getString("name");
    modifiable = json.getBoolean("modifiable", true);
    String lastModifiedStr = json.getString("last modified", "2020-08-01T00:00:00.000+09:00");
    lastModified = OffsetDateTime.parse(lastModifiedStr);
    data = new HashMap<String, Object>();

    JSONObject jsonData = json.getJSONObject("data");
    for (Object key : jsonData.keys()) {
      String variableName = (String)key;
      if (Settings.booleanVariables.contains(variableName)) {
        data.put(variableName, jsonData.getBoolean(variableName));
      } else if (Settings.floatVariables.contains(variableName)) {
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

  void updateLastModified() {
    lastModified = OffsetDateTime.now();
  }

  boolean update(Settings settings) {
    if (modifiable) {
      data = settings.toHashMap();
      updateLastModified();
      return true;
    }
    return false;
  }

  JSONObject toJson() {
    JSONObject json = new JSONObject();
    json.setString("name", name);
    json.setBoolean("modifiable", modifiable);
    json.setString("last modified", lastModified.toString());

    JSONObject jsonData = new JSONObject();
    for (String key : data.keySet()) {
      jsonData.put(key, data.get(key));
    }
    json.setJSONObject("data", jsonData);

    return json;
  }
}
