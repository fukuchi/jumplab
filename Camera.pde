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
    this.x = constrain(x + Jumper.w / 2, window_hw, level.w - window_hw);
    this.y = constrain(y + Jumper.h / 2, window_hh, level.h - window_hh);
    px = this.x;
    py = this.y;
    focus_x = 0;
  }

  void update() {
    float tx = x; // target position
    float ty = y;

    float dx = jumper.x + Jumper.w / 2 - x;
    float dy = jumper.y + Jumper.h / 2 - y;
    if (settings.forwardFocus || settings.projectedFocus) {
      float fx = 0;
      if (settings.forwardFocus) {
        fx += jumper.lastDir * settings.focusDistance;
      }
      if (settings.projectedFocus) {
        fx += settings.focusDistance * jumper.vx / settings.maxVx;
      }
      if (jumper.lastDir > 0) {
        if (focus_x < fx) {
          float cameraEdge_x = settings.cameraWindow_w / 2 - dx;
          if (focus_x < cameraEdge_x) {
            focus_x = cameraEdge_x;
          }
          focus_x += settings.focusingSpeed;
          if (focus_x > fx) {
            focus_x = fx;
          }
        } else if (focus_x > fx) {
          focus_x -= 1;
          if (focus_x < fx) {
            focus_x = fx;
          }
        }
      } else if (jumper.lastDir < 0) {
        if (focus_x > fx) {
          float cameraEdge_x = -settings.cameraWindow_w / 2 - dx;
          if (focus_x > cameraEdge_x) {
            focus_x = cameraEdge_x;
          }
          focus_x -= settings.focusingSpeed;
          if (focus_x < fx) {
            focus_x = fx;
          }
        } else if (focus_x < fx) {
          focus_x += 1;
          if (focus_x > fx) {
            focus_x = fx;
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

    if (settings.showTrail) {
      pushStyle();
      if (!settings.showAfterimage) {
        noStroke();
        fill(255, 0, 0);
        for (int i=0; i<trailLen; i++) {
          ellipse(trail[i].x + Jumper.w / 2 - cx, trail[i].y + Jumper.h / 2 - cy, 5, 5);
        }
      } else {
        tint(255, 128);
        for (int i=0; i<trailLen; i++) {
          int idx = (trailHead + 1 + i) % trailLen;
          if (idx % 4 == 0) {
            jumper.draw(trail[idx].image, trail[idx].x - cx, trail[idx].y - cy);
          }
        }
      }
      popStyle();
    }
    PImage img = jumper.draw(cx, cy);
    if (!gPause || gStepForward) {
      trail[trailHead].x = jumper.x;
      trail[trailHead].y = jumper.y;
      trail[trailHead].image = img;
      trailHead++;
      if (trailHead >= trailLen) trailHead = 0;
    }

    if (settings.showCameraMarker) {
      noStroke();
      fill(255, 0, 0);
      rect(window_hw -  2, window_hh - 12, 5, 25);
      rect(window_hw - 12, window_hh -  2, 25, 5);
      stroke(255);
      noFill();
      rect(window_hw - settings.cameraWindow_w / 2, window_hh - settings.cameraWindow_h / 2, settings.cameraWindow_w, settings.cameraWindow_h);
      if (settings.forwardFocus || settings.projectedFocus) {
        float tx = 0;
        if (settings.forwardFocus) {
          tx += jumper.lastDir * settings.focusDistance;
        }
        if (settings.projectedFocus) {
          tx += settings.focusDistance * jumper.vx / settings.maxVx;
        }
        int fx = (int)(jumper.x + Jumper.w / 2 + tx) - cx;
        int fy = (int)jumper.y + Jumper.h / 2 - cy;
        line(fx - 9, fy - 9, fx + 9, fy + 9);
        line(fx - 9, fy + 9, fx + 9, fy - 9);
        stroke(255, 255, 0);
        fx = (int)(jumper.x + Jumper.w / 2 + focus_x) - cx;
        fy = (int)jumper.y + Jumper.h / 2 - cy;
        line(fx - 12, fy, fx + 12, fy     );
        line(fx, fy - 12, fx, fy + 12);
      }
    }

    noStroke();
    fill(128);
    rect(gConsole.x, gConsole.y, gConsole.w, gConsole.h);
    stroke(255);
    line(gConsole.x, gConsole.y + 166, gConsole.x + gConsole.w, gConsole.y + 166);

    if (showTitle) {
      drawTitle();
    }

    if (settings.showInputStatus) {
      drawInputStatus();
    }

    if (gPause) {
      pushStyle();
      pushMatrix();
      translate(window_hw, window_hh - 50);
      textFont(onScreenFont);
      textSize(16);
      float w = textWidth("PAUSE");
      noStroke();
      fill(0);
      rect(-w / 2 - 50, -10, w + 100, 20);
      fill(255);
      text("PAUSE", -w / 2, 7);
      popStyle();
      popMatrix();
    }
  }

  void drawInputStatus() {
    pushMatrix();
    pushStyle();
    translate(window_hw - 120, 40);
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
      showTitle =false;
    }
    popStyle();
  }
}
