float theta = 0.0;

void setup() {
  size(600, 600);
  smooth();
}

void draw() {
  background(255);

  // Increment theta (try different values for " angular velocity " here)
  //theta += 0.02;
  noStroke();
  fill(0);
  float x = theta;
  float yOffset = mouseY - height/2;
  if (yOffset == Float.NaN) {
    yOffset = 0;
  }
  yOffset  = yOffset / (height/2);
  //println()
  // A for loop is used to draw all the points along a sine wave (scaled to the pixel dimension of the window).
  for (int i = 0; i <= 200; i++) {
    // Calculate y value based off of sine function
    float y = sin(x*PI - (mouseX * PI/300) + asin(yOffset))*height/2;
    //println(yOffset + " " + asin(yOffset) + " " + y);
    // Draw an ellipse
    ellipse(i*3, y + height/2, 8, 8);
    // Move along x-axis
    x += 0.01;
  }
}

