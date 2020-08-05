Settings gSettings;
Jumper gMasao;
Level gLevel;
Camera gCamera;
Console gConsole;
Joystick gJoystick;
PresetManager gPresets;

static final int gameScreen_w = 800;
static final int gameScreen_h = 600;
static final int console_w = 300;

static String userSettingsFilename = "user_settings.json";
static String defaultSettingsFilename = "default_settings.json";
static String joystickConfigFilename = "joystick_config.json";

void settings() {
  println("Initializing...");
  // If you have any performance problem, try P2D render as follows.
  size(gameScreen_w + console_w, gameScreen_h);
  //  size(gameScreen_w + console_w, gameScreen_h, P2D);
  noSmooth();
}

void setup() {
  gPresets = new PresetManager();
  if (!gPresets.load(userSettingsFilename)) {
    if (!gPresets.load(defaultSettingsFilename)) {
      System.err.println("The installed package seems to be broken. Check the files under the installed directory.");
      exit();
    }
  }
  gSettings = new Settings();
  gJoystick = new Joystick(this, joystickConfigFilename);
  gLevel = new Level("level1.csv", "block.png", "bg.png");
  gMasao = new Jumper(gSettings, gLevel);
  gCamera = new Camera(gMasao, gLevel, gSettings, gameScreen_w, gameScreen_h);
  gCamera.reset(gMasao.x, gMasao.y);
  gConsole = new Console(this, gameScreen_w, 0, console_w, gameScreen_h, gPresets, gSettings);
  frameRate(60);
  background(128);
  println("Initialization completed.");
}

void draw() {
  gMasao.update();
  gCamera.update();
  gConsole.statusUpdate(gMasao, gLevel, gCamera);
  gCamera.draw();
  gConsole.drawStatus(gMasao);
}

void keyPressed() {
  gMasao.keyPressed();
}

void keyReleased() {
  gMasao.keyReleased();
}
