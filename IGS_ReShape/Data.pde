class Group { // A group is a list of Path objects
  List<Path> group = new ArrayList();
}

class Path { // A path object is a list of Points with additional data for name, selection, color
  List<Point> path;
  String name;
  boolean isActive;
  int shadeNumber;

  Path(String name, int shadeNumber) {
    this.path = new ArrayList<Point>();
    this.name = name;
    this.isActive = false;
    this.shadeNumber = shadeNumber;
  }
}

class Point {
  Location location; // lat, lng values
  float altitude;
  long time;
}

class MapLayer { // A MapLayer is an image with a set of attributes
  PImage image;
  boolean isActive;
  boolean geoRectified;
  Location rectifiedTopCorner; // for rectifying map
  Location rectifiedBottomCorner;
  ScreenPosition adjustingTopCorner; // for further adjusting a rectified map image
  ScreenPosition adjustingBottomCorner;
}
