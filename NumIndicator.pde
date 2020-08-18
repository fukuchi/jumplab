class NumIndicator {
  // This class would not be needed if ControlP5 had provided any monospace font...
  static final int glyph_w = 6;
  static final int glyph_h = 8;

  PImage[] glyphs;
  NumIndicator() {
    glyphs = new PImage[15];
    PImage img = loadImage("numglyphs.png");
    img.loadPixels();
    for (int i=0; i<15; i++) {
      glyphs[i] = createImage(glyph_w, glyph_h, RGB);
      glyphs[i].loadPixels();
      for (int y=0; y<glyph_h; y++) {
        for (int x=0; x<glyph_w; x++) {
          glyphs[i].pixels[y * glyph_w + x] = img.pixels[(y * 15 + i) * glyph_w + x];
        }
      }
      glyphs[i].updatePixels();
    }
  }

  void text(String str, int x, int y) {
    for (char ch : str.toCharArray()) {
      int idx = 0;
      if (ch >= ',' && ch <= '9') {
        idx = ch - ',' + 1;
      }
      fill(0);
      image(glyphs[idx], x, y);
      x += glyph_w;
    }
  }
}
