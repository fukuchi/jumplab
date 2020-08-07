class ChartCanvas extends Canvas {
  int x, y;
  PGraphics pg;
  HashMap<String, float[]> serieses;
  ArrayList<String> keyList;
  Settings settings;

  ChartCanvas(Settings settings, int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.settings = settings;
    pg = createGraphics(w, h);
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    serieses = new HashMap<String, float[]>();
    keyList = new ArrayList<String>();
  }

  void setup(PGraphics destPg) {
  }

  void update(PApplet destPg) {
  }

  void draw(PGraphics destPg) {
    int seriesNum = serieses.size();

    destPg.pushMatrix();
    destPg.pushStyle();
    destPg.translate(x, y);
    destPg.image(pg, 0, 0);
    destPg.translate(0, pg.height + 10);
    destPg.colorMode(HSB, 360, 100, 100);
    destPg.textSize(10);
    destPg.textAlign(LEFT, CENTER);
    for (int i=0; i<seriesNum; i++) {
      destPg.fill(0, 0, 100);
      String label = keyList.get(i);
      destPg.text(label, 200, i * 20);
      destPg.fill(360 * i / seriesNum, 100, 100);
      destPg.noStroke();
      destPg.rect(150, i * 20 - 1, 40, 3);
    }
    destPg.popStyle();
    destPg.popMatrix();
  }

  void addSeries(String label) {
    float[] series = new float[3];
    serieses.put(label, series);
    keyList.add(label);
  }

  void updateSeries(String label, float value) {
    float[] series = serieses.get(label);
    if (series == null) return;

    series[2] = series[1];
    series[1] = series[0];
    series[0] = value;
  }

  void showVelocityChartChanged() {
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
  }

  void updateChart() {
    int seriesNum = serieses.size();
    pg.beginDraw();
    pg.pushStyle();
    pg.copy(1, 0, pg.width - 1, pg.height, 0, 0, pg.width - 1, pg.height);
    pg.colorMode(RGB, 255);
    pg.fill(255);
    pg.noStroke();
    pg.rect(pg.width - 1, 0, 1, pg.height);
    pg.colorMode(HSB, 360, 100, 100);
    if (!settings.showVelocityChart) {
      for (int i=0; i<seriesNum; i++) {
        pg.stroke(360 * i / seriesNum, 100, 100);
        String label = keyList.get(i);
        float[] series = serieses.get(label);
        pg.line(pg.width - 2, (pg.height - 1) * (1 - series[1]), pg.width - 1, (pg.height - 1) * (1 - series[0]));
      }
    } else {
      float pg_hh = pg.height / 2;
      pg.stroke(0, 0, 0);
      pg.line(pg.width - 2, pg_hh, pg.width - 1, pg_hh);
      for (int i=0; i<seriesNum; i++) {
        pg.stroke(360 * i / seriesNum, 100, 100);
        String label = keyList.get(i);
        float[] series = serieses.get(label);
        float d1 = pg_hh - (series[1] - series[2]) * 10 * (pg.height - 1);
        float d2 = pg_hh - (series[0] - series[1]) * 10 * (pg.height - 1);
        pg.line(pg.width - 2, d1, pg.width - 1, d2);
      }
    }
    pg.popStyle();
    pg.endDraw();
  }
}
