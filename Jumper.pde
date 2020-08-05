import java.util.Vector;

class Jumper {
  float x, y;
  float px, py;
  float vx, vy;
  int dir;
  int lastDir;
  int jumpDir;
  boolean jumping;
  boolean standing;
  boolean propelling;
  boolean onObstacle;
  float verticalAcc;
  int jumpMotion;
  int jumpMotionMax;
  int propellingRemainingFrames;
  float pattern;
  int runningMotionMax;
  Settings settings;
  Level level;
  int[] joyInput;

  Vector<PImage> images_running_r;
  Vector<PImage> images_running_l;
  Vector<PImage> images_jumping_r;
  Vector<PImage> images_jumping_l;

  static final int w = 24;
  static final int h = 48;

  Jumper(Settings settings, Level level) {
    this.settings = settings;
    this.level = level;

    x = (float)level.sx;
    y = (float)level.sy;
    px = x;
    py = y;
    vx = 0;
    vy = 0;
    jumping = false;
    propelling = false;
    onObstacle = false;
    jumpMotion = 0;
    dir = 0;
    lastDir = 1;
    jumpDir = 0;
    pattern = 0;
    verticalAcc = settings.gravityFalling;
    joyInput = new int[3];

    initializeImages();
  }

  void initializeImages() {
    images_running_r = new Vector<PImage>();
    images_running_l = new Vector<PImage>();
    images_jumping_r = new Vector<PImage>();
    images_jumping_l = new Vector<PImage>();
    runningMotionMax = 8;
    for (int i=0; i<runningMotionMax+1; i++) {
      String filename = String.format("stickman-%d.png", i);
      images_running_r.add(loadImage(filename));
      images_running_l.add(hflipImage(images_running_r.get(i)));
    }

    jumpMotionMax = 4;
    for (int i=0; i<jumpMotionMax; i++) {
      String filename = String.format("stickman-jump-%d.png", jumpMotionMax - i);
      images_jumping_r.add(loadImage(filename));
    }
    jumpMotionMax = images_jumping_r.size();
    for (int i = 0; i < jumpMotionMax; i++) {
      images_jumping_l.add(hflipImage(images_jumping_r.get(i)));
    }
  }

  void update() {
    boolean hDL, hDR, hUL, hUR;

    joystickUpdate();
    px = x;
    py = y;
    velocityXUpdate();
    velocityYUpdate();
    animationUpdate();

    x += vx;
    y += vy;

    hDL = hitDL();
    hDR = hitDR();

    if (!onObstacle && (hDL || hDR)) {
      float ny = y - level.obstaclePenaltyD(y);
      if (vy > 0 && py <= ny) {
        if ((hDL && !hitUL()) || (hDR && !hitUR())) {
          y = ny;
          jumping = false;
          onObstacle = true;
          vy = 0;
        }
      }
    } else if (!hitBL() && !hitBR()) {
      onObstacle = false;
      if (!jumping && settings.haltedAndFall) {
        vx = 0;
      }
    }

    if (hitUL() && hitUR()) {
      y += level.obstaclePenaltyU(y);
      vy = 0;
      propelling = false;
    }

    hUL = hitUL();
    hDL = hitDL();
    if (hUL || hDL) {
      float penalty = level.obstaclePenaltyL(x);
      if (hUL && !hDL) {
        float ny = y + level.obstaclePenaltyU(y);
        if (vy < 0 && penalty >= settings.collisionTolerance && ny <= py) {
          y += level.obstaclePenaltyU(y);
          vy = 0;
          propelling = false;
        } else {
          x += penalty ;
          if (vx < 0) vx = 0;
        }
      } else {
        x += penalty;
        if (vx < 0) vx = 0;
      }
    }

    hUR = hitUR();
    hDR = hitDR();
    if (hUR || hDR) {
      float penalty = level.obstaclePenaltyR(x + w);
      if (hUR && !hDR) {
        float ny = y + level.obstaclePenaltyU(y);
        if (vy < 0 && penalty >= settings.collisionTolerance && ny <= py) {
          y += level.obstaclePenaltyU(y);
          vy = 0;
          propelling = false;
        } else {
          x -= penalty;
          if (vx > 0) vx = 0;
        }
      } else {
        x -= penalty;
        if (vx > 0) vx = 0;
      }
    }
  }

  void velocityXUpdate() {
    float ax;
    if (jumping || (!onObstacle && !settings.allowAerialWalk)) {
      ax = settings.axJumping;
    } else if (!jumping && !onObstacle && settings.haltedAndFall) {
      ax = 0;
    } else if (Math.signum(vx) != dir) {
      ax = settings.axBrake;
    } else {
      ax = settings.axNormal;
    }
    if (dir != 0) {
      vx += ax * dir;
      if (settings.vxAdjustmentAtTakeoff > 0 && jumping) {
        vx = constrain(vx, -settings.maxVx * (1 + settings.vxAdjustmentAtTakeoff), settings.maxVx * (1 + settings.vxAdjustmentAtTakeoff));
      } else {
        vx = constrain(vx, -settings.maxVx, settings.maxVx);
      }
    } else {
      vx -= ax * Math.signum(vx);
      if (abs(vx) < ax) {
        vx = 0;
      }
    }
  }

