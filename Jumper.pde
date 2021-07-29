import java.util.Vector;

class Jumper {
  float x, y;
  float px, py;
  float vx, vy;
  float pvx, pvy;
  float ay;
  float maxVx;
  int dir;
  int lastDir;
  int jumpDir;
  boolean jumping;
  boolean dashing;
  boolean standing;
  boolean propelling;
  boolean onObstacle;
  int jumpMotion;
  int jumpMotionMax;
  int propellingRemainingFrames;
  float pattern;
  int runningMotionMax;
  Settings settings;
  Level level;
  int[] keyInput;
  int[] joyInput;
  boolean[] inputStatus;
  static final int inputTypes = 4; // left, right, jump, dash

  Vector<Vector<PImage>> stock_images_running_l;
  Vector<Vector<PImage>> stock_images_running_r;
  Vector<Vector<PImage>> stock_images_jumping_l;
  Vector<Vector<PImage>> stock_images_jumping_r;
  final String[] proportionLabels = {"1h", "3h", "8h"};

  int character;
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
    vx = vy = 0;
    pvx = pvy = 0;
    jumping = false;
    propelling = false;
    onObstacle = false;
    jumpMotion = 0;
    dir = 0;
    lastDir = 1;
    jumpDir = 0;
    pattern = 0;
    ay = settings.gravityFalling;
    keyInput = new int[inputTypes];
    joyInput = new int[inputTypes];
    inputStatus = new boolean[inputTypes];

