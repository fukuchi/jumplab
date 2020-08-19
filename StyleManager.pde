import java.util.Collections;
import java.util.Comparator;

class StyleManager {
  HashMap <String, Style> styles;

  StyleManager() {
    styles = new HashMap<String, Style>();
  }

  boolean load(String filename) {
    JSONArray stylesJson;

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
      stylesJson = new JSONArray(reader);
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

    for (int i=0; i<stylesJson.size(); i++) {
      JSONObject styleJson = stylesJson.getJSONObject(i);
      Style style = new Style(styleJson);
      styles.put(style.name, style);
    }

    return true;
  }

  Style get(String name) {
    return styles.get(name);
  }

  boolean upsert(String name, Settings settings) {
    Style style = get(name);
    if (style == null) {
      style = new Style(name);
      styles.put(name, style);
    }
    return style.update(settings);
  }

  void save(String filename) {
    JSONArray stylesJson = new JSONArray();
    for (Style style : styles.values()) {
      stylesJson.append(style.toJson());
    }
    saveJSONArray(stylesJson, "data/" + filename);
  }

  List<String> keyList() {
    ArrayList<String> keys = new ArrayList<String>(styles.keySet());
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
    Style style = styles.get(name);
    if (style != null) {
      return style.isModifiable();
    }
    return true;
  }
}