  void velocityYUpdate() {
    if (jumping && jumpMotion > 0) {
      jumpMotion--;
      if (jumpMotion == 0) {
        vy = -settings.jumpPower - (settings.jumpPowerBonus * abs(vx));
        if (settings.vxAdjustmentAtTakeoff < 0) {
          vx += vx * settings.vxAdjustmentAtTakeoff;
        } else if (settings.vxAdjustmentAtTakeoff > 0) {
          vx += vx * settings.vxAdjustmentAtTakeoff;
        }
        onObstacle = false;
        if (settings.maxPropellingFrames > 0) {
          propelling = true;
          propellingRemainingFrames = round(settings.maxPropellingFrames);
        }
      }
    }
    if (!onObstacle) {
      if (!settings.allowAerialJump && jumping && jumpMotion > 0) {
        jumping = false;
        jumpMotion = 0;
        propelling = false;
      }
      if (vy > 0) {
        verticalAcc = settings.gravityFalling;
      }
      if (!propelling) {
        vy += verticalAcc;
        if (vy > settings.maxVy) {
          vy = settings.maxVy;
        }
      }
      if (settings.maxPropellingFrames > 0) {
        if (propelling) {
          propellingRemainingFrames--;
          if (propellingRemainingFrames <= 0) {
            propelling = false;
          }
        }
      }
    }
  }

  void animationUpdate() {
    if (vx == 0) {
      int p = (int)pattern;
      if (p % (runningMotionMax / 2) > 0) {
        pattern += 0.5;
      } else {
        p = 0;
        standing = true;
      }
    } else {
      pattern += abs(vx/12);
      standing = false;
    }
    if (pattern >= runningMotionMax) {
      pattern -= runningMotionMax;
    }
  }

  boolean hitUL() {
    return level.isThereObstacle((int)x, (int)y);
  }
  boolean hitUR() {
    return level.isThereObstacle(ceil(x + w - 1), (int)y);
  }
  boolean hitDL() {
    return level.isThereObstacle((int)x, ceil(y + h - 1));
  }
  boolean hitDR() {
    return level.isThereObstacle(ceil(x + w - 1), ceil(y + h - 1));
  }
  boolean hitBL() {
    return level.isThereObstacle((int)x, ceil(y + h));
  }
  boolean hitBR() {
    return level.isThereObstacle(ceil(x + w - 1), ceil(y + h));
  }

  void move(int d) {
    dir = d;
    if (dir != 0) {
      lastDir = dir;
    }
  }

  void jump() {
    if (!jumping) {
      if (onObstacle) {
        jumping = true;
        jumpDir = lastDir;
        jumpMotion = round(settings.jumpAnticipationFrames) + 1;
        verticalAcc = settings.gravity;
      }
    }
  }

  void jumpCanceled() {
    if (jumping) {
      verticalAcc = settings.gravityFalling;
      if (vy < 0) vy *= settings.verticalSpeedSustainLevel;
      propelling = false;
    }
  }

  void draw(float dx, float dy) {
    PImage img;

    if (jumping) {
      int p = jumpMotion==0?0:(int)(jumpMotion * (jumpMotionMax - 1) / (settings.jumpAnticipationFrames + 1) + 1);
      int dir = settings.allowAerialTurn?lastDir:jumpDir;
      if (dir < 0) {
        img = images_jumping_l.get(p);
      } else {
        img = images_jumping_r.get(p);
      }
    } else if (standing) {
      img = (lastDir < 0)?images_running_l.get(0):images_running_r.get(0);
    } else {
      int p = (int)pattern;
      if (lastDir < 0) {
        img = images_running_l.get(p + 1);
      } else {
        img = images_running_r.get(p + 1);
      }
    }
    image(img, dx - (img.width - 24) / 2, dy);
  }

  boolean keyPressed() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        move(-1);
        return true;
      } else if (keyCode == RIGHT) {
        move(1);
        return true;
      }
    } else if (key == ' ') {
      jump();
      return true;
    }
    return false;
  }

  boolean keyReleased() {
    if (key == CODED) {
      if (keyCode == LEFT && dir == -1 ||
        keyCode == RIGHT && dir == 1) {
        move(0);
        return true;
      }
    } else if (key == ' ') {
      jumpCanceled();
      return true;
    }
    return false;
  }

  void joystickUpdate() {
    gJoystick.update(joyInput);
    if (joyInput[0] != 0) {
      move(joyInput[1]);
    }
    if (joyInput[2] < 0) jumpCanceled();
    if (joyInput[2] > 0) jump();
  }

  PImage hflipImage(PImage srcImg) {
    PImage destImg = createImage(srcImg.width, srcImg.height, ARGB);
    int x, y;

    srcImg.loadPixels();
    destImg.loadPixels();
    for (y=0; y<srcImg.height; y++) {
      for (x=0; x<srcImg.width; x++) {
        destImg.pixels[srcImg.width - 1 - x + y * srcImg.width] =
          srcImg.pixels[x + y * srcImg.width];
      }
    }
    destImg.updatePixels();
    return destImg;
  }
}