    initializeImages();
    setImages(1);
  }

  void initializeImages() {
    stock_images_running_r = new Vector<Vector<PImage>>();
    stock_images_running_l = new Vector<Vector<PImage>>();
    stock_images_jumping_r = new Vector<Vector<PImage>>();
    stock_images_jumping_l = new Vector<Vector<PImage>>();

    for (String label : proportionLabels) {
      images_running_r = new Vector<PImage>();
      images_running_l = new Vector<PImage>();
      images_jumping_r = new Vector<PImage>();
      images_jumping_l = new Vector<PImage>();

      runningMotionMax = 8;
      for (int i=0; i<runningMotionMax+1; i++) {
        String filename = String.format("%s/stickman-%d.png", label, i);
        images_running_r.add(loadImage(filename));
        images_running_l.add(hflipImage(images_running_r.get(i)));
      }
      jumpMotionMax = 4;
      for (int i=0; i<jumpMotionMax; i++) {
        String filename = String.format("%s/stickman-jump-%d.png", label, jumpMotionMax - i);
        images_jumping_r.add(loadImage(filename));
        images_jumping_l.add(hflipImage(images_jumping_r.get(i)));
      }

      stock_images_running_r.add(images_running_r);
      stock_images_running_l.add(images_running_l);
      stock_images_jumping_r.add(images_jumping_r);
      stock_images_jumping_l.add(images_jumping_l);
    }
  }

  void setImages(int num) {
    settings.selectedCharacter = proportionLabels[num];
    images_running_r = stock_images_running_r.get(num);
    images_running_l = stock_images_running_l.get(num);
    images_jumping_r = stock_images_jumping_r.get(num);
    images_jumping_l = stock_images_jumping_l.get(num);
  }

  float center_x() {
    return x + Jumper.w / 2;
  }

  float center_y() {
    return y + Jumper.h / 2;
  }

  void update() {
    boolean hDL, hDR, hUL, hUR;

    maxVx = dashing?settings.maxVxDashing:settings.maxVx;

    pvx = vx;
    pvy = vy;
    px = x;
    py = y;

    control(keyInput);
    joystickUpdate();
    velocityXUpdate();
    velocityYUpdate();
    animationUpdate();

    x += vx;
    y += vy;

    hDL = hitDL(0);
    hDR = hitDR(0);

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
      if (!jumping && settings.stopAndFall) {
        vx = 0;
      }
    }

    if (hitUL() && hitUR()) {
      y += level.obstaclePenaltyU(y);
      vy = 0;
      propelling = false;
    }

    hUL = hitUL();
    hDL = hitDL(0);
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
    hDR = hitDR(0);
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
    } else if (!jumping && !onObstacle && settings.stopAndFall) {
      ax = 0;
    } else if (Math.signum(vx) != dir) {
      ax = settings.axBrake;
    } else {
      if (dashing) {
        ax = settings.axNormalDashing;
      } else {
        ax = settings.axNormal;
      }
    }
    if (dir != 0) {
      vx += ax * dir;
      if (settings.vxAdjustmentAtTakeoff > 0 && jumping) {
        vx = constrain(vx, -maxVx * (1 + settings.vxAdjustmentAtTakeoff), maxVx * (1 + settings.vxAdjustmentAtTakeoff));
      } else {
        vx = constrain(vx, -maxVx, maxVx);
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
        vy = -settings.jumpVelocity - (settings.jumpVelocityBonus * abs(vx));
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
        ay = settings.gravityFalling;
      }
      if (!propelling) {
        vy += ay;
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
      if (settings.allowWallSlide) {
        if (lastDir < 0 && hitDL(1) && inputStatus[0] || lastDir > 0 && hitDR(1) && inputStatus[1]) {
          if (vy >= settings.maxVy * 0.2) vy = settings.maxVy * 0.2;
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
  boolean hitDL(int d) {
    return level.isThereObstacle((int)x - d, ceil(y + h - 1));
  }
  boolean hitDR(int d) {
    return level.isThereObstacle(ceil(x + w - 1) + d, ceil(y + h - 1));
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
        ay = settings.gravity;
      }
    }
    if (!onObstacle && settings.allowWallJump) {
      if (lastDir < 0 && hitDL(1) && inputStatus[0] || lastDir > 0 && hitDR(1) && inputStatus[1]) {
        jumping = true;
        jumpDir = -lastDir;
        jumpMotion = 1;
        ay = settings.gravity;
        vx = -maxVx * lastDir * settings.wallJumpSpeedRatio;
        vy = 0;
      }
    }
  }

  void jumpCanceled() {
    if (jumping) {
      ay = settings.gravityFalling;
      if (vy < 0) vy *= settings.verticalSpeedSustainLevel;
      propelling = false;
    }
  }

  void dashStart() {
    dashing = true;
  }

  void dashEnd() {
    dashing = false;
  }

  void draw(PImage img, float dx, float dy) {
    if (img != null) {
      image(img, dx - (img.width - 24) / 2, dy);
    }
  }

  PImage draw(float cx, float cy) {
    PImage img;

    if (jumping) {
      int p = (jumpMotion == 0)?0: (int)(jumpMotion * (jumpMotionMax - 1) / (settings.jumpAnticipationFrames + 1) + 1);
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
    this.draw(img, x - cx, y - cy);

    return img;
  }

  boolean keyPressed() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        keyInput[0] = 1;
        return true;
      } else if (keyCode == RIGHT) {
        keyInput[1] = 1;
        return true;
      } else if (keyCode == SHIFT) {
        keyInput[3] = 1;
      }
    } else if (key == ' ') {
      keyInput[2] = 1;
      return true;
    }
    return false;
  }

  boolean keyReleased() {
    if (key == CODED) {
      if (keyCode == LEFT) {
        keyInput[0] = -1;
        return true;
      } else if (keyCode == RIGHT) {
        keyInput[1] = -1;
        return true;
      } else if (keyCode == SHIFT) {
        keyInput[3] = -1;
      }
    } else if (key == ' ') {
      keyInput[2] = -1;
      return true;
    }
    return false;
  }

  void control(int[] input) {
    if (input[0] > 0) {
      move(-1);
    } else if (input[1] > 0) {
      move(1);
    } else if (input[0] < 0 && dir == -1 || input[1] < 0 && dir == 1) {
      move(0);
    }
    if (input[2] > 0) {
      jump();
    } else if (input[2] < 0) {
      jumpCanceled();
    }
    if (input[3] > 0) {
      dashStart();
    } else if (input[3] < 0) {
      dashEnd();
    }
    for (int i=0; i<inputTypes; i++) {
      if (input[i] > 0) inputStatus[i] = true;
      if (input[i] < 0) inputStatus[i] = false;
      input[i] = 0;
    }
  }

  void joystickUpdate() {
    gJoystick.update(joyInput);
    control(joyInput);
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
