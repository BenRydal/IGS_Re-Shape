void loadData() {
  setScales();  // run first
  setGUI();
  loadBaseLayers();
  loadPaths();
  setMap(); // run after loadPaths
}

void setScales() {
  // ------ map scales ------
  mapWidth = width/2.5;
  mapSpacing = width/25;
  mapHeight = height - 2 * mapSpacing;

  // ------ time scales ------
  timelineLength = width - mapWidth - 1.5 * mapSpacing;
  timelineStart = mapWidth + mapSpacing; 
  timelineEnd = timelineStart + timelineLength;
  currPixelTimeMin = timelineStart; // set to beginning/end of timeline to start
  currPixelTimeMax = timelineEnd;
  timeLineCenter = timelineStart + timelineLength/2;
  zoom = -int(width-mapWidth);

  // ------ text scales ------
  if (width < 600 || height < 600) {
    lrgTextSize = 13;
    keyTextSize = 10;
  } else {
    lrgTextSize = 18;
    keyTextSize = 15;
  }
}

void setMap() {
  map = new UnfoldingMap(this, -mapWidth, 0, mapWidth * 2, mapHeight, provider);
  MapUtils.createDefaultEventDispatcher(this, map);
  map.zoomToLevel(12);
  map.panTo(locationToStart);
  map.panLeft(); // roughly centers the map on first point
  map.panLeft();
  map.setZoomRange(4, 20); // prevent zooming too far out
  map.setTweening(true);
  PVector rotateCenter = new PVector(mapWidth/2, mapHeight/2);
  map.mapDisplay.setInnerTransformationCenter(rotateCenter);
}

void setGUI() {
  // Timeline
  tickHeight = mapSpacing/3;
  yPosTimeScale = mapHeight + tickHeight;
  yPosTimeScaleTop = mapHeight - 2 * tickHeight;
  yPosTimeScaleBottom = mapHeight + 2 * tickHeight;
  // Map layer Keys
  yPosMapLayerKeysTop = mapHeight;
  yPosMapLayerKeysBottom = mapHeight + mapSpacing/2;
  yPosMapLayerKeys = mapHeight + mapSpacing/3;
  // Movement path keys
  yPosPathKeysTop = mapHeight +  mapSpacing;
  yPosPathKeysBottom = yPosPathKeysTop + mapSpacing/2;
  yPospathKeys = yPosPathKeysTop + mapSpacing/3;
  // Group Keys
  yPosGroupLablesTop = yPosPathKeysTop - mapSpacing/2.5;
  yPosGroupLablesBottom = yPosPathKeysTop;
  yPosGroupLables = yPosPathKeysTop - mapSpacing/14;
  // View Keys
  yPosDimensionLables = yPosPathKeysBottom;
  yPosDimensionLablesTop = yPosDimensionLables - mapSpacing/2;
  yPosDimensionLablesBottom = yPosDimensionLables + mapSpacing/3;

  // Adaptable Spacing
  textSize(keyTextSize);
  groupSpacing = textWidth("GROUP:      "); // spacing for group keys
  pathKeySpacing = 2 * textWidth("Path"); // spacing for movement path keys
  pathDispNum = int(mapWidth/pathKeySpacing); // set display multiplier to fit within mapWidth
  layerDispNum = int((mapWidth/1.5)/pathKeySpacing); // set layer display multiplier to fit within mapWidth/2
}

void loadBaseLayers() {
  String filePath = "data/maps/";
  final File dataDir = new File(sketchPath(filePath));
  for (final File f : dataDir.listFiles()) { // For all files in directory get file if it is image file
    if (f.getName().endsWith(".png") || f.getName().endsWith(".jpg") || f.getName().endsWith(".GIF")) {
      PImage image = loadImage(filePath + f.getName());
      MapLayer layer = new MapLayer();
      layer.image = image;
      layer.isActive = false;
      layer.geoRectified = false;
      layer.rectifiedTopCorner = new Location(0, 0);
      layer.rectifiedBottomCorner = new Location(0, 0);
      layer.adjustingTopCorner = new ScreenPosition(0, 0);
      layer.adjustingBottomCorner = new ScreenPosition(0, 0);
      mapLayers.add(layer);
    }
  }
} 

