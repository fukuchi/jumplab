class ChartCanvas extends Canvas {
  int x, y;
  PGraphics pg;
  ArrayList<Series> serieses;
  int seriesesNum;
  Settings settings;

  class Series {
    String label;
    float[] data;

    Series(String label) {
      this.label = label;
      data = new float[3];
    }
  }

  ChartCanvas(Settings settings, int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.settings = settings;
    pg = createGraphics(w, h);
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    serieses = new ArrayList<Series>();
    seriesesNum = 0;
  }

  void draw(PGraphics destPg) {
    destPg.pushMatrix();
    destPg.pushStyle();
    destPg.translate(x, y);
    destPg.image(pg, 0, 0);
    destPg.translate(0, pg.height + 10);
    destPg.colorMode(HSB, 360, 100, 100);
    destPg.textSize(10);
    destPg.textAlign(LEFT, CENTER);
    for (int i=0; i<seriesesNum; i++) {
      destPg.fill(0, 0, 100);
      destPg.text(serieses.get(i).label, 200, i * 20);
      destPg.fill(360 * i / seriesesNum, 100, 100);
      destPg.noStroke();
      destPg.rect(150, i * 20 - 1, 40, 3);
    }
    destPg.popStyle();
    destPg.popMatrix();
  }

  int addSeries(String label) {
    Series s = new Series(label);
    serieses.add(seriesesNum, s);
    seriesesNum++;
    return seriesesNum - 1;
  }

  void updateSeries(int idx, float value) {
    float[] series = serieses.get(idx).data;
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
    pg.beginDraw();
    pg.pushStyle();
    pg.copy(1, 0, pg.width - 1, pg.height, 0, 0, pg.width - 1, pg.height);
    pg.colorMode(RGB, 255);
    pg.fill(255);
    pg.noStroke();
    pg.rect(pg.width - 1, 0, 1, pg.height);
    pg.colorMode(HSB, 360, 100, 100);
    if (!settings.showVelocityChart) {
      for (int i=0; i<seriesesNum; i++) {
        pg.stroke(360 * i / seriesesNum, 100, 100);
        float[] series = serieses.get(i).data;
        pg.line(pg.width - 2, (pg.height - 1) * (1 - series[1]), pg.width - 1, (pg.height - 1) * (1 - series[0]));
      }
    } else {
      float pg_hh = pg.height / 2;
      pg.stroke(0, 0, 75);
      pg.line(pg.width - 2, pg_hh, pg.width - 1, pg_hh);
      for (int i=0; i<seriesesNum; i++) {
        pg.stroke(360 * i / seriesesNum, 100, 100);
        float[] series = serieses.get(i).data;
        float d1 = pg_hh - (series[1] - series[2]) * 10 * (pg.height - 1);
        float d2 = pg_hh - (series[0] - series[1]) * 10 * (pg.height - 1);
        pg.line(pg.width - 2, d1, pg.width - 1, d2);
      }
    }
    pg.popStyle();
    pg.endDraw();
  }
}
