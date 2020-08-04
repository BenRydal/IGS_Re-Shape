void loadData() {
  setScales();  // run first
  setGUI();
  loadBaseLayers();
  loadPaths();
  setMap(); // run after loadPaths
}

void setScales() {
  // ------ map scales ------
  mapSpacing = width/25; // sets general spacing variable
  mapWidth = width/2; // sets mapWidth
  mapHeight = height - 2.5 * mapSpacing; // setsMapHeight
  startingHeightKeys = mapHeight + mapSpacing/2; // sets yPos for where keys are located

  // ------ time scales ------
  timelineLength = width - mapWidth - 1.5 * mapSpacing;
  timelineStart = mapWidth + mapSpacing; 
  timelineEnd = timelineStart + timelineLength;
  currPixelTimeMin = timelineStart; // set to beginning/end of timeline to start
  currPixelTimeMax = timelineEnd;
  timeLineCenter = timelineStart + timelineLength/2;
  zoom = -int(width-mapWidth/1.5);

  // ------ text scales ------
  if (width < 600 || height < 600) {
    lrgTextSize = 11;
    keyTextSize = 8;
  } else {
    lrgTextSize = 18;
    keyTextSize = 15;
  }
}

void setMap() {
  map = new UnfoldingMap(this, 0, 0, mapWidth * 2, mapHeight, provider);
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
  yPosTimeScale = startingHeightKeys + tickHeight;
  yPosTimeScaleTop = startingHeightKeys - 2 * tickHeight;
  yPosTimeScaleBottom = startingHeightKeys + 2 * tickHeight;
  yPosFormattedDate = yPosTimeScale - tickHeight - mapSpacing/6;
  // Map layer Keys
  yPosMapLayerKeysTop = startingHeightKeys;
  yPosMapLayerKeysBottom = startingHeightKeys + mapSpacing/2;
  yPosMapLayerKeys = startingHeightKeys + mapSpacing/3;
  // Movement path keys
  yPosPathKeysTop = startingHeightKeys +  mapSpacing;
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
  groupSpacing = textWidth(groupSpacingText); // spacing for group keys
  pathKeySpacing = 2 * textWidth(pathKeySpacingText); // spacing for movement path keys
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
    } else println("Error loading file, please make sure you have selected a .png, .jpg or .GIF file");
  }
} 

// Test image file, load image and add to map layers array if properly formatted image file
void baseLayerFileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    String fileName = selection.getAbsolutePath();
    if (fileName.endsWith(".png") || fileName.endsWith(".jpg") || fileName.endsWith(".GIF")) { // If it is a CSV file load data
      PImage image = requestImage(fileName);
      MapLayer layer = new MapLayer();
      layer.image = image;
      layer.isActive = false;
      layer.geoRectified = false;
      layer.rectifiedTopCorner = new Location(0, 0);
      layer.rectifiedBottomCorner = new Location(0, 0);
      layer.adjustingTopCorner = new ScreenPosition(0, 0);
      layer.adjustingBottomCorner = new ScreenPosition(0, 0);
      mapLayers.add(layer);
    } else println("Error loading file, please make sure you have selected a .png, .jpg or .GIF file");
  }
  loop(); // resume program
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
      Path temp = processTable(GPS, fileName, currGroup.group.size()); // send to process table
      if (temp.path.size() > 0) currGroup.group.add(temp); // make sure Table has data/headers before adding
    }
  }
  // if (currGroup.group.size() > 0)  groups.add(currGroup); // make sure group has data before adding
  // else println("No files were loaded, please make sure table columns and dates are properly formatted");
  groups.add(currGroup);
  if (currGroup.group.size() == 0)  println("No files were loaded, please make sure table columns and dates are properly formatted");
}

void pathFileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    // send to function to test/load data and add to paths
    println("User selected " + selection.getAbsolutePath());
    String fileName = selection.getAbsolutePath();
    if (fileName.endsWith(".csv")) { // If it is a CSV file load data
      Table GPS = loadTable(fileName, "header");
      Path temp = processTable(GPS, fileName, currGroup.group.size()); // send to process table
      // Pan to 1st location and add to currGroup if file has data
      if (temp.path.size() > 0) {
        Point point = temp.path.get(1); // get 1st point to pan to location of path
        temp.isActive = true;
        currGroup.group.add(temp);
        map.panTo(point.location); // pan map to location
      } else println("Error loading file, please make sure table columns and dates are properly formatted");
    } else println("Error loading file, please make sure table columns and dates are properly formatted");
  }
  loop(); // resume program
}

// Tests and returns Path object from CSV file
Path processTable(Table GPS, String fileName, int student) {
  Path s = new Path("Path " + (student + 1), (student % colorShadeNumber)); // add 1 so labeled paths in GUI start at 1 not 0, 2nd parameter sets int for color selection
  // Loop through table to get/create column name strings
  int columnCount = GPS.getColumnCount();
  ArrayList<String> columns = new ArrayList();
  for (int i = 0; i < columnCount; i++) columns.add(GPS.getColumnTitle(i));
  // loop through table rows and test 
  for (TableRow position : GPS.rows ()) {
    float lat = 0, lng = 0, alt = 0; // set starting values for testing
    long time = 0;
    // loop over column names and for each row test if column name is correct and get value
    try {
      for (String columnName : columns) {
        if (columnName.startsWith("tim")) time = tryParse(position.getString(columnName));
        else if (columnName.startsWith("lat")) lat = position.getFloat(columnName);
        else if (columnName.startsWith("long")) lng = position.getFloat(columnName);
        else if (columnName.startsWith("alt")) alt = position.getFloat(columnName);
      }
    }
    catch (Exception e) {
      println(fileName + "was not loaded. Please make sure column names are correct");
      break;
    } 
    if (testDataValues(lat, lng, alt, time)) { // If all data has respective values 
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

// Test if data is not starting values or NaN
boolean testDataValues(float lat, float lng, float alt, long time) {
  if (!Float.isNaN(lat) && lat != 0 && !Float.isNaN(lng) && lng != 0 && !Float.isNaN(alt) && alt != 0 && time != 0L) return true;
  else return false;
}

// Converts date stamp to unix time based on local timezone
long tryParse(String s) {
  List<String> formatStrings = Arrays.asList(dateStringsToTest); // Date formats to test
  for (String fs : formatStrings) {
    try {
      SimpleDateFormat sdf = new SimpleDateFormat(fs);
      sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
      return (sdf.parse(s).getTime()) / 1000L;
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
