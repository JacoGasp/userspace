import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;

int numOfBalls = 16;
int numOfBands = numOfBalls * numOfBalls;
int rad = 5;
float margin = 2 * rad + 60;

Vertice punti[][];

float side = numOfBalls * rad + numOfBalls * margin;

float smoothPeaks[] = new float[numOfBands];
float oldPeaks[] = new float[numOfBands];

PShape grid;

void setup() {
  //size(640, 360, P3D);
  //size(1280, 800, P3D);
  frameRate(60);
  fullScreen(P3D);
  pixelDensity(displayDensity());
  smooth(4);
  noCursor();

  noStroke();
  grid = createShape(GROUP);
  fill(255);
  setupAudio();
  drawShape();
  for (int i = 0; i < numOfBands; i++) {
    smoothPeaks[i] = 0.0;
    oldPeaks[i] = 0.0;
  }
}
void draw() {
  camera(width * sin(frameCount*0.001) , height/2.0 * cos(frameCount*0.002), (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  background(40);
  noStroke();
  fft.forward(song.mix);
  fft.linAverages(numOfBands);

  pushMatrix();
  translate(width/ 2 + -155, height/2 + 219, -803);
  rotateY(2 * 0.05);
  rotateX(31 * 0.05);
  rotateZ(-240 * 0.05);

  shape(grid);
  for (int i = 0; i < grid.getChildCount(); i ++) {
    PShape ball;
    ball = grid.getChild(i);
    float currentPeak = 100 * log(fft.getBand(i) * 4 +1);
    smoothPeaks[i] += (currentPeak - smoothPeaks[i]) * 0.2;
    float peak = smoothPeaks[i] - oldPeaks[i];
    ball.translate(0, 0, peak);
    oldPeaks[i] = smoothPeaks[i];
  }
  drawLines(smoothPeaks);
  popMatrix();
  //saveFrame();
}

void drawShape() {
  punti = new Vertice[numOfBalls][numOfBalls];
  for (int j = 0; j < numOfBalls; j++){
     for(int k = 0; k < numOfBalls; k++) {
      PShape sphere = createShape(SPHERE, rad);
      float x = j * margin;
      float y = k * margin;
      punti[j][k] = new Vertice(x, y, 0);
      sphere.translate(x, y, 0);
      grid.addChild(sphere);
    }
  }
  print(grid.getChildCount());
}

void drawLines(float peaks[]) {
stroke(255);
int i = 0;
for (int j = 0; j < numOfBalls; j++) {
  for (int k = 0; k < numOfBalls; k++) {
    Vertice currentPoint = punti[j][k];
    if (k >= 1) {
      Vertice oldPoint2 = punti[j][k-1];
      line(oldPoint2.x, oldPoint2.y, oldPoint2.z, currentPoint.x, currentPoint.y, peaks[i]);
    }
    if (j >= 1) {
      Vertice oldPoint = punti[j-1][k];
      line(oldPoint.x, oldPoint.y, oldPoint.z, currentPoint.x, currentPoint.y, peaks[i]);
    }

    punti[j][k] = new Vertice(currentPoint.x, currentPoint.y, peaks[i]);
    i++;
    }
  }
}

void setupAudio() {
  minim = new Minim(this);
  String filePath = dataPath("Userspace.mp3");
  song = minim.loadFile(filePath);
  song.play();
  fft = new FFT(song.bufferSize(), song.sampleRate());
}

class Vertice {
  float x, y, z;
  Vertice(float tempX, float tempY, float tempZ) {
    x = tempX;
    y = tempY;
    z = tempZ;
  }
}
