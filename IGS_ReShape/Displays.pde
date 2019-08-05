class Display { // Display class has 3 sub-classes that organize drawing in 2D, 3D, and 4D. 

  void draw() {
  }

  // Sends correct Path from current group to draw
  void updateDrawData() {
    DrawData drawData = new DrawData();
    for (Path s : currGroup.group) {
      if (s.isActive) drawData.organizeDrawData(s);
    }
    if (animateMode) updateAnimation();
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
      translate(0, 0, mouseX-timelineStart);  // remaping time to these 2 lines will get the time slice
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
    clip(0, mapHeight/2, 2 * mapWidth, mapHeight);
    tint(255, 128);
    image(currLayer.image, mapWidth/2, mapHeight/2); // draw image at center of map
    noClip(); // reset all--very important for rest of program drawing
    noTint();
    imageMode(CORNER);
  }

  // Draw map image scaled/rectified to digital map
  void drawRectifiedMapImage(MapLayer currLayer) {
    imageMode(CORNERS); // set image mode, clip and tint for drawing the map
    clip(0, 0, mapWidth, mapHeight);
    if (adjustingMode) { // Adjusting mode is additional mode for refining a rectified map image
      tint(255, 128);
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

class Display_2D extends Display {

  void draw() {
    map.draw();
    super.updateMapImage();
    super.setKeys();
    super.updateDrawData();
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices();
  }
}

class Display_3D extends Display { 

  void draw() {
    super.setKeys();
    pushMatrix(); 
    translate(0, translateY, zoom);  
    rotateX(rotation);   
    map.draw();
    super.updateDrawData();
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices();
    popMatrix();
    if (rotation < PI/2.5) rotation +=.03; // animation between modes
    if (translateY < height/1.5) translateY +=10;
  }
}

class Display_4D extends Display { 

  void draw() {
    super.setKeys();
    pushMatrix(); 
    translate(0, translateY, zoom);  
    rotateX(rotation);   
    map.draw(); 
    super.updateDrawData();
    if (overRect(timelineStart, 0, timelineEnd, yPosTimeScale)) super.drawCursorSlices();
    popMatrix();
    if (rotation < PI/2.5) rotation +=.03;  // animation between modes
    if (translateY < height/1.5) translateY +=10;
  }
}
