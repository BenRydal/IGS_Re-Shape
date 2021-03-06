class Keys {

  void drawKeys() {
    drawTimeScale();
    drawPathKeys();
    drawGroupKeys();
    drawMapLayerKeys();
    drawFileAddKeys();
    drawMapZoomKeys();
    drawDimensionKeys();
    drawInformationKeys();
    if (display_3D) drawSpaceTimeCubeKeys();
    if (display_4D) drawAltitudeKeys();
  }

  void drawMapZoomKeys() {
    fill(255);
    rect(mapSpacing/2, mapHeight-mapSpacing - mapSpacing/2, mapSpacing/2, mapSpacing);
    textAlign(CENTER);
    textSize(lrgTextSize);
    fill(0);
    text("+", mapSpacing/2 + mapSpacing/4, mapHeight-mapSpacing-mapSpacing/4.5);
    text("-", mapSpacing/2 + mapSpacing/4, mapHeight-mapSpacing/1.5);
  }

  void drawInformationKeys() {
    textAlign(LEFT);
    fill(255);
    textSize(lrgTextSize);
    if (overRect(width - textWidth(infoLabel + view_1 + view_2 + view_3 + view_4), yPosDimensionLablesTop, width - textWidth(view_1 + view_2 + view_3 + view_4), yPosDimensionLablesBottom)) welcome = true;
    else {
      welcome = false;
      text(infoLabel, width - textWidth(infoLabel + view_1 + view_2 + view_3 + view_4), yPosDimensionLables);
    }
  }

  void drawTimeScale() {
    // timeline selection rectangle
    fill(255, 150);
    noStroke();
    if (animateMode) rect(currPixelTimeMin, yPosTimeScale - tickHeight, animateTimeMax - currPixelTimeMin, 2 * (tickHeight));
    else rect(currPixelTimeMin, yPosTimeScale - tickHeight, currPixelTimeMax - currPixelTimeMin, 2 * (tickHeight));
    drawDates();
    // timeline
    strokeWeight(1);
    line(timelineStart, yPosTimeScale, timelineEnd, yPosTimeScale); // horizontal
    // Permanent lines at start/end of timeline
    stroke(250);
    strokeWeight(7); 
    line(timelineStart, yPosTimeScale - tickHeight, timelineStart, yPosTimeScale + tickHeight); 
    line(timelineEnd, yPosTimeScale - tickHeight, timelineEnd, yPosTimeScale + tickHeight);
    // Selector lines
    line(currPixelTimeMin, yPosTimeScale - tickHeight, currPixelTimeMin, yPosTimeScale + tickHeight); 
    line(currPixelTimeMax, yPosTimeScale - tickHeight, currPixelTimeMax, yPosTimeScale + tickHeight);
    line(currPixelTimeMax, yPosTimeScale - tickHeight, currPixelTimeMax, yPosTimeScale + tickHeight);
  }

  void drawDates() {
    fill(255);
    stroke(255);
    strokeWeight(3);
    textAlign(CENTER);
    textSize(lrgTextSize);
    float unixDisplayStampStart = map(currPixelTimeMin, timelineStart, timelineEnd, unixMin, unixMax); // gets you time/date stamp using max Unix value
    float unixDisplayStampEnd = map(currPixelTimeMax, timelineStart, timelineEnd, unixMin, unixMax); // gets you time/date stamp

    if (overRect(timelineStart, 0, timelineEnd, yPosGroupLablesBottom) || animateMode) {
      long setDisplayTime = 0L;
      if (animateMode) setDisplayTime = (long) map(animateTimeMax, currPixelTimeMin, currPixelTimeMax, unixDisplayStampStart, unixDisplayStampEnd);
      else setDisplayTime = (long) map(mouseX, timelineStart, timelineEnd, unixDisplayStampStart, unixDisplayStampEnd);
      Date date = new Date ();
      date.setTime(setDisplayTime*1000);
      SimpleDateFormat displayDate = new SimpleDateFormat("EEE, h:mm a");
      String formattedDate = displayDate.format(date);
      text(formattedDate, timeLineCenter, yPosFormattedDate);
    } else text("TIME", timeLineCenter, yPosFormattedDate);

    // Start/End Date stamps
    Date dateStart = new Date ();
    Date dateEnd = new Date ();
    dateStart.setTime((long)(unixDisplayStampStart) * 1000L); // add unixMin
    dateEnd.setTime((long)(unixDisplayStampEnd) * 1000L);  
    SimpleDateFormat displayDate = new SimpleDateFormat("EEE MM-dd h:mm a");
    String formattedDateStart = displayDate.format(dateStart);
    String formattedDateEnd = displayDate.format(dateEnd);
    textAlign(LEFT);
    text(formattedDateStart, timelineStart + mapSpacing/6, yPosFormattedDate);
    textAlign(RIGHT);
    text(formattedDateEnd, timelineEnd - mapSpacing/6, yPosFormattedDate);
    textAlign(LEFT); // reset
  }

  void drawPathKeys () {
    float xPosCurrPath = mapSpacing/2;
    fill(backgroundKeys);
    noStroke();
    rect(0, yPosPathKeysTop, width, height - yPosPathKeysTop); // student key rectangle
    textSize(keyTextSize);
    fill(255);
    strokeWeight(3);
    text("<", xPosCurrPath, yPospathKeys); 
    xPosCurrPath += pathKeySpacing/2;

    // loops through and draws text for paths and highlight lines below text
    for (int i = dispMult * pathDispNum; i <  dispMult * pathDispNum + pathDispNum; i++) {
      if (i < currGroup.group.size()) {
        Path currPath = currGroup.group.get(i);
        String studentName = currPath.name;
        text(studentName, xPosCurrPath, yPospathKeys); 
        if (currPath.isActive) {
          if (groupPathsMode) stroke(colorShades[currGroup.group.get(0).shadeNumber]); 
          else stroke(colorShades[currPath.shadeNumber]);
          line(xPosCurrPath, yPosPathKeysBottom, xPosCurrPath + textWidth(studentName), yPosPathKeysBottom);
        }
        xPosCurrPath += pathKeySpacing;
      }
    }
    fill(255);
    text(">", xPosCurrPath, yPospathKeys);
  }

  void drawGroupKeys() {
    textSize(keyTextSize);
    stroke(backgroundKeys);
    noStroke();
    float xPos = groupSpacing/2; // starting x position
    int groupNum = 0;
    for (Group g : groups) {
      if (g == currGroup) fill(backgroundKeys); // if active fill this color
      else fill(groupColor);
      rect(xPos, yPosGroupLablesBottom, groupSpacing, yPosGroupLablesTop - yPosGroupLablesBottom);
      if (groupNum == 0) {
        rect(0, yPosGroupLablesBottom, groupSpacing, yPosGroupLablesTop - yPosGroupLablesBottom);
        fill(255);
        text("GROUP", xPos, yPosGroupLables); // Base group with all paths
      } else {
        fill(255);
        textAlign(CENTER);
        text(groupNum, xPos + groupSpacing/2, yPosGroupLables);
      }
      xPos += groupSpacing;
      groupNum++;
    }
    stroke(0);
    strokeWeight(1);
    // +/- rectangles
    fill(180);
    rect(xPos, yPosGroupLablesBottom, groupSpacing/2, yPosGroupLablesTop - yPosGroupLablesBottom); // + rect
    rect(xPos + groupSpacing/2, yPosGroupLablesBottom, groupSpacing/2, yPosGroupLablesTop - yPosGroupLablesBottom); // - rect
    // +/- signs
    fill(0);
    // line(xPos + groupSpacing/6, (yPosGroupLablesTop - yPosGroupLablesBottom)/2, xPos + groupSpacing/3, (yPosGroupLablesTop - yPosGroupLablesBottom)/2);
    textAlign(CENTER);
    textSize(1.5 * lrgTextSize);
    text(" + ", xPos + groupSpacing/4, yPosGroupLables);
    text(" - ", xPos + groupSpacing/2 + groupSpacing/4, yPosGroupLables);
  }

  // add map pan to
  void drawFileAddKeys() {
    fill(255);
    stroke(255);
    textSize(keyTextSize);
    textAlign(LEFT);
    float xPos = mapSpacing/2;
    text("+ PATH", xPos, yPosFormattedDate);
    text("+ MAP LAYER", xPos + textWidth("+ PATH    "), yPosFormattedDate);
  }

  void drawMapLayerKeys() {
    fill(255);
    stroke(255);
    textSize(keyTextSize);
    textAlign(LEFT);
    float xPos = mapSpacing/2;
    text("<", xPos, yPosMapLayerKeys);
    xPos += pathKeySpacing/2;

    boolean layerIsRectified = false;
    boolean layerIsAdjusted = false;
    // for MapLayers that are showing
    for (int i = mapLayerDispMult * layerDispNum; i < (mapLayerDispMult * layerDispNum) + layerDispNum; i ++) {
      if (i < mapLayers.size()) { 
        MapLayer currLayer = mapLayers.get(i);
        if (currLayer.isActive) {
          fill(255);
          if (currLayer.geoRectified) layerIsRectified = true; // set to true if the layer is rectified
          if (adjustingMode) layerIsAdjusted = true;
        } else fill(50);
        text("Map " + i, xPos, yPosMapLayerKeys);
        xPos += pathKeySpacing;
      }
    }
    fill (255);
    text(">", xPos, yPosMapLayerKeys);
    // Rectify/Adjust
    fill(layerIsRectified ? 255: 50); // Georectify key
    text("Rectify", xPos + pathKeySpacing/2, yPosMapLayerKeys);
    fill(layerIsAdjusted ? 255: 50); // Georectify key
    text("Adjust", xPos + pathKeySpacing + textWidth("Rectify"), yPosMapLayerKeys);
    // Map Opacity Scrollbar Keys
    xPos += (pathKeySpacing/2 + pathKeySpacing + textWidth("AdjustRectify"));
    float opacityLineLength = textWidth("Transparency");
    // set opacity xPos positions for GUI methods
    mapOpacityCirXPos = map(mapOpacityLevel, 0, 255, xPos, xPos + opacityLineLength);
    mapOpacityXPosStart = xPos;
    mapOpacityXPosEnd = xPos + opacityLineLength;
    strokeWeight(2);
    fill(255);
    line(mapOpacityXPosStart, yPosMapLayerKeys, mapOpacityXPosEnd, yPosMapLayerKeys);
    text("Transparency", xPos, yPosMapLayerKeys - tickHeight);
    ellipse(mapOpacityCirXPos, yPosMapLayerKeys, mapOpacityCirSize, mapOpacityCirSize);
  }

  void drawDimensionKeys () {
    textSize(lrgTextSize);
    textAlign(LEFT);
    fill(display_1D ? 255: backgroundColor);
    text(view_1, width - textWidth(view_1 + view_2 + view_3 + view_4), yPosDimensionLables);
    fill(display_2D ? 255: backgroundColor);
    text(view_2, width - textWidth(view_2 + view_3 + view_4), yPosDimensionLables);
    fill(display_3D ? 255: backgroundColor);
    text(view_3, width - textWidth(view_3 + view_4), yPosDimensionLables);
    fill(display_4D ? 255: backgroundColor);
    text(view_4, width - textWidth(view_4), yPosDimensionLables);
  }

  void drawSpaceTimeCubeKeys() {
    textAlign(RIGHT);
    textSize(lrgTextSize);
    fill(255);
    strokeWeight(1);
    text("Time", timelineEnd - mapSpacing/2, mapSpacing);
    line(timelineEnd, yPosTimeScale - mapSpacing, timelineEnd, mapSpacing);
    line(timelineEnd - mapSpacing/4, mapSpacing + mapSpacing/4, timelineEnd, mapSpacing); // Left arrow
    line(timelineEnd + mapSpacing/4, mapSpacing + mapSpacing/4, timelineEnd, mapSpacing); // Right arrow
  }

  void drawAltitudeKeys() {
    textAlign(RIGHT);
    textSize(lrgTextSize);
    fill(255);
    strokeWeight(1);
    text("Altitude (" + int(altitudeMin) + "ft - " + int(altitudeMax) + "ft)", timelineEnd - mapSpacing/2, mapSpacing);
    line(timelineEnd, yPosTimeScale - mapSpacing, timelineEnd, mapSpacing);
    line(timelineEnd - mapSpacing/4, yPosTimeScale - mapSpacing, timelineEnd + mapSpacing/4, yPosTimeScale - mapSpacing); // Bottom tick
    line(timelineEnd - mapSpacing/4, mapSpacing, timelineEnd + mapSpacing/4, mapSpacing); // Top tick
  }
}
