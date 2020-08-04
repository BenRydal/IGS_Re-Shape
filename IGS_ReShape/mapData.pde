class DrawData {

  int bugSpacingComparison = PRECISION; // initial value to draw a single most precise "bug"
  int bugPointToDraw = 0; // Initial value that selects arraList position to draw bug 
  int bugAnimateCounter = 0; // Counter holds value to draw bug if in animate mode

  // Organizes drawing of Path object and "bug" or location on the map of a selected point on a Path by a user
  void organizeDrawData(Path s) {
    setLineStyle(s);
    resetBug();
    drawCurve(s, SPACE);
    if (!display_1D) drawCurve(s, SPACETIME); // don't draw space-time for 1D view
    if (animateMode && bugAnimateCounter != 0) drawBug(s.path.get(bugAnimateCounter), s.shadeNumber);
    else if (bugPointToDraw != 0) drawBug(s.path.get(bugPointToDraw), s.shadeNumber); // draw single bug for each path
  }

  // Sets line color, weight etc.
  void setLineStyle(Path s) {
    noFill(); // necessary for drawing paths
    strokeWeight(WEIGHT);
    if (groupPathsMode) stroke(colorShades[currGroup.group.get(0).shadeNumber]); // set color to 1st path of group
    else stroke(colorShades[s.shadeNumber]); // or set color to current path color
  }

  // Reset bug for each line drawn
  void resetBug() {
    bugSpacingComparison = PRECISION; // initial value to draw a single most precise "bug"
    bugPointToDraw = 0; // Initial value that selects arraList position to draw bug 
    bugAnimateCounter = 0; // Counter holds value to draw bug if in animate mode
  }

  void drawCurve (Path s, int view) {  
    boolean drawVertex = false; // Controls drawing of vertices for points and beginning/ending curves
    float priorTime = 0f;  // Holders for prior values of points for comparison
    ScreenPosition priorPos = new ScreenPosition(0, 0);
    // Loops through and tests each point in path array to draw different types of curves
    for (int i = 0; i <= s.path.size() -1; i++) {
      Point point = s.path.get(i); // get point and remap time/altitude values to timeline pixel scale
      ScreenPosition pos = map.getScreenPosition(point.location);
      float timeInPixels = map(point.time - unixMin, 0, unixMax-unixMin, timelineStart, timelineEnd);
      float altitudeInPixels = map(point.altitude, altitudeMin, altitudeMax, 0, height - mapSpacing); // corresponds with altitude keys
      // For first point use same values for prior time/pos
      if (i == 0) {
        priorTime = timeInPixels;
        priorPos = pos;
      }
      // Tests if point should be displayed and adjusts curve drawing/begin and end shape accordingly
      if (overMap(pos) && overTimeline(timeInPixels) && removeBadData(pos, timeInPixels, priorPos, priorTime)) {
        if (!drawVertex) {
          beginShape();
          drawVertex = true;
        }
      } else {
        if (drawVertex) {
          endShape();
          drawVertex = false;
        }
      }

      priorTime = timeInPixels; // set new prior time/pos values
      priorPos = pos;

      if (drawVertex) {
        float [] vertexPos = setCoordinates(view, pos, timeInPixels, altitudeInPixels); // get correct coordinates for drawing
        vertex(vertexPos[0], vertexPos[1], vertexPos[2]); 
        // Test/set bug values
        if (view == SPACETIME && animateMode) bugAnimateCounter = i;
        else if (view == SPACETIME && overRect(timelineStart, 0, timelineEnd, height)) calculateBug(vertexPos[3], i, bugSpacingComparison);
      }
    }
    if (drawVertex) endShape();  // End curve shape if needed
  }

  // Sets coordinates depending on view and display
  float[] setCoordinates(int view, ScreenPosition pos, float timeInPixels, float altitudeInPixels) {
    float xPos = 0f;
    float yPos = pos.y;
    float zPos = 0f;
    float scaledTimeInPixels = 0f;

    if (view == SPACE) { 
      xPos = pos.x;
      if (display_1D || display_2D || display_3D) zPos = 0;
      else if (display_4D) zPos = altitudeInPixels;
    } else if (view == SPACETIME) {
      scaledTimeInPixels = map(timeInPixels, currPixelTimeMin, currPixelTimeMax, timelineStart, timelineEnd);
      if (display_2D) {
        xPos = scaledTimeInPixels;  
        zPos = 0;
      } else if (display_3D) {
        xPos = pos.x;
        zPos = scaledTimeInPixels - timelineStart;
      } else if (display_4D) {
        xPos = scaledTimeInPixels;
        zPos = altitudeInPixels;
      }
    } 
    float[] vertexPos = {xPos, yPos, zPos, scaledTimeInPixels};
    return vertexPos;
  }

  // Tests if distance from mouse to bug is less than previous ones and sets new bug values if so
  void calculateBug(float time, int newBugPoint, int currbugSpacingComparison) { 
    int tempDistance = int(abs(time - mouseX));
    if (tempDistance < currbugSpacingComparison) {
      bugSpacingComparison = tempDistance;
      bugPointToDraw = newBugPoint;
    }
  }
  // Draws bug with correct color and coordinates
  void drawBug(Point point, int shadeNumber) {
    if (groupPathsMode) shadeNumber = currGroup.group.get(0).shadeNumber;
    ScreenPosition pos = map.getScreenPosition(point.location);
    float timeInPixels = map(point.time, unixMin, unixMax, timelineStart, timelineEnd);
    float altitudeInPixels = map(point.altitude, altitudeMin, altitudeMax, 0, height - mapSpacing);
    float [] zPos = setCoordinates(SPACETIME, pos, timeInPixels, altitudeInPixels);
    strokeWeight(4);
    stroke(0);
    fill(colorShades[shadeNumber]);
    ellipse (pos.x, pos.y, 30, 30);
    strokeWeight(2);
    line(pos.x, pos.y, 0, pos.x, pos.y, zPos[2]);
  }

  boolean overMap(ScreenPosition pos) {
    float mapXposLeft = 0f;
    float mapXPosRight = 0f;
    if (display_1D) {
      mapXposLeft = 0;
      mapXPosRight = width;
    } else if (display_2D) {
      mapXposLeft = 0;
      mapXPosRight = mapWidth;
    } else if (display_3D) {
      mapXposLeft = 0;
      mapXPosRight = width;
    } else if (display_4D) {
      mapXposLeft = -mapWidth;
      mapXPosRight = mapWidth;
    }
    if (pos.x > mapXposLeft && pos.x < mapXPosRight && pos.y > 0 && pos.y < mapHeight) return true;
    else return false;
  }

  boolean overTimeline (float time) {
    if (animateMode) {
      if (time >= animateTimeMin && time <= animateTimeMax) return true;
      else return false;
    } else {
      if (time >= currPixelTimeMin && time <= currPixelTimeMax) return true;
      else return false;
    }
  }

  boolean removeBadData(ScreenPosition pos, float currentTime, ScreenPosition posPrior, float priorTime) {
    if (!cleanData) return true; // don't remove any data 
    else {
      if (currentTime < priorTime + PRECISION && (pos.x > posPrior.x - PRECISION && pos.x < posPrior.x + PRECISION) && (pos.y > posPrior.y - PRECISION && pos.y < posPrior.y + PRECISION)) return true;
      else return false;
    }
  }
}
