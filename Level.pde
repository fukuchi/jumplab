class Level {
  int w, h; // level size in pixel
  int cw, ch; // level size in character
  int bw, bh; // block size
  int sx, sy; // initial position of the player character
  int[][] map;
  PImage bgImg;
  PImage blockImg;

  Level(String mapFile, String blockImgFile, String bgFile) {
    sx = sy = 1;
    Table mapdata = loadTable(mapFile);
    cw = mapdata.getColumnCount();
    ch = mapdata.getRowCount();
    map = new int[ch][cw];
    for (int y=0; y<ch; y++) {
      TableRow row = mapdata.getRow(y);
      for (int x=0; x<cw; x++) {
        int v = row.getInt(x);
        if (v == 9) {
          sx = x;
          sy = y;
        } else {
          map[y][x] = v;
        }
      }
    }

    blockImg = loadImage(blockImgFile);
    bgImg = loadImage(bgFile);
    bw = blockImg.width;
    bh = blockImg.height;

    w = bw * cw;
    h = bh * ch;

    sx = sx * bw;
    sy = sy * bh;
  }

  boolean isThereObstacle(int x, int y) {
    int cx = x / bw;
    int cy = y / bh;
    if (cx < 0 || cy < 0 || cx >= cw || cy >= ch) return true;
    return map[cy][cx] > 0;
  }

  float obstaclePenaltyL(float x) {
    int cx = (int)(x + bw) / bw;
    return cx * bw - x;
  }

  float obstaclePenaltyR(float x) {
    int cx = (int)x / bw;
    return x - cx * bw;
  }

  float obstaclePenaltyU(float y) {
    int cy = (int)(y + bh) / bh;
    return cy * bw - y;
  }

  float obstaclePenaltyD(float y) {
    int cy = (int)y / bh;
    return y - cy * bw;
  }
}
