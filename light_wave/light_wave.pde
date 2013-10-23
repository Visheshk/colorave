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
float[][] lastT = {{0, 0}, {1000, 1000}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}};
float frac = 1.0, yScale = 1.0; 
int[] loc = {-1, -1, -1, -1};

void setup()
{
  //size(screen.width,screen.height);
  size(640, 480);
  noStroke();
  fill(0);

  loop();
  frameRate(30);
  //noLoop();
  
  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
}

int findObj(Vector objList,int id){
  int iloc = -1;
  if (objList.size() >= 1 ){
    for (int i = 0; i < objList.size(); i++){
      TuioObject tob = (TuioObject)objList.elementAt(i);
      //println(tob.getSymbolID());
      if (tob.getSymbolID() == id){
        iloc = i;
        break;
      }
    }
  }
  return iloc;
}

void drawColor(){
  float R, G, B, A;
  float w = abs(700 * frac / 1.5);
  if (w >= 380 && w < 440){
    R = -(w - 440.0) / (440.0 - 380.0);
    G = 0.0;
    B = 1.0;
  }
  else if (w >= 440 && w < 490){
    R = 0.0;
    G = (w - 440.0) / (490.0 - 440.0);
    B = 1.0;
  }
  else if (w >= 490 && w < 510){
    R = 0.0;
    G = 1.0;
    B = -(w - 510.0) / (510.0 - 490.0);
  }
  else if (w >= 510 && w < 580){
    R = (w - 510.0) / (580.0 - 510.0);
    G = 1.0;
    B = 0.0;
  }
  else if (w >= 580 && w < 645){
    R = 1.0;
    G = -(w - 645.0) / (645.0 - 580.0);
    B = 0.0;
  }
  else if (w >= 645 && w <= 780){
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
  //colorMode();
  R *= abs(yScale)*sss;
  G *= abs(yScale)*sss;
  B *= abs(yScale)*sss;
  //fill(R*255, G*255, B*255, abs(yScale*255));
  fill(R*255, G*255, B*255);
  //println(w + " " + R + " " + G + " " + B);
  rect(0,50,200,40);
  fill(R*255, 0, 0);
  rect(450, 50, 40, 40);
  fill(0, G*255, 0);
  rect(500, 50, 40, 40);
  fill(0, 0, B*255);
  rect(550, 50, 40, 40);
  text(nf(255*R,3,2), 450, 40);
  text(nf(255*G,3,2), 500, 40);
  text(nf(255*B,3,2), 550, 40);
}

void makeSound(){
  
}

void sinWaveOne(float y1, float x1, float y2, float x2){
  noStroke();
  fill(0);
  float x = 0.0;
  float yOffset = y1 - height/2;
  if (yOffset == Float.NaN) {
    yOffset = 0;
  }
  yOffset  = yOffset / (height/2);
  
  if(x2 != 1000){
    frac = (x2 - x1) / width;
    frac *= 2;
    //println(x2 + " " + x1);
  }
  //println(frac);
  int dist = 3;
  for (int i = 0; i <= (width/dist); i++) {
    //float y = -1 * sin((x*PI - (x1 * PI/300) + asin(yOffset))/frac)*height/2;
    float y = -1 * yScale * sin((x*PI - (x1*2*PI/width))/frac)*height/2;
    ellipse(i*dist, y + height/2, 8, 8);
    // Move along x-axis
    x += 0.01;
  }
  drawColor();
  makeSound();
}

//produce sound

void drawBase(){
  //draw x axis -- done
  //draw projection of fiducials on x axis -- done
  //draw y height
  //write light wavelength above -- done
  //write sound wavelength below
  
  rect(0, height/2, width, 3); //axis
  fill(0);
  ellipse(lastT[0][0], height/2, 20, 20);
  if(loc[1] > -1)
    ellipse(lastT[1][0], height/2, 20, 20);
  if(loc[2] > -1)
    rect(0, lastT[2][1], width, 3);
  //light stuff
  float lightLambda = abs(700*frac) / 1.5;
 String wlength; 
  if (lightLambda < 380)
    wlength = "Ultraviolet";
  else if (lightLambda > 700)
    wlength = "Infrared";
  else
    wlength = "Wavelength: " + nf(lightLambda, 3, 2) + " nanometers";
  text(wlength, 450, 100);  // Default depth, no z-value specified
}

void draw(){
  
  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  stroke(0, 0, 0);
  fill(255);
  Vector tuioObjectList =  tuioClient.getTuioObjects();
  
  loc[0] = -1; loc[1] = -1;
  loc[0] = findObj(tuioObjectList, 1);
  if(loc[0] > -1){
    TuioObject neo = (TuioObject)tuioObjectList.elementAt(loc[0]);
    lastT[0][0] = neo.getScreenX(width);
    lastT[0][1] = neo.getScreenY(height);
    ellipse(lastT[0][0], lastT[0][1], 40, 40);
  }
  loc[1] = findObj(tuioObjectList, 2);
  if(loc[1] > -1){
    
    TuioObject wot = (TuioObject)tuioObjectList.elementAt(loc[1]);
    lastT[1][0] = wot.getScreenX(width);
    lastT[1][1] = wot.getScreenY(height);
    ellipse(lastT[1][0], lastT[1][1], 40, 40);
  }
  //println(lastT[0][1] + " " + lastT[0][0] + " " + lastT[1][1] + " " + lastT[1][0]);
  loc[2] = findObj(tuioObjectList, 3);
  if(loc[2] > -1){
      TuioObject top = (TuioObject)tuioObjectList.elementAt(loc[2]);
      lastT[2][1] = top.getScreenY(height);
      yScale = ((height/2) - lastT[2][1]) / (height/2);
  }
  if(loc[1] == -1){
    sinWaveOne(lastT[0][1], lastT[0][0], 1000, 1000);
  }
  else
    sinWaveOne(lastT[0][1], lastT[0][0], lastT[1][1], lastT[1][0]);
  
  drawBase();
  
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

