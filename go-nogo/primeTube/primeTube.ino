const int valvePin = 5;
int state = LOW;

void setup() {
  pinMode(valvePin, INPUT);
  digitalWrite(valvePin, state);

  Serial.begin(9600);
  Serial.flush();

}

void loop() {
  if (Serial.available() > 0) {
    int val = Serial.parseInt();
    if (val == 1) {
      state = !state;
      digitalWrite(valvePin, state);
    }
  }
}
