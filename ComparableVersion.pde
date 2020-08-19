class ComparableVersion implements Comparable<ComparableVersion> {
  private int[] numbers;
  String versionString;

  ComparableVersion(String versionString) {
    this.versionString = versionString;
    String[] strs = versionString.split("\\.", 3);
    numbers = new int[strs.length];

    for (int i=0; i<strs.length; i++) {
      numbers[i] = Integer.parseInt(strs[i]);
    }
  }

  int maxLevel() {
    return numbers.length;
  }

  int number(int level) {
    if (level >= numbers.length) {
      return -1;
    }
    return numbers[level];
  }

  int compareTo(ComparableVersion other, int level) {
    int thisNum = this.number(level);
    int otherNum = other.number(level);
    int res = Integer.compare(thisNum, otherNum);
    if (res == 0) {
      if (thisNum >= 0 && otherNum >= 0) {
        res = compareTo(other, level + 1);
      }
    }
    return res;
  }

  int compareTo(ComparableVersion other) {    
    return compareTo(other, 0);
  }
  
  int compareTo(String other) {
    return compareTo(new ComparableVersion(other));
  }

  String toString() {
    return versionString;
  }
}
