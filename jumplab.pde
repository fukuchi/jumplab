Settings settings;
Jumper masao;
Level level;
Camera camera;
Console console;
Joystick joystick;

static final int gameScreen_w = 800;
static final int gameScreen_h = 600;
static final int console_w = 300;

void settings() {
  println("Initializing...");
  // If you have any performance problem, try P2D render as follows.
  size(gameScreen_w + console_w, gameScreen_h);
  //  size(gameScreen_w + console_w, gameScreen_h, P2D);
  noSmooth();
}

void setup() {
  settings = new Settings();
  settings.load();
  joystick = new Joystick(this);
  level = new Level("level1.csv", "block.png", "bg.png");
  masao = new Jumper(settings, level.sx, level.sy);
  camera = new Camera(masao, level, gameScreen_w, gameScreen_h);
  camera.reset(masao.x, masao.y);
  console = new Console(this, gameScreen_w, 0, console_w, gameScreen_h, settings);
  frameRate(60);
  background(128);
  println("Initialization completed.");
}

void draw() {
  masao.update();
  camera.update();
  console.statusUpdate(masao);
  camera.draw();
  console.drawStatus(masao);
}

void keyPressed() {
  masao.keyPressed();
}

void keyReleased() {
  masao.keyReleased();
}
