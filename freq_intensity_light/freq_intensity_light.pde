// we need to import the TUIO library
// and declare a TuioProcessing client variable
import TUIO.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
Boolean draw;
TuioObject tobj[];
float[] tot = {0, 0, 0};
float[][] lastT = {
  {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
};
Vector objList;
float[][] w = {
  {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
  , {
    0, 0
  }
};
float[][] colors = {
  {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
  , {
    0, 0, 0
  }
};
int[] loc = {
  -1, -1, -1, -1
};

void setup()
{
  //size(screen.width,screen.height);
  size(800, 480);
  noStroke();
  fill(0);
  
  loop();
  frameRate(30);
  //noLoop();

  font = createFont("Helvetica", 23);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
}

void drawColor(float w, float intensity, int i) {
  float R, G, B, A;
  
  if (w >= 380 && w < 440) {
    R = -(w - 440.0) / (440.0 - 380.0);
    G = 0.0;
    B = 1.0;
  }
  else if (w >= 440 && w < 490) {
    R = 0.0;
    G = (w - 440.0) / (490.0 - 440.0);
    B = 1.0;
  }
  else if (w >= 490 && w < 510) {
    R = 0.0;
    G = 1.0;
    B = -(w - 510.0) / (510.0 - 490.0);
  }
  else if (w >= 510 && w < 580) {
    R = (w - 510.0) / (580.0 - 510.0);
    G = 1.0;
    B = 0.0;
  }
  else if (w >= 580 && w < 645) {
    R = 1.0;
    G = -(w - 645.0) / (645.0 - 580.0);
    B = 0.0;
  }
  else if (w >= 645 && w <= 780) {
    R = 1.0;
    G = 0.0;
    B = 0.0;
  }
  else{
    R = 0.0;
    G = 0.0;
    B = 0.0;
  }
  float sss = 1;
  if(w >= 700){
    sss = 0.3 + 0.7 * (780.0 - w) / (780.0 - 700.0);  
  }
  else if (w <= 420){
    sss = 0.3 + 0.7 * (w - 380.0) / (420.0 - 380.0);
  }
  //float gamma;
  R *= sss; G *= sss; B *= sss;
  //colorMode();
  intensity = abs(1 - (2 * intensity)/height);
  //R *= intensity; G *= intensity; B *= intensity;
  fill(R*255, G*255, B*255);
  colors[i][0] = R*255;
  colors[i][1] = G*255;
  colors[i][2] = B*255;
  
  for(int j = 0; j < 3; j++){
    tot[j] += colors[i][j];
    if (tot[j] > 255)
      tot[j] = 255;
  }
  
}


void drawAxis() {

}

void totalColor() {
  fill(tot[0], tot[1], tot[2], 255);
  rect(0, 2 * height / 3, width, 10);
  //for()
  fill(0);
  text(tot[0] + " " + tot[1] + " " + tot[2], 20, height - 100);
}

void drawBar(int i) {
  drawColor(lastT[i][0], lastT[i][1], i);
  rect(lastT[i][0] - 20, height/2, 40, (lastT[i][1] - (height/2)));
}

void getPos() {
  for (int i = 0; i < objList.size(); i++) {
    TuioObject tob = (TuioObject)objList.elementAt(i);
    lastT[i][0] = tob.getScreenX(width);
    lastT[i][1] = tob.getScreenY(height);
    fill(0);
    ellipse(lastT[i][0], lastT[i][1], 40, 40);
    fill(255);
    text(lastT[i][0], lastT[i][0] - 15, lastT[i][1]);
    drawBar(i);
    //print(i + " ");
  }
  totalColor();
  //print("\n");
}

void draw() {

  background(255);
  textFont(font, 18*scale_factor);
  //float obj_size = object_size*scale_factor; 
  //float cur_size = cursor_size*scale_factor; 
  stroke(0, 0, 0);
  fill(0);
  objList =  tuioClient.getTuioObjects();
  rect(0, height/2, width, 3); //axis
  tot[0] = 0; tot[1] = 0; tot[2] = 0;
  
  getPos(); //get the positions of the tuioObjects
  drawAxis(); //draw the axes, ideally label frequency and intensity
  //drawBars(objList); //draw a bar beneath each fiducial
  //totalColor();
}


// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) {
}

