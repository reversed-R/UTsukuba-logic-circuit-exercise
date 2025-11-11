#define HALF_CYCLE 1000

void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, 1);
  delay(HALF_CYCLE);
  digitalWrite(13, 0);
  delay(HALF_CYCLE);
}
