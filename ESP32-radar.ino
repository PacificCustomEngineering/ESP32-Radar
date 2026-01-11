#include <ESP32Servo.h>  // Make sure you have this library installed (by Gianluca Vivani)

#define TRIG_PIN 23
#define ECHO_PIN 22
#define SERVO_PIN 26   // Change if you use a different pin

Servo radarServo;

void setup() {
  Serial.begin(115200);
  
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Servo setup for ESP32
  ESP32PWM::allocateTimer(0);
  radarServo.setPeriodHertz(50);    // Standard 50 Hz servo
  radarServo.attach(SERVO_PIN, 500, 2400);  // 500-2400 μs pulse range
  
  // Start centered
  radarServo.write(90);
  delay(1000);
}

int getDistance() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);  // Timeout ~400 cm max

  if (duration == 0) {
    return 0;  // No echo received
  }

  int distance = duration * 0.0343 / 2;  // Convert to cm (integer)

  if (distance < 2 || distance > 400) {
    return 0;  // Out of valid range
  }

  return distance;
}

void loop() {
  // Sweep from left (15°) to right (165°)
  for (int angle = 0; angle <= 180; angle += 2) {  // Step by 2° for smooth scan
    radarServo.write(angle);
    delay(30);  // Wait for servo to reach position

    int distance = getDistance();

    // Send: angle,distance.
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.println(".");  // The dot is critical for Processing
  }

  // Sweep back from right to left
  for (int angle = 180; angle >= 0; angle -= 2) {
    radarServo.write(angle);
    delay(30);

    int distance = getDistance();

    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.println(".");
  }
}
