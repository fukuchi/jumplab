class Camera {
  Jumper jumper;
  Level level;
  PImage levelImg;
  PVector[] posbuf;
  static final int posbuflen = 64;
  int posbufp = 0;

  float x, y;
  float px, py; // previous position
  float focus_x;
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
    px = this.x;
    py = this.y;
    focus_x = x;
  }

  void update() {
    float tx = x; // target position
    float ty = y;

    float dx = jumper.x + Jumper.w / 2 - x;
    float dy = jumper.y + Jumper.h / 2 - y;
    if (settings.forwardFocus) {
      float fx = jumper.lastDir * settings.focusDistance;
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
        }
      }
      dx += focus_x;
    }
    if (dx < -settings.cameraWindow_w / 2) {
      tx += dx + settings.cameraWindow_w / 2;
    } else {
      if (dx > settings.cameraWindow_w / 2) {
        tx += dx - settings.cameraWindow_w / 2;
      }
    }
    if (dy < -settings.cameraWindow_h / 2) {
      ty += dy + settings.cameraWindow_h / 2;
    } else {
      if (dy > settings.cameraWindow_h / 2) {
        ty += dy - settings.cameraWindow_h / 2;
      }
    }

    if (!settings.cameraEasing_x) {
      px = x;
      x = constrain(tx, window_hw, level.w - window_hw);
    } else {
      float vx = x - px;
      px = x;
      float dist = abs(tx - x);
      vx += Math.signum(tx - x) * dist * settings.cameraEasingNormal_x;
      vx = vx * 0.5;
      x += vx;
      x = constrain(x, window_hw, level.w - window_hw);
    }

    if (!settings.platformSnapping || !jumper.jumping) {
      if (!settings.cameraEasing_y) {
        py = y;
        y = constrain(ty, window_hh, level.h - window_hh);
      } else {
        float vy = y - py;
        py = y;
        if (!jumper.onObstacle) {
          float dist = abs(ty - y);
          vy += Math.signum(ty - y) * dist * settings.cameraEasingNormal_y;
          vy = vy * 0.5;
          y += vy;
        } else {
          y += (ty - y) * settings.cameraEasingGrounding_y;
        }
        y = constrain(y, window_hh, level.h - window_hh);
      }
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

    if (settings.showCameraMarker) {
      noStroke();
      fill(255, 0, 0);
      rect(window_hw -  2, window_hh - 12, 5, 25);
      rect(window_hw - 12, window_hh -  2, 25, 5);
      stroke(255);
      noFill();
      rect(window_hw - settings.cameraWindow_w / 2, window_hh - settings.cameraWindow_h / 2, settings.cameraWindow_w, settings.cameraWindow_h);
      if (settings.forwardFocus) {
        int fx = (int)(jumper.x + Jumper.w / 2 + jumper.lastDir * settings.focusDistance) - cx;
        int fy = (int)jumper.y + Jumper.h / 2 - cy;
        line(fx - 12, fy, fx + 12, fy     );
        line(fx, fy - 12, fx, fy + 12);
        stroke(255, 255, 0);
        fx = (int)(jumper.x + Jumper.w / 2 + focus_x) - cx;
        fy = (int)jumper.y + Jumper.h / 2 - cy;
        line(fx - 12, fy, fx + 12, fy     );
        line(fx, fy - 12, fx, fy + 12);
      }
    }

    noStroke();
    fill(128);
    rect(console.x, console.y, console.w, console.h);
    stroke(255);
    line(console.x, console.y + 166, console.x + console.w, console.y + 166);
  }
}
