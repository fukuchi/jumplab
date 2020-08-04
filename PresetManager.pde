import java.util.Collections;
import java.util.Comparator;

class PresetManager {
  HashMap <String, Preset> presets;

  PresetManager() {
    presets = new HashMap<String, Preset>();
  }

  boolean load(String filename) {
    JSONArray presetsJson;

    /* Processing 3.5.4 does not return null if the file is not found
     and throws NullPointerException. As a workaround, we check the
     file exists or not before open the file. */
    BufferedReader reader;
    reader = createReader(filename);
    if (reader == null) {
      return false;
    }
    println("loading '" + filename + "'...");

    try {
      presetsJson = new JSONArray(reader);
      reader.close();
    }
    catch (IOException e) {
      e.printStackTrace();
      return false;
    } 
    catch (RuntimeException e) {
      System.err.println("Failed to load '" + filename + "'.");
      e.printStackTrace();
      return false;
    }

    for (int i=0; i<presetsJson.size(); i++) {
      JSONObject presetJson = presetsJson.getJSONObject(i);
      Preset preset = new Preset(presetJson);
      presets.put(preset.name, preset);
    }

    return true;
  }

  Preset get(String name) {
    return presets.get(name);
  }

  boolean upsert(String name, Settings settings) {
    Preset preset = get(name);
    if (preset == null) {
      preset = new Preset(name);
      presets.put(name, preset);
    }
    return preset.update(settings);
  }

  void save(String filename) {
    JSONArray presetsJson = new JSONArray();
    for (String key : presets.keySet()) {
      presetsJson.append(presets.get(key).toJson());
    }
    saveJSONArray(presetsJson, "data/" + filename);
  }

  List<String> keyList() {
    ArrayList<String> keys = new ArrayList<String>(presets.keySet());
    Collections.sort(keys, new Comparator<String>() {
      @Override public int compare(String s1, String s2) {
        int res = s1.compareToIgnoreCase(s2);
        return (res != 0)? res : s1.compareTo(s2);
      }
    }
    );
    return keys;
  }

  boolean isModifiable(String name) {
    Preset preset = presets.get(name);
    if (preset != null) {
      return preset.isModifiable();
    }
    return true;
  }
}
