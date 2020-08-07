class ChartCanvas extends Canvas {
  int x, y;
  PGraphics pg;
  HashMap<String, float[]> serieses;
  ArrayList<String> keyList;

  ChartCanvas(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
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
    float[] series = new float[2];
    serieses.put(label, series);
    keyList.add(label);
  }

  void updateSeries(String label, float value) {
    float[] series = serieses.get(label);
    if (series == null) return;

    series[1] = series[0];
    series[0] = value;
  }

  void updateChart() {
    int seriesNum = serieses.size();
    pg.beginDraw();
    pg.copy(1, 0, pg.width - 1, pg.height, 0, 0, pg.width - 1, pg.height);
    pg.colorMode(RGB, 255);
    pg.fill(255);
    pg.noStroke();
    pg.rect(pg.width - 1, 0, 1, pg.height);
    pg.colorMode(HSB, 360, 100, 100);
    for (int i=0; i<seriesNum; i++) {
      pg.stroke(360 * i / seriesNum, 100, 100);
      String label = keyList.get(i);
      float[] series = serieses.get(label);
      pg.line(pg.width - 2, (pg.height - 1) * (1 - series[1]), pg.width - 1, (pg.height - 1) * (1 - series[0]));
    }
    pg.endDraw();
  }
}
