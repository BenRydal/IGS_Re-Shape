class Display { // Display class has 3 sub-classes that organize drawing in 2D, 3D, and 4D. 

  void draw() {
  }

  // Sends correct Path from current group to draw
  void updateDrawData() {
    DrawData drawData = new DrawData();
    // Don't use shorthand for loop, due to how selectInput works in Processing it can throw concurrentMod error  
    for (int i = 0; i < currGroup.group.size(); i++) {
      Path s = currGroup.group.get(i); 
      if (s.isActive) drawData.organizeDrawData(s);
    }
    if (animateMode) updateAnimation();
  }

  // Rescales time and altitude scales
  void reScaleData() {
    // reset values
    unixMin = 0L; 
    unixMax = 0L; 
    altitudeMin = 0f; 
    altitudeMax = 0f; 

    // Loop through all points in each path if showing and either use set starting values or compare values methods
    for (Path s : currGroup.group) {
      if (s.isActive) {
        for (int i = 0; i <= s.path.size() -1; i++) {
          Point point = s.path.get(i); 
          if (unixMin == 0) setStartingValues(point.time, point.altitude, locationToStart.x, locationToStart.y); // if 1st point set starting values for comparison
          else compareValues(point.time, point.altitude); // else compare values to previous min/max values
        }
      }
    }
    reScaleValues = false; // reset
  }

  // Updates min/max values for animation and ends animation when complete
  void updateAnimation() {
    if (animateTimeMax <= currPixelTimeMax) animateTimeMax+= animateSpeed; // incrents animation if active/still running
    else animateMode = !animateMode; // turn animation off when completed
  }

  // Creates/sets keys
  void setKeys() {
    Keys keys = new Keys(); 
    keys.drawKeys();
  }

  // Draws mouse/cursor slicer/selector depending on 2D, 3D, 4D view
  void drawCursorSlices() {    
    stroke(255); 
    strokeWeight(4); 
    if (display_2D) line(mouseX, 0, mouseX, yPosTimeScale); 
    else if (display_3D) {
      fill(50, 200); 
      translate(0, 0, mouseX-timelineStart); // remaping time to these 2 lines will get the time slice
      rect((width - 2*mapWidth)/2, 0, mapWidth * 2, mapHeight);
    } else if (display_4D) {
      fill(50, 200); 
      rotateY(-PI/2); 
      translate(0, 0, -mouseX); 
      rect(0, 0, mapWidth * 1.5, mapHeight);
    }
  }

  // Loops through all map images and draws one layer at a scale depending on modes
  void updateMapImage() {
    for (int i = mapLayerDispMult * layerDispNum; i < mapLayers.size(); i ++) {
      MapLayer currLayer = mapLayers.get(i); 
      if (currLayer.isActive) { // if the layer is selected
        if (!currLayer.geoRectified) drawMapImage(currLayer); 
        else drawRectifiedMapImage(currLayer);
      }
    }
  }

  // Draw map image scaled to screen
  void drawMapImage(MapLayer currLayer) {
    imageMode(CENTER); // set image mode, clip and tint for drawing the map
    tint(255, mapOpacityLevel); // tint at level adjusted in GUI
    if (display_1D) {
      clip(width/2, mapHeight/2, width, mapHeight); 
      image(currLayer.image, width/2, mapHeight/2); // draw image at center of map
    } else if (display_2D) {
      clip(0, mapHeight/2, 2 * mapWidth, mapHeight); 
      image(currLayer.image, mapWidth/2, mapHeight/2); // draw image at center of map
    }
    noClip(); // reset all--very important for rest of program drawing
    noTint(); 
    imageMode(CORNER);
  }

  // Draw map image scaled/rectified to digital map
  void drawRectifiedMapImage(MapLayer currLayer) {
    imageMode(CORNERS); // set image mode, clip and tint for drawing the map
    if (display_1D) clip(0, 0, width, mapHeight); 
    else if (display_2D) clip(0, 0, mapWidth, mapHeight); 
    if (adjustingMode) { // Adjusting mode is additional mode for refining a rectified map image
      tint(255, mapOpacityLevel); // tint at level adjusted in GUI
      image(currLayer.image, currLayer.adjustingTopCorner.x, currLayer.adjustingTopCorner.y, currLayer.adjustingBottomCorner.x, currLayer.adjustingBottomCorner.y); 
      noTint(); // reset
    } else {
      ScreenPosition rectifiedTopCorner = map.getScreenPosition(currLayer.rectifiedTopCorner); 
      ScreenPosition rectifiedBottomCorner = map.getScreenPosition(currLayer.rectifiedBottomCorner); 
      image(currLayer.image, rectifiedTopCorner.x, rectifiedTopCorner.y, rectifiedBottomCorner.x, rectifiedBottomCorner.y);
    }
    noClip(); // reset
    imageMode(CORNER);
  }
}

class Display_1D extends Display {

  void draw() {
    if (reScaleValues) super.reScaleData(); 
    map.draw(); 
    super.updateMapImage(); 
    super.setKeys(); 
    if (!welcome) super.updateDrawData();
  }
}

class Display_2D extends Display {

  void draw() {
    if (reScaleValues) super.reScaleData(); 
    map.draw(); 
    super.updateMapImage(); 
    super.setKeys(); 
    if (!welcome) super.updateDrawData(); 
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices();
  }
}

class Display_3D extends Display { 

  void draw() {
    if (reScaleValues) super.reScaleData(); 
    super.setKeys(); 
    pushMatrix(); 
    translate(0, translateY, zoom); 
    rotateX(rotation); 
    map.draw(); 
    if (!welcome) super.updateDrawData(); 
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices(); 
    popMatrix(); 
    if (rotation < PI/2.5) rotation +=.03; // animation between modes
    if (translateY < height/1.5) translateY +=10;
  }
}

class Display_4D extends Display { 

  void draw() {
    if (reScaleValues) super.reScaleData(); 
    super.setKeys(); 
    pushMatrix(); 
    translate(0, translateY, zoom); 
    rotateX(rotation); 
    map.draw(); 
    if (!welcome) super.updateDrawData(); 
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices(); 
    popMatrix(); 
    if (rotation < PI/2.5) rotation +=.03; // animation between modes
    if (translateY < height/1.5) translateY +=10;
  }
}
