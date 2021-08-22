class Camera {
  Jumper jumper;
  Level level;
  Settings settings;
  PImage levelImg;
  PImage titleImg;
  JumperTrail[] trail;
  static final int trailLen = 64;
  int trailHead = 0;
  boolean showTitle = true;
  int titleTimer;

  float x, y;
  float px, py; // previous position
  float focus_x;
  float targetFocus_x;
  int window_w, window_h;
  int window_hw, window_hh;

  PFont onScreenFont;

  class JumperTrail {
    float x, y;
    PImage image;
  }

  Camera(Jumper jumper, Level level, Settings settings, int w, int h) {
    this.jumper = jumper;
    this.level = level;
    this.settings = settings;
    window_w = w;
    window_h = h;
    window_hw = w / 2;
    window_hh = h / 2;

    levelImg = level.createLevelImage();
    titleImg = loadImage("title.png");
    titleTimer = -1;

    trail = new JumperTrail[trailLen];
    for (int i=0; i<trailLen; i++) {
      trail[i] = new JumperTrail();
    }

    onScreenFont = createFont("Lucida Sans", 16);
  }

  void reset(float x, float y) {
    this.x = constrain(x, window_hw, level.w - window_hw);
    this.y = constrain(y, window_hh, level.h - window_hh);
    px = this.x;
    py = this.y;
    focus_x = 0;
  }

  void update() {
    float tx = x; // target position
    float ty = y;

    float dx = jumper.center_x() - x;
    float dy = jumper.center_y() - y;
    if (settings.forwardFocus || settings.projectedFocus) {
      targetFocus_x = 0;
      if (settings.forwardFocus) {
        targetFocus_x += jumper.lastDir * settings.focusDistance;
      }
      if (settings.projectedFocus) {
        targetFocus_x += settings.focusDistance * jumper.vx / settings.maxVx;
      }
      if (jumper.lastDir > 0) {
        if (focus_x < targetFocus_x) {
          float cameraEdge_x = settings.cameraWindow_w / 2 - dx;
          if (focus_x < cameraEdge_x) {
            focus_x = cameraEdge_x;
          }
          focus_x += settings.focusingSpeed;
          if (focus_x > targetFocus_x) {
            focus_x = targetFocus_x;
          }
        } else if (focus_x > targetFocus_x) {
          focus_x -= settings.focusResettingSpeed;
          if (focus_x < targetFocus_x) {
            focus_x = targetFocus_x;
          }
        }
      } else if (jumper.lastDir < 0) {
        if (focus_x > targetFocus_x) {
          float cameraEdge_x = -settings.cameraWindow_w / 2 - dx;
          if (focus_x > cameraEdge_x) {
            focus_x = cameraEdge_x;
          }
          focus_x -= settings.focusingSpeed;
          if (focus_x < targetFocus_x) {
            focus_x = targetFocus_x;
          }
        } else if (focus_x < targetFocus_x) {
          focus_x += settings.focusResettingSpeed;
          if (focus_x > targetFocus_x) {
            focus_x = targetFocus_x;
          }
        }
      }
      dx += focus_x;
    }
    if (dx < -settings.cameraWindow_w / 2) {
      tx += dx + settings.cameraWindow_w / 2;
    } else if (dx > settings.cameraWindow_w / 2) {
      tx += dx - settings.cameraWindow_w / 2;
    }
    if (dy < -settings.cameraWindow_h / 2) {
      ty += dy + settings.cameraWindow_h / 2;
    } else if (dy > settings.cameraWindow_h / 2) {
      ty += dy - settings.cameraWindow_h / 2;
    }

    if (!settings.cameraEasing_x) {
      px = x;
      x = tx;
    } else {
      float vx = x - px;
      px = x;
      x += vx * (0.5 - settings.cameraEasingNormal_x) + (tx - x) * settings.cameraEasingNormal_x;
    }
    x = constrain(x, window_hw, level.w - window_hw);

    if (!settings.platformSnapping || !jumper.jumping) {
      if (!settings.cameraEasing_y) {
        py = y;
        y = ty;
      } else {
        float vy = y - py;
        py = y;
        if (!jumper.onObstacle) {
          y += vy * (0.5 - settings.cameraEasingNormal_y) + (ty - y) * settings.cameraEasingNormal_y;
        } else {
          y += vy * (0.5 - settings.cameraEasingGrounding_y) + (ty - y) * settings.cameraEasingGrounding_y;
        }
      }
      y = constrain(y, window_hh, level.h - window_hh);
    }
  }

  void drawBG(int cx, int cy) {
    PImage bg;

    cx = (int)(((float)cx - level.bgImg.width * 0.5) * settings.bgScrollRatio + level.bgImg.width * 0.5);
    cy = (int)(((float)cy - (level.h - window_h)) * settings.bgScrollRatio + (level.h - window_h));

    int bgx = cx % level.bgImg.width;
    int bgy = (level.bgImg.height - (level.h - cy) % level.bgImg.height) % level.bgImg.height;
    int bgTile_y = (level.h - cy - 1) / level.bgImg.height;

    int dw1 = level.bgImg.width - bgx;
    int dw2 = window_w - dw1;
    int dh1 = level.bgImg.height - bgy;
    int dh2 = window_h - dh1;

    dw1 = min(dw1, window_w);
    dh1 = min(dh1, window_h);

    bg = (bgTile_y > 0) ? level.bgSkyImg : level.bgImg;
    copy(bg, bgx, bgy, dw1, dh1, 0, 0, dw1, dh1);
    if (dw2 > 0) {
      copy(bg, 0, bgy, dw2, dh1, dw1, 0, dw2, dh1);
    }
    if (dh2 > 0) {
      bg = (bgTile_y > 1) ? level.bgSkyImg : level.bgImg;
      copy(bg, bgx, 0, dw1, dh2, 0, dh1, dw1, dh2);
      if (dw2 > 0) {
        copy(bg, 0, 0, dw2, dh2, dw1, dh1, dw2, dh2);
      }
    }
  }

  void draw() {
    int cx = ((int)x - window_hw);
    int cy = ((int)y - window_hh);

    drawBG(cx, cy);
    copy(levelImg, cx, cy, window_w, window_h, 0, 0, window_w, window_h);

    if (settings.showTrail) drawTrail(cx, cy);
    PImage img = jumper.draw(cx, cy);
    if (!gPause || gStepForward) {
      trail[trailHead].x = jumper.x;
      trail[trailHead].y = jumper.y;
      trail[trailHead].image = img;
      trailHead++;
      if (trailHead >= trailLen) trailHead = 0;
    }

    if (settings.showCameraMarker) drawCameraMarker(cx, cy);
    if (showTitle) drawTitle();
    if (settings.showInputStatus) drawInputStatus();
    if (gPause) drawPauseBar();

    noStroke();
    fill(128);
    rect(gConsole.x, gConsole.y, gConsole.w, gConsole.h);
    stroke(255);
    line(gConsole.x, gConsole.y + 166, gConsole.x + gConsole.w, gConsole.y + 166);
  }

  void drawTrail(int cx, int cy) {
    pushMatrix();
    translate(-cx, -cy);
    pushStyle();
    if (!settings.showAfterimage) {
      for (int i=0; i<trailLen; i++) {
        noStroke();
        fill(255, 0, 0);
        ellipse(trail[i].x + Jumper.w / 2, trail[i].y + Jumper.h / 2, 5, 5);
      }
    } else {
      tint(255, 128);
      for (int i=0; i<trailLen; i++) {
        int idx = (trailHead + 1 + i) % trailLen;
        if (idx % 4 == 0) {
          jumper.draw(trail[idx].image, trail[idx].x, trail[idx].y);
        }
      }
    }
    popMatrix();
    popStyle();
  }

  void drawCameraMarker(int cx, int cy) {
    pushStyle();
    noStroke();
    fill(255, 0, 0);
    rect(window_hw -  2, window_hh - 12, 5, 25);
    rect(window_hw - 12, window_hh -  2, 25, 5);
    stroke(255);
    noFill();
    rect(window_hw - settings.cameraWindow_w / 2, window_hh - settings.cameraWindow_h / 2, settings.cameraWindow_w, settings.cameraWindow_h);
    if (settings.forwardFocus || settings.projectedFocus) {
      int fx = (int)(jumper.center_x() + targetFocus_x) - cx;
      int fy = (int)jumper.center_y() - cy;
      line(fx - 9, fy - 9, fx + 9, fy + 9);
      line(fx - 9, fy + 9, fx + 9, fy - 9);
      stroke(255, 255, 0);
      fx = (int)(jumper.center_x() + focus_x) - cx;
      fy = (int)jumper.center_y() - cy;
      line(fx - 12, fy, fx + 12, fy);
      line(fx, fy - 12, fx, fy + 12);
    }
    popStyle();
  }

  void drawInputStatus() {
    pushMatrix();
    pushStyle();
    translate(window_hw - 170, 40);
    stroke(0);
    strokeWeight(3);
    if (jumper.inputStatus[0]) {
      fill(64, 255, 255);
    } else {
      fill(0, 64, 64);
    }
    triangle(0, 40, 60, 0, 60, 80);
    translate(80, 0);
    if (jumper.inputStatus[1]) {
      fill(64, 255, 255);
    } else {
      fill(0, 64, 64);
    }
    triangle(20, 0, 80, 40, 20, 80);
    translate(100, 0);
    if (jumper.inputStatus[2]) {
      fill(255, 64, 64);
    } else {
      fill(64, 0, 0);
    }
    ellipse(40, 40, 70, 70);
    if (jumper.inputStatus[3]) {
      fill(255, 64, 64);
    } else {
      fill(64, 0, 0);
    }
    ellipse(120, 40, 70, 70);
    popMatrix();
    popStyle();
  }

  void drawTitle() {
    pushStyle();
    int now = millis();
    if (titleTimer < 0) {
      titleTimer = now + 3500;
    } else if (now < titleTimer) {
      int remaining = titleTimer - now;
      if (remaining >= 256 && (jumper.vx != 0 || !jumper.onObstacle)) {
        titleTimer -= 100;
      }
      if (remaining < 256) {
        tint(255, remaining);
      }
      image(titleImg, (window_w - titleImg.width) / 2, 50);
      textAlign(RIGHT, CENTER);
      textFont(onScreenFont);
      fill(255, remaining);
      text("Version " + gVersionString, (window_w - titleImg.width) / 2 + titleImg.width, 50 + titleImg.height);
    } else {
      showTitle = false;
    }
    popStyle();
  }

  void drawPauseBar() {
    pushMatrix();
    pushStyle();
    translate(window_hw, window_hh - 50);
    textFont(onScreenFont);
    textSize(16);
    float w = textWidth("PAUSE");
    noStroke();
    fill(0);
    rect(-w / 2 - 50, -10, w + 100, 20);
    fill(255);
    text("PAUSE", -w / 2, 7);
    popMatrix();
    popStyle();
  }
}
