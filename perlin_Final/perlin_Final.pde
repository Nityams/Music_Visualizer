/*
@Author: Nityam Shrestha
@Author: Jameson Thai
Visualizer Credit: Daniel Shiffman
*/
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;

//2D Values
ArrayList circles = new ArrayList();
color c= color(0);
int counter = 0;

//Perlin 3D Terrain values
int cols, rows;
int scl =25;
int h = 1200;
int w = 2400;
float flying = 0;
float[][] terrain;
float z = 100;

// testing vars
int colorTest = 0;
int counterTest = 0;
int circleXRange;
int circleYRange;
int circleSize;
boolean change = true;
color perlinColor;
long startTime = System.nanoTime();
long endTime;

class FadingCircle {
  int x, y;
  int size;
  color c;
  int transparency;
  FadingCircle(int x, int y, int size) {
    this.size = size;
    this.x = x;
    this.y = y;
    c = color(random(360), random(360), random(360));
    transparency = 255;
  }
  void run() {
    if (transparency <= 4) { 
      transparency = 0;
    } else { 
      transparency -= 8;
    };
    noStroke();
    fill(c, transparency);
    ellipse(x, y, size, size);
  }
}

void setup()
{
  fullScreen(P3D);      
  cols = w/scl;
  rows = h/scl;
  terrain = new float[cols][rows];

  //Audio 
  minim = new Minim(this);

  song = minim.loadFile("lights.mp3", 1024);
  song.play();
  fft = new FFT(song.bufferSize(), song.sampleRate());
}


void draw() {
  flying -= 0.08; 
  float yoff = flying;
  for (int y = 0; y<rows; y++) {
    float xoff = 0;

    for (int x =0; x< cols; x++) {
      terrain[x][y] = map(noise(xoff, yoff ), 0, 1, -100, z);  //-150 used
      xoff += 0.2;
    }
    yoff += 0.2;
  }
  background(0);

  if (change) {
    c = color(random(110,200), random(110,200), random(100,200));
    change = false;
  }
 
  stroke(150);   
  fill(c, 150);
  translate(width/2, height/2 + 50);
  rotateX(PI/3);  
  translate(-w/2, -h/2);

  for (int y = 0; y<rows-1; y++) {
    beginShape(TRIANGLE_STRIP);  
    for (int x =0; x< cols; x++) {
      vertex(x*scl, y*scl, terrain[x][y]);
      vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
    }
    endShape();
  }


  // 2D elements setup
  rotateX(-PI/3);  // anti-PI/3
  int ht = height;
  int wt = width;
  translate(wt, ht);

  // Add background rectangle here
  fill(c, counter);
  noStroke();
  rect(-wt, -ht*2, wt * 100, ht * 100); 

  // Circle ready
  fft.forward(song.mix);
  for (int i=0; i<circles.size(); i++) {
    FadingCircle fc = (FadingCircle) circles.get(i);
    fc.run();
  }

  // Display range for circles
  circleXRange = (int)random(-wt/2, wt + wt/2);   // [-wt/2, wt + wt/2 ]
  circleYRange = (int)random(ht, (ht+ ht/2)) ; // [ -ht , -(ht+ ht/2)] 
  circleSize = (int)random(10, 25);
  
  int initSize = circles.size();

  //WaveForm
  stroke(random(200),random(200),random(200));
  for (int i = 0; i < song.bufferSize() - 1; i++)
  {
    line(i-wt+200, -ht-200 + song.mix.get(i)*50, i+1-wt+200, -ht-200 + song.left.get(i+1)*50); 
    line(i-wt/2+600, -ht-200 + song.mix.get(i)*50, i+1-wt/2+600, -ht-200 + song.right.get(i+1)*50);
  }

  //AUDIO
  for (int i = 0; i < fft.specSize(); i++)
  {
    float band = fft.getBand(i); 
    // Bass + subBass
    if (i < 11 && band > 120) {
       fill(255, 130, 42);
        ellipse(-wt/1.5,-ht, band, band);
    }
    //Low-Mid
    else if (i >=17 && i < 75 && band > 50) {
      circles.add(new FadingCircle(circleXRange, -circleYRange, 12));
    }
    // High-Mid
    else if (i >= 75 && band > 13) {// 17 -> 50
      circles.add(new FadingCircle(circleXRange, -circleYRange, circleSize));
    }
    else
    {
      // do something else
    }
  }

  if (circles.size() - initSize > 12) {
    endTime = System.nanoTime();
   
    if (endTime - startTime >= 200000000) //2 sec
    {
      println((endTime - startTime)/1000000000 );
      c = color(random(200), 100, random(200));  
      counter = 255;
      startTime = System.nanoTime();
    }
  }

  if (counter <=3) counter = 0;
  else counter-=3;
}

// AUDIO Stop
void stop() {  
  song.close(); // always close Minim audio classes when you are finished with them
  println("stopeed");
  minim.stop(); // always stop Minim before exiting
  super.stop(); // this closes the sketch
}