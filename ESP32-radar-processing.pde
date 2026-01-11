import processing.serial.*;

Serial myPort;

int angle = 0;
int distance = 0;

int radarRadius;
int maxRange = 30;   // MAX RANGE IN CM

// GREEN SCAN SETTINGS
int greenFanWidth = 30;
int greenLineWeight = 3;

// RED DETECTION SETTINGS
int redFanWidth = greenFanWidth / 2;
int redLineWeight = 3;

void setup() {
  fullScreen();      // CORRECT FUNCTION
  smooth(8);

  // Radar radius scales with screen height
  radarRadius = height - 80;

  // CHANGE TO YOUR SERIAL PORT
  myPort = new Serial(this, "COM4", 115200);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);

  // Radar origin = bottom-center
  translate(width / 2, height - 20);

  drawRadar();
  drawSweepFan();
  drawObjectLine();
}

void serialEvent(Serial myPort) {
  String data = myPort.readStringUntil('\n');
  if (data != null) {
    data = trim(data);
    String[] values = split(data, ',');
    if (values.length == 2) {
      angle = int(values[0]);
      distance = int(values[1]);
    }
  }
}

void drawRadar() {
  stroke(0, 255, 0);
  noFill();

  // Range arcs (every 10 cm)
  for (int r = 10; r <= maxRange; r += 10) {
    float mappedR = map(r, 0, maxRange, 0, radarRadius);
    arc(0, 0, mappedR * 2, mappedR * 2, PI, TWO_PI);
  }

  // Angle reference lines
  for (int a = 0; a <= 180; a += 30) {
    float x = radarRadius * cos(radians(a));
    float y = radarRadius * sin(radians(a));
    line(0, 0, x, -y);
  }
}

void drawSweepFan() {
  for (int i = 0; i < greenFanWidth; i++) {
    float fade = map(i, 0, greenFanWidth, 255, 20);
    stroke(0, 255, 0, fade);
    strokeWeight(greenLineWeight);

    float a = angle - i;
    float x = radarRadius * cos(radians(a));
    float y = radarRadius * sin(radians(a));
    line(0, 0, x, -y);
  }
}

void drawObjectLine() {
  if (distance > 0 && distance <= maxRange) {

    float scaledDist = map(distance, 0, maxRange, 0, radarRadius);
    float lineLength = 25;

    // Center red inside green scan
    int startOffset = (greenFanWidth - redFanWidth) / 2;

    for (int i = 0; i < redFanWidth; i++) {
      stroke(255, 0, 0, 220);
      strokeWeight(redLineWeight);

      float a = angle - (startOffset + i);

      float x1 = (scaledDist - lineLength) * cos(radians(a));
      float y1 = (scaledDist - lineLength) * sin(radians(a));

      float x2 = scaledDist * cos(radians(a));
      float y2 = scaledDist * sin(radians(a));

      line(x1, -y1, x2, -y2);
    }
  }
}
