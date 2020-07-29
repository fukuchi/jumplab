import java.util.Vector;

class Jumper {
  float x, y;
  float px, py;
  float vx, vy;
  int dir;
  int lastDir;
  int jumpDir;
  boolean jumping;
  boolean onObstacle;
  float verticalAcc;
  int jumpMotion;
  int jumpMotionMax;
  float pattern;
  Settings settings;

  Vector<PImage> images_running_r;
  Vector<PImage> images_running_l;
  Vector<PImage> images_jumping_r;
  Vector<PImage> images_jumping_l;

  static final int w = 24;
  static final int h = 48;

  Jumper(Settings settings, int x, int y) {
    this.x = (float)x;
    this.y = (float)y;
    this.settings = settings;

    px = x;
    py = y;
    vx = 0;
    vy = 0;
    jumping = false;
    onObstacle = false;
    jumpMotion = 0;
    dir = 0;
    lastDir = 0;
    jumpDir = 0;
    pattern = 0;
    verticalAcc = settings.gravityFalling;

    initializeImages();
  }

  void initializeImages() {
    images_running_r = new Vector<PImage>();
    images_running_l = new Vector<PImage>();
    images_jumping_r = new Vector<PImage>();
    images_jumping_l = new Vector<PImage>();
    images_running_r.add(loadImage("char-run-1.png"));
    images_running_r.add(loadImage("char-run-2.png"));
    images_running_r.add(loadImage("char-run-3.png"));
    images_running_r.add(loadImage("char-run-4.png"));
    for (int i = 0; i < images_running_r.size (); i++) {
      images_running_l.add(hflipImage(images_running_r.get(i)));
    } 
    images_jumping_r.add(loadImage("char-jump.png"));
    images_jumping_r.add(loadImage("char-jump-pre3.png"));
    images_jumping_r.add(loadImage("char-jump-pre2.png"));
    images_jumping_r.add(loadImage("char-jump-pre1.png"));
    jumpMotionMax = images_jumping_r.size();
    for (int i = 0; i < jumpMotionMax; i++) {
      images_jumping_l.add(hflipImage(images_jumping_r.get(i)));
    }
  }

  void update() {
    boolean hDL, hDR, hUL, hUR;

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
    }

    if (hitUL() && hitUR()) {
      y += level.obstaclePenaltyU(y);
      vy = 0;
    }

    hUL = hitUL();
    hDL = hitDL();
    if (hUL || hDL) {
      float penalty = level.obstaclePenaltyL(x);
      if (hUL && !hDL) {
        if (vy < 0 && penalty >= 6) {
          y += level.obstaclePenaltyU(y);
          vy = 0;
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
        if (vy < 0 && penalty >= 6 && ny < py) {
          y += level.obstaclePenaltyU(y);
          vy = 0;
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
    } else if (Math.signum(vx) != dir) {
      ax = settings.axBreak;
    } else {
      ax = settings.axNormal;
    }
    if (dir != 0) {
      vx += ax * dir;
      vx = constrain(vx, -settings.maxVx, settings.maxVx);
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
        vy = -settings.jumpPower;
        onObstacle = false;
      }
    }
    if (!onObstacle) {
      if (!settings.allowAerialJump && jumping && jumpMotion > 0) {
        jumping = false;
        jumpMotion = 0;
      }
      if (vy > 0) {
        verticalAcc = settings.gravityFalling;
      }
      vy += verticalAcc;
      if (vy > settings.maxVy) {
        vy = settings.maxVy;
      }
    }
  }

  void animationUpdate() {
    if (vx != 0) {
      pattern += abs(vx/16);
      if (pattern >= images_running_r.size()) {
        pattern = 0;
      }
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
        jumpMotion = (int)settings.jumpAnticipationFrames + 1;
        verticalAcc = settings.gravity;
      }
    }
  }

  void jumpCanceled() {
    if (jumping) {
      verticalAcc = settings.gravityFalling;
    }
  }

  void draw(float dx, float dy) {
    PImage img;

    if (jumping) {
      int p = jumpMotion==0?0:(int)(jumpMotion * (jumpMotionMax - 1) / (settings.jumpAnticipationFrames + 1) + 1);
      if (jumpDir < 0) {
        img = images_jumping_l.get(p);
      } else {
        img = images_jumping_r.get(p);
      }
    } else {
      int p = (int)pattern;
      if (lastDir < 0) {
        img = images_running_l.get(p);
      } else {
        img = images_running_r.get(p);
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
