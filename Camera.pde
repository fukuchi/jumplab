class Camera {
  Jumper jumper;
  Level level;
  PImage levelImg;
  PVector[] posbuf;
  static final int posbuflen = 64;
  int posbufp = 0;

  float x, y;
  float py;
  int window_w, window_h;
  int window_hw, window_hh;

  Camera(Jumper jumper, Level level, int w, int h) {
    this.jumper = jumper;
    this.level = level;
    window_w = w;
    window_h = h;
    window_hw = w / 2;
    window_hh = h / 2;

    PGraphics levelGfx = createGraphics(level.w, level.h);
    levelGfx.beginDraw();
    levelGfx.background(0, 0);
    for (int y=0; y<level.ch; y++) {
      for (int x=0; x<level.cw; x++) {
        if (level.map[y][x] > 0) {
          levelGfx.image(level.blockImg, x * level.bw, y * level.bh);
        }
      }
    }
    levelGfx.endDraw();
    levelImg = levelGfx.get();

    posbuf = new PVector[posbuflen];
    for (int i=0; i<posbuflen; i++) {
      posbuf[i] = new PVector(0, 0);
    }
  }

  void reset(float x, float y) {
    this.x = constrain(x + Jumper.w / 2, window_hw, level.w - window_hw);
    this.y = constrain(y + Jumper.h / 2, window_hh, level.h - window_hh);
    py = this.y;
  }

  void update() {
    x = constrain(jumper.x + Jumper.w / 2, window_hw, level.w - window_hw);
    if (!settings.camVerticalEasing) {
      py = y;
      y = constrain(jumper.y + Jumper.h / 2, window_hh, level.h - window_hh);
    } else {
      float vy = y - py;
      py = y;
      float ty = jumper.y + Jumper.h / 2;
      if (!jumper.onObstacle) {
        float dist = abs(ty - y);
        vy += Math.signum(ty - y) * dist * settings.camEasingNormal;
        vy = vy * 0.5;
        y += vy;
      } else {
        y += (ty - y) * settings.camEasingGrounding;
      }
      y = constrain(y, window_hh, level.h - window_hh);
    }
  }

  void draw() {
    int bgx, bgy;
    int cx = (int)x - window_hw;
    int cy = (int)y - window_hh;
    if (settings.parallaxScrolling) {
      float rx = (x - window_hw) / (level.w - window_w);
      float ry = (y - window_hh) / (level.h - window_h);
      bgx = (int)(rx * (float)(1536 - window_w));
      bgy = (int)(ry * (float)(704 - window_h)) + 450;
    } else {
      bgx = cx;
      bgy = cy + 150;
    }
    copy(level.bgImg, bgx, bgy, window_w, window_h, 0, 0, window_w, window_h);
    copy(levelImg, cx, cy, window_w, window_h, 0, 0, window_w, window_h);

    posbuf[posbufp].x = jumper.x + Jumper.w / 2;
    posbuf[posbufp].y = jumper.y + Jumper.h / 2;
    posbufp = (posbufp + 1) % posbuflen;
    if (settings.showTrail) {
      noStroke();
      fill(255, 0, 0);
      for (int i=0; i<posbuflen; i++) {
        if (posbuf[i].x - cx < window_w) {
          ellipse(posbuf[i].x - cx, posbuf[i].y - cy, 5, 5);
        }
      }
    }
    jumper.draw(jumper.x - cx, jumper.y - cy);

    if (settings.showCenterMarker) {
      noStroke();
      fill(255, 0, 0);
      rect(window_hw - 5, window_hh - 15, 10, 30);
      rect(window_hw - 15, window_hh - 5, 30, 10);
    }

    noStroke();
    fill(128);
    rect(console.x, console.y, console.w, console.h);
    stroke(255);
    line(console.x, console.y + 166, console.x + console.w, console.y + 166);
  }
}
