void keyPressed() {
  if (key =='r') map.rotate(PI/20);
  else if (key =='l') map.rotate(-PI/20);
  else if (key == 'a' || key == 'A') { // controls animation
    animateMode = !animateMode;
    animateTimeMin = currPixelTimeMin;
    animateTimeMax = currPixelTimeMin;
  } else if (key == 'f') zoom += 20;
  else if (key == 'b') zoom -= 20;
  else if (key == 'g' || key == 'G') groupPathsMode = !groupPathsMode;
  else if (key == 'c' || key == 'C') changeColorMode = !changeColorMode;
  else if (key == 'd' || key == 'D') cleanData = !cleanData;
  else if (key == 's' || key == 'S') {
    selectAllPathsMode = !selectAllPathsMode;
    for (Path s : currGroup.group) {
      if (selectAllPathsMode && !s.isActive) s.isActive = true;
      else if (!selectAllPathsMode && s.isActive) s.isActive = false;
    }
  }
}

void mousePressed() { // only one handler is called, test method organizes respective handler in each sub class
  if (startingMessage == true) startingMessage = false; 
  MouseHandler handle = new MouseHandler();
  if (!animateMode && overRect(timelineStart, yPosTimeScaleTop, timelineEnd, yPosTimeScaleBottom)) handle = new handleTimelineKeys();
  else if (overRect(0, yPosPathKeysTop, timelineStart, yPosPathKeysBottom)) handle = new handlePathKeys();
  else if (overRect(0, yPosGroupLablesTop, width, yPosGroupLablesBottom)) handle = new handleGroupKeys();
  else if (overRect(0, yPosMapLayerKeysTop, timelineStart, yPosMapLayerKeysBottom)) handle = new handleMapKeys();
  else if (overRect(timelineStart, yPosDimensionLablesTop, width, yPosDimensionLablesBottom)) handle = new handleDimensionKeys();
  else if (overRect(mapSpacing/2, mapHeight - (mapSpacing + mapSpacing/2), 2 * mapSpacing/2, mapHeight - mapSpacing/2)) handle = new handleMapZoomKeys();
  else if (overRect(mapSpacing/2, mapHeight, mapWidth/2, yPosTimeScaleBottom)) handle = new handleAddFileKeys();
  handle.test();
}

void mouseDragged() {
  if (!animateMode) {
    MouseHandler handle = new handleTimelineKeys();
    if (lockedLeft || lockedRight || lockedMiddle) handle.test();
    else if (overRect(timelineStart, yPosTimeScaleTop, timelineEnd, yPosTimeScaleBottom)) handle.test();
  }
  // Map opacity scrollbar
  float valueToMap = constrain(mouseX, mapOpacityXPosStart, mapOpacityXPosEnd);
  if (overCircle(mapOpacityCirXPos, yPosMapLayerKeys, mapOpacityCirSize*2)) mapOpacityLevel = map(valueToMap, mapOpacityXPosStart, mapOpacityXPosEnd, 0, 255);
}

void mouseReleased() {
  lockedLeft = false;
  lockedRight = false;
  lockedMiddle = false;
}

