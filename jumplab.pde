/*
 * JumpLab: a testbed for studying jump motion and scrolling algorithms of videogames
 *
 * Web: https://fukuchi.org/works/jumplab/
 * Repository: https://github.com/fukuchi/jumplab/
 *
 * Copyright (C) 2020, 2021 Kentaro Fukuchi <kentaro@fukuchi.org> and other contributors
 *
 * This program is free software: you can redistribute it and/or modify it under the terms
 * of the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see https://www.gnu.org/licenses/.
 */

import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;

Settings gSettings;
Jumper gMasao;
Level gLevel;
Camera gCamera;
Console gConsole;
Joystick gJoystick;
StyleManager gStyles;

boolean gPause;
boolean gStepForward;

static final String gVersionString = "1.4.0";

static final int gameScreen_w = 800;
static final int gameScreen_h = 600;
static final int console_w = 300;

static final String userSettingsFilename = "user_settings.json";
static final String defaultSettingsFilename = "default_settings.json";
static final String joystickConfigFilename = "joystick_config.json";

static boolean takeScreenshot = false;
static DateTimeFormatter dateTimeFormatter;

void settings() {
  println("JumpLab version " + gVersionString);
  println("Initializing...");
  // If you have any performance problem, try P2D render as follows.
  size(gameScreen_w + console_w, gameScreen_h);
  //size(gameScreen_w + console_w, gameScreen_h, P2D);
  noSmooth();
}

void setup() {
  gStyles = new StyleManager();
  if (!gStyles.loadDefaultSettings(defaultSettingsFilename)) {
    System.err.println("Failed to load the default style settings. The installed package seems to be broken. Check the files under the installed directory.");
    exit();
  }
  gStyles.loadUserSettings(userSettingsFilename);

  gSettings = new Settings();
  gJoystick = new Joystick(this, joystickConfigFilename);
  gLevel = new Level("level1.csv", "tiles.png", "bg.png", "bg-sky.png");
  gMasao = new Jumper(gSettings, gLevel);
  gCamera = new Camera(gMasao, gLevel, gSettings, gameScreen_w, gameScreen_h);
  gCamera.reset(gMasao.center_x(), gMasao.center_y());
  gConsole = new Console(this, gameScreen_w, 0, console_w, gameScreen_h, gStyles, gSettings);
  frameRate(60);

  dateTimeFormatter = DateTimeFormatter.ofPattern("uuuu-MM-dd_HH-mm-ss-SSS");

  background(128);
  println("Initialization completed.");
}

void draw() {
  if (!gPause || gStepForward) {
    gMasao.update();
    gCamera.update();
    gConsole.statusUpdate(gMasao, gLevel, gCamera);
    gStepForward = false;
  } else {
    gJoystick.updateDuringPause();
  }
  gCamera.draw();
  gConsole.draw(gMasao);

  if (takeScreenshot) {
    String filename = String.format("screenshot_%s.png", LocalDateTime.now().format(dateTimeFormatter));

    save(filename);

    takeScreenshot = false;
  }
}

void keyPressed() {
  boolean eventReceived;

  eventReceived = gMasao.keyPressed();
  if (!eventReceived) gConsole.keyPressed();
  if (key == 's') {
    takeScreenshot = true;
  }
}

void keyReleased() {
  boolean eventReceived;

  eventReceived = gMasao.keyReleased();
  if (!eventReceived) gConsole.keyReleased();
}
