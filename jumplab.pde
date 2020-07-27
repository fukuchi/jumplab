Settings settings;
Jumper masao;
Level level;
Camera camera;
Console console;

void setup() {
  size(1100, 600);

  settings = new Settings();
  masao = new Jumper(settings, 48, 950);
  level = new Level("level1.csv", "block.png", "bg.png");
  camera = new Camera(masao, level, 800, 600);
  camera.reset(masao.x, masao.y);
  console = new Console(this, camera.window_w, 0, width - camera.window_w, camera.window_h, settings);
  frameRate(60);
  background(128);
}

void draw() {
  masao.update();
  camera.update();
  console.statusUpdate(masao);
  camera.draw();
}

void keyPressed() {
  masao.keyPressed();
}

void keyReleased() {
  masao.keyReleased();
}