boolean overCircle(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

boolean overRect(float x, float y, float boxWidth, float boxHeight) {
  if (mouseX >= x && mouseX <= boxWidth &&
    mouseY >= y && mouseY <= boxHeight) {
    return true;
  } else {
    return false;
  }
}

class MouseHandler {
  void test() {
  }
}

class handleGroupKeys extends MouseHandler {

  void test() {
    reScaleValues = true; // controls rescaling method later in program
    float xPosToTest = groupSpacing/2; // Starting xPosition, each function builds/increments on this xPosition to test all buttons/keys
    xPosToTest = handleGroupTab(xPosToTest);
    xPosToTest = handleAddTab(xPosToTest);
    xPosToTest = handleSubtractTab(xPosToTest);
  }

  // Loop through all groups and change active group 
  float handleGroupTab(float xPos) {
    for (Group g : groups) {
      if (overRect(xPos, yPosGroupLablesTop, xPos + groupSpacing, yPosGroupLablesBottom)) {
        if (g != currGroup) {
          dispMult = 0; // reset displayMult for selected group
          currGroup = g; // set current group to this group
        }
      }
      xPos += groupSpacing; // increment spacing
    }
    return xPos; // return updated xPosition
  }

  // + button, adds all selected paths to a new group
  float handleAddTab (float xPos) { 
    if (overRect(xPos, yPosGroupLablesTop, xPos + groupSpacing/2, yPosGroupLablesBottom) && (xPos < width - 2 * groupSpacing)) { // if over and less than width
      Group g = new Group(); // keeps incrementing name of group
      for (Path p : currGroup.group) if (p.isActive) g.group.add(p);
      // If paths are selected make new group and set to current croup
      if (g.group.size() != 0) { // if paths are selected
        groups.add(g);
        currGroup = g;
        dispMult = 0; // reset displayMultiplier
      }
    }
    return xPos += groupSpacing/2;
  }

  // - button, removes group if not base/1st group
  float handleSubtractTab (float xPos) {
    if (overRect(xPos, yPosGroupLablesTop, xPos + groupSpacing/2, yPosGroupLablesBottom)) {
      List<Group> tempGroup = new ArrayList();
      int i = 0; // Necessary to not delete 1st/base group of paths
      if (groups.size() > 1) {
        for (Group g : groups) {
          if (g == currGroup && i != 0) tempGroup.add(g);
          i++;
        }
        groups.removeAll(tempGroup);
        currGroup = groups.get(0);
        dispMult = 0; // reset displayMultiplier
      }
    }
    return xPos += groupSpacing/2;
  }
}

class handleDimensionKeys extends MouseHandler {

  void test() {
    textSize(lrgTextSize);  

    if (overRect(width - textWidth(view_1 + view_2 + view_3 + view_4), yPosDimensionLablesTop, width - textWidth(view_2 + view_3 + view_4), yPosDimensionLablesBottom)) { 
      map.move(width/2-mapWidth, 0);
      if (display_2D) {
        map.panRight();
        map.panRight();
      } 
      display_1D = true;
      display_2D = false;
      display_3D = false;
      display_4D = false;
      rotation = 0;
      translateY = 0;
    } else if (overRect(width - textWidth(view_2 + view_3 + view_4), yPosDimensionLablesTop, width - textWidth(view_3 + view_4), yPosDimensionLablesBottom)) { 
      map.move(-mapWidth, 0);
      if (display_1D) {
        map.panLeft();
        map.panLeft();
      } else if (display_3D || display_4D) {
        map.panLeft();
        map.panLeft();
      }
      display_1D = false;
      display_2D = true;
      display_3D = false;
      display_4D = false;
      rotation = 0;
      translateY = 0;
    } else if (overRect(width - textWidth(view_3 + view_4), yPosDimensionLablesTop, width - textWidth(view_4), yPosDimensionLablesBottom)) {
      map.move((width - 2*mapWidth)/2, 0); // shift map to allow mouse handling on map in 3D
      if (display_2D) {
        map.panRight();
        map.panRight();
      }
      display_1D = false;
      display_2D = false;
      display_3D = true;
      display_4D = false;
    } else if (overRect(width - textWidth(view_4), yPosDimensionLablesTop, width, yPosDimensionLablesBottom)) {
      map.move(-mapWidth, 0);
      if (display_2D) {
        map.panRight();
        map.panRight();
      }
      display_1D = false;
      display_2D = false;
      display_3D = false;
      display_4D = true;
    }
  }
}

class handlePathKeys extends MouseHandler {
  // For every group that exists in 'groups', change the active group and current student list when clicked.
  void test() {
    reScaleValues = true; // controls rescaling method later in program
    float xPosToTest = mapSpacing/2; // 
    xPosToTest = handleLeftArrow(xPosToTest);
    xPosToTest = handlePaths(xPosToTest);
    xPosToTest = handleRightArrow(xPosToTest);
  }

  float handleLeftArrow(float xPos) {
    // checks logic for left button and loops to end of list of paths in the current group
    if (overRect(xPos, yPosPathKeysTop, xPos + pathKeySpacing/2, yPosPathKeysBottom)) { // TEMP x pos
      dispMult--;
      if (dispMult < 0) dispMult = currGroup.group.size() / pathDispNum;
    }
    return xPos += pathKeySpacing/2;
  }

  float handlePaths(float xPos) { // Loops through paths based on displayMult
    for (int i = dispMult * pathDispNum; i < (dispMult * pathDispNum) + pathDispNum; i ++) {
      if (i < currGroup.group.size()) { 
        Path currPath = currGroup.group.get(i);
        if (overRect(xPos, yPosPathKeysTop, xPos + pathKeySpacing, yPosPathKeysBottom)) {
          // two modes/selection possibilities to toggle on/off keys OR switch colors
          if (changeColorMode && currPath.isActive && !groupPathsMode) { // if in changeColorMode, not groupPathsMode and the path is showing
            if (currPath.shadeNumber < colorShadeNumber - 1) currPath.shadeNumber +=1; // increment color by 1
            else currPath.shadeNumber = currPath.shadeNumber - (colorShadeNumber - 1); // reset color to starting value in color array
          } else currPath.isActive = !currPath.isActive;
        }
        xPos += pathKeySpacing;
      }
    }
    return xPos;
  }

  float handleRightArrow(float xPos) {
    // checks logic for right button and loops to begining of list of paths in the current group when reaching the end of paths
    if (overRect(xPos, yPosPathKeysTop, xPos + pathKeySpacing/2, yPosPathKeysBottom)) {
      dispMult++;
      if (dispMult > currGroup.group.size() / pathDispNum) dispMult = 0;
    }
    return xPos += pathKeySpacing/2;
  }
}


class handleMapKeys extends MouseHandler {

  void test() {
    textSize(keyTextSize);  
    fill(255);
    float xPosToTest = mapSpacing/2; // Measures the left side of each group visually
    xPosToTest = handleLeftArrow(xPosToTest);
    xPosToTest = handleMaps(xPosToTest);
    xPosToTest = handleRightArrow(xPosToTest);
    xPosToTest = handleRectifyButton(xPosToTest);
    xPosToTest = handleAdjustButton(xPosToTest);
  }

  float handleLeftArrow(float xPos) {
    // if over left arrowhead
    if (overRect(xPos, yPosMapLayerKeysTop, xPos + pathKeySpacing/2, yPosMapLayerKeysBottom)) {
      mapLayerDispMult--;
      if (mapLayerDispMult < 0) mapLayerDispMult = mapLayers.size() / layerDispNum;
    } 
    return xPos += pathKeySpacing/2;
  }

  float handleMaps(float xPos) {
    // for MapLayers that are showing
    for (int i = mapLayerDispMult * layerDispNum; i < (mapLayerDispMult * layerDispNum) + layerDispNum; i ++) {
      if (i < mapLayers.size()) { 
        if (overRect(xPos, yPosMapLayerKeysTop, xPos + pathKeySpacing, yPosMapLayerKeysBottom)) {
          MapLayer currLayer = mapLayers.get(i);
          currLayer.isActive = !currLayer.isActive;
          if (adjustingMode) adjustingMode = false; // reset adjusting mode
          // Turn off all other active layers
          // loop through all layers again and for any that are active, make inactive except for "i" layer
          for (int j = 0; j < mapLayers.size(); j ++) {
            MapLayer layerToDeactivate = mapLayers.get(j);
            if (j != i) layerToDeactivate.isActive = false;
          }
        }
        xPos += pathKeySpacing;
      }
    }
    return xPos;
  }

  float handleRightArrow(float xPos) {
    fill(255);
    // if over right arrowhead
    if (overRect(xPos, yPosMapLayerKeysTop, xPos + pathKeySpacing/2, yPosMapLayerKeysBottom)) {
      mapLayerDispMult++;
      if (mapLayerDispMult > mapLayers.size() / layerDispNum) {
        mapLayerDispMult = 0;
      }
    }
    return xPos += pathKeySpacing/2;
  }

  float handleRectifyButton(float xPos) {
    if (overRect(xPos, yPosMapLayerKeysTop, xPos + textWidth("Rectify"), yPosMapLayerKeysBottom)) {
      for (int i = mapLayerDispMult * layerDispNum; i < (mapLayerDispMult * layerDispNum) + layerDispNum; i ++) {
        if (i < mapLayers.size()) { 
          MapLayer currLayer = mapLayers.get(i);
          if (currLayer.isActive) {
            // if it is rectified, reset all paramenters
            if (adjustingMode) adjustingMode = false;  // reset adjusting mode
            currLayer.geoRectified = !currLayer.geoRectified;
            if (display_1D) {
              currLayer.rectifiedTopCorner = map.getLocation(width/2 - currLayer.image.width/2, mapHeight/2 - currLayer.image.height/2);
              currLayer.rectifiedBottomCorner = map.getLocation(width/2 + currLayer.image.width/2, mapHeight/2 + currLayer.image.height/2);
            } else if (display_2D) {
              currLayer.rectifiedTopCorner = map.getLocation(mapWidth/2 - currLayer.image.width/2, mapHeight/2 - currLayer.image.height/2);
              currLayer.rectifiedBottomCorner = map.getLocation(mapWidth/2 + currLayer.image.width/2, mapHeight/2 + currLayer.image.height/2);
            }
          }
        }
      }
    }
    return xPos += textWidth("Rectify") + pathKeySpacing/2;
  }

  float handleAdjustButton(float xPos) {
    if (overRect(xPos, yPosMapLayerKeysTop, xPos + textWidth("Adjust"), yPosMapLayerKeysBottom)) {
      for (int i = mapLayerDispMult * layerDispNum; i < mapLayers.size(); i ++) {
        MapLayer currLayer = mapLayers.get(i);
        if (currLayer.isActive && currLayer.geoRectified) { // has to be active and already rectified
          if (adjustingMode) {
            adjustingMode = !adjustingMode;
            currLayer.rectifiedTopCorner = map.getLocation(currLayer.adjustingTopCorner.x, currLayer.adjustingTopCorner.y);
            currLayer.rectifiedBottomCorner = map.getLocation(currLayer.adjustingBottomCorner.x, currLayer.adjustingBottomCorner.y);
          } else {
            adjustingMode = !adjustingMode;
            currLayer.adjustingTopCorner = map.getScreenPosition(currLayer.rectifiedTopCorner);
            currLayer.adjustingBottomCorner = map.getScreenPosition(currLayer.rectifiedBottomCorner);
          }
        }
      }
    }
    return xPos;
  }
}

class handleTimelineKeys extends MouseHandler {

  void test() {
    float xPosLeftSelector = currPixelTimeMin;
    float xPosRightSelector = currPixelTimeMax;
    float selSpacing = mapSpacing/4;
    // 3 types of selection that work together
    if (lockedLeft || (!lockedRight && !lockedMiddle && overRect(xPosLeftSelector - selSpacing, yPosTimeScaleTop, xPosLeftSelector + selSpacing, yPosTimeScaleBottom))) {
      lockedLeft = true;
      currPixelTimeMin = constrain(mouseX, timelineStart, timelineEnd);
      if (currPixelTimeMin > currPixelTimeMax - (2 * selSpacing)) currPixelTimeMin = currPixelTimeMax - (2 * selSpacing); // prevents overstriking
    } else if (lockedRight || !lockedMiddle && overRect(xPosRightSelector - selSpacing, yPosTimeScaleTop, xPosRightSelector + selSpacing, yPosTimeScaleBottom)) {
      lockedRight = true;
      currPixelTimeMax = constrain(mouseX, timelineStart, timelineEnd);
      if (currPixelTimeMax < currPixelTimeMin + (2 * selSpacing)) currPixelTimeMax = currPixelTimeMin + (2 * selSpacing);  // prevents overstriking
    } else if (lockedMiddle || overRect(xPosLeftSelector - selSpacing, yPosTimeScaleTop, xPosRightSelector + selSpacing, yPosTimeScaleBottom)) {
      lockedMiddle = true;
      if (xPosLeftSelector >= timelineStart && xPosRightSelector <= timelineEnd) {
        int mouseChange = mouseX - pmouseX;
        if (xPosRightSelector != timelineEnd) currPixelTimeMin = constrain(currPixelTimeMin + mouseChange, timelineStart, timelineEnd);
        if (xPosLeftSelector != timelineStart) currPixelTimeMax = constrain(currPixelTimeMax + mouseChange, timelineStart, timelineEnd);
      }
    }
  }
}

class handleMapZoomKeys extends MouseHandler {
  void test() {
    if (mouseY < mapHeight-mapSpacing) map.zoomToLevel(map.getZoomLevel() + 1); // zoom out
    else if (mouseY > mapHeight-mapSpacing) map.zoomToLevel(map.getZoomLevel() - 1); // zoom in
  }
}

class handleAddFileKeys extends MouseHandler {
  void test() {
    textSize(keyTextSize);
    textAlign(LEFT);
    float xPos = mapSpacing/2;
    // Load Paths or Base Layers
    if (mouseX < xPos + textWidth("+ PATH    ")) {
      noLoop();
      selectInput("Select a file to process:", "pathFileSelected");
    } else if (mouseX < xPos + textWidth("+ PATH    + MAP LAYER    ")) {
      noLoop();
      selectInput("Select a file to process:", "baseLayerFileSelected");
    }
  }
}
