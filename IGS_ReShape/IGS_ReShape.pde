/*
This software is a simplified version of the Interaction Geography Slicer (IGS) visualization tool that runs in Processing customized for the Re-Shape learning environment.
 
 TO RUN THIS PROGRAM:
 1) Please download the most recent version of Processing at: https://processing.org/download/
 2) Place the folder titled "Unfolding" included in this repository within your processing "libraries" folder (located within the Processing folder on your computer). Unfolding is a wonderful mapping Library developed by Till Nagel & contributers (see credits below).
 3) Visit this link to understand how to collect and properly format data: https://www.benrydal.com/re-shape
 4) Open any file in the IGS_ReShape folder in Processing
 
 CREDITS/LICENSE INFORMATION: This software is licensed under the GNU General Public License Version 2.0. See the GNU General Public License included with this software for more details. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 This software makes use of the Unfolding Maps Library developed at the Interaction Design Lab, FH Potsdam, the HCI group, KU Leuven, and MIT Senseable City Labs. Copyright (C) 2015 Till Nagel, and contributors. See http://unfoldingmaps.org/contact.html
 IGS software was originally developed by Ben Rydal Shapiro at Vanderbilt University as part of his dissertation titled Interaction Geography & the Learning Sciences. Copyright (C) 2018 Ben Rydal Shapiro, and contributers. To reference or read more about this work please see: https://etd.library.vanderbilt.edu/available/etd-03212018-140140/unrestricted/Shapiro_Dissertation.pdf
 */

import java.util.List;
import java.io.File;
import java.util.TimeZone;
import java.util.Arrays;
import java.util.Date;
import java.text.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.data.*;

// ------ DATA ------
List<Group> groups = new ArrayList(); // Holder for Groups/set of Path objects, a base group is created on program start up
Group currGroup; // Current group of paths that is displayed
List<MapLayer> mapLayers = new ArrayList(); // Holder for map images/may layers
String [] dateStringsToTest = {"yyyy-MM-dd HH:mm:ss", "MM/dd/yy HH:mm", "MM/dd/yyyy HH:mm"}; // Date stamp in data/CSV file MUST match one of these date strings
long unixMin = 0L, unixMax = 0L; // Values for min/max datestamps converted into Unix time 
float altitudeMin = 0f, altitudeMax = 0f;
float animateSpeed = 0.1f, animateTimeMin = 0f, animateTimeMax = 0f; // Path animation speed

// ------ MAP ------
UnfoldingMap map;
AbstractMapProvider provider = new Microsoft.RoadProvider(); // map tile provider
// AbstractMapProvider provider = new Google.GoogleMapProvider();
// AbstractMapProvider provider = new StamenMapProvider.TonerBackground();
Location locationToStart = new Location(40.730610, -73.935242);  // Starting location if no data is loaded
float mapWidth, mapHeight, mapSpacing;
int zoom; // controls zoom position of drawing in 3D/4D

// ------ TIMELINE ------
float timelineStart, timelineEnd, timelineLength, tickHeight; // pixel values for timeline
float currPixelTimeMin = 0, currPixelTimeMax = 0; // user/GUI adjustable pixel values for timeline

// ------ GUI ------
String infoLabel = "* Information    ", view_1 = "Map    ", view_2 = "Space-Time    ", view_3 = "3D Cube    ", view_4 = "4D Cube    "; // Info/view labels
String groupSpacingText = "GROUP:      ", pathKeySpacingText = "Path"; // Text spacing for group/path key labeles
PFont font;
int lrgTextSize, keyTextSize;
int dispMult = 0, mapLayerDispMult = 0, pathDispNum, layerDispNum;  // Display multipliers for GUI
boolean startingMessage = true; // Controls welcome message showing on program start up
boolean welcome = true; // Controls welcome message/information on hover
PImage welcomeScreen;
int welcomeAnimation = 0;  // Controls fading for welcome screen
boolean display_1D = true, display_2D = false, display_3D = false, display_4D = false;  // 4 Views
boolean lockedLeft = false, lockedRight = false, lockedMiddle = false, groupPathsMode = false, selectAllPathsMode = false, adjustingMode = false, animateMode = false, changeColorMode = false, cleanData = true;
float startingHeightKeys, yPosTimeScale, yPosTimeScaleTop, yPosTimeScaleBottom, timeLineCenter, yPosDimensionLables, yPosDimensionLablesTop, yPosDimensionLablesBottom, yPosMapLayerKeys, yPosMapLayerKeysTop, yPosMapLayerKeysBottom, yPospathKeys, yPosPathKeysTop, yPosPathKeysBottom, yPosGroupLables, yPosGroupLablesTop, yPosGroupLablesBottom, groupSpacing, pathKeySpacing;
float rotation = 0f, translateY = 0f; // For switching from 2D to 3D views

// ------ COLORS ------
int backgroundKeys = 33, backgroundColor = 150, groupColor = 80, colorShadeNumber = 11;  // Number of path colors
// color codes (d/l indicate dark or light) dOrange, dGreen, lBlue, dRed, lYellow, dBrown, lOrange, lGreen, dPurple, lRed, lBlue, lPurple
color [] colorShades = {#ff7f00, #33a02c, #a6cee3, #e31a1c, #ffff99, #b15928, #fdbf6f, #b2df8a, #6a3d9a, #fb9a99, #cab2d6};

// ------ CONSTANTS ------
int PRECISION = 100; // For cleaning path data. The lower the value the more bad data is removed.
int WEIGHT = 3;   // line weight for drawing paths
int SPACE = 1, SPACETIME = 2; // 2 views

void setup() {
  println("IGS_Re-Shape v0.2.0");
  fullScreen(P3D);
  pixelDensity(2); // enable for high resolution screens but program will run slower
  font = loadFont("data/misc/Helvetica-24.vlw");
  textFont(font);
  welcomeScreen = loadImage("data/misc/welcome.png");
  loadData();
}

void draw() {
  background(backgroundColor);
  Display display; // 4 display sub classes depending on view
  if (display_1D) display = new Display_1D();
  else if (display_2D) display = new Display_2D();
  else if (display_3D) display = new Display_3D();
  else display = new Display_4D();
  display.draw();
  setWelcomeScreen();
}

void setWelcomeScreen() {
  if (startingMessage) welcome = true; // always draw welcome screen on program start up
  // Determine fade in/out and send to draw welcome screen scaled to window 
  if (welcome) {
    if (welcomeAnimation < 200) welcomeAnimation +=10;
    drawWelcomeScreen();
  } else {
    if (welcomeAnimation > 0) {
      welcomeAnimation -=10;
      drawWelcomeScreen();
    }
  }
}

void drawWelcomeScreen() {
  imageMode(CENTER);
  tint(255, welcomeAnimation); 
  int imageRatio = welcomeScreen.width/welcomeScreen.height;
  if (pixelWidth > welcomeScreen.width) image(welcomeScreen, width/2, height/2, welcomeScreen.width/2, welcomeScreen.height/2);
  else image(welcomeScreen, width/2, height/2, width * imageRatio, height * imageRatio);
  imageMode(CORNER);
  noTint();
}