// Loads all files in tracks directory and organizes for data processing
void loadPaths() {  
  String filePath = "data/";
  final File dataDir = new File(sketchPath(filePath)); // Create path to data folder
  currGroup = new Group(); // initial group to hold all paths
  for (final File f : dataDir.listFiles()) { // loop through all files in directory
    String fileName = f.getName();
    if (fileName.endsWith(".csv")) { // If it is a CSV file load data
      Table GPS = loadTable(filePath + fileName, "header");
      Path temp = processTable(GPS, fileName, currGroup.group.size() + 1); // send to process table, + 1 to start path names in GUI at 1 not 0
      if (temp.path.size() > 0) currGroup.group.add(temp); // make sure Table has data/headers before adding
    }
  }
  if (currGroup.group.size() > 0)  groups.add(currGroup); // make sure group has data before adding
  else println("No files were loaded, please make sure table columns and dates are properly formatted");
}

// Tests and returns Path object from CSV file
Path processTable(Table GPS, String fileName, int student) {
  Path s = new Path("Path " + student, returnColorNumber(student - 1)); // Initialize path object to hold data, subtract one to pick correct color array
  for (TableRow position : GPS.rows ()) {
    float lat = 0, lng = 0, alt = 0;
    long time = 0;
    // Tests to make sure columns labeled correctly
    try {
      // get values from column positions corresponding to ViewRanger formatting
      time = tryParse(position.getString(1)); // time
      lat = position.getFloat(2); // latitude
      lng = position.getFloat(3); // longitude
      alt = position.getFloat(4); // altitude
    } 
    catch (Exception e) {
      println(fileName + "was not loaded. Please make sure column names are correct");
      break;
    } 
    if (!Float.isNaN(lat) && !Float.isNaN(lng) && !Float.isNaN(alt) && time != 0L) { // If all data has respective values 
      if (unixMin == 0) setStartingValues(time, alt, lat, lng); // if 1st point set starting values for comparison
      else compareValues(time, alt); // else compare values to previous min/max values
      // Add point to path
      Point point = new Point();
      point.location = new Location(lat, lng);       
      point.altitude = alt;
      point.time = time;
      s.path.add(point);
    }
  }
  return s; // return Path object
}

// Converts date stamp to unix time based on local timezone
long tryParse(String s) {
  List<String> formatStrings = Arrays.asList(dateStringsToTest); // Date formats to test
  for (String fs : formatStrings) {
    try {
      SimpleDateFormat sdf = new SimpleDateFormat(fs);
      sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
      return (sdf.parse(s).getTime()) / 1000L; // gets unix time in seconds and subtracts 18000 to account for GMT
    } 
    catch (Exception e) {
      // println("Please check the date/time format of data");
    }
  }
  return 0L;
}

// Runs once in entire program to set starting values for comparison
void setStartingValues(long time, float alt, float lat, float lng) {
  unixMin = time;
  unixMax = time;
  altitudeMin = alt;
  altitudeMax = alt;
  locationToStart = new Location(lat, lng);
}

// Compares and sets new min/max data values accordingly
void compareValues(long time, float alt) {
  if (time < unixMin) unixMin = time; // time comparison
  else if (time > unixMax) unixMax = time;
  if (alt < altitudeMin) altitudeMin = alt; // altitude comparison
  else if (alt > altitudeMax) altitudeMax = alt;
}

int returnColorNumber(int num) {
  if (num < colorShadeNumber) return num;
  else if (num < (2 * colorShadeNumber)) return num - colorShadeNumber;
  else if (num < (3 * colorShadeNumber)) return num - (2 * colorShadeNumber);
  else if (num < (4 * colorShadeNumber)) return num - (3 * colorShadeNumber);
  else return 0;
}
