const int valvePin = 5;
int state = LOW;

void setup() {
  pinMode(valvePin, INPUT);
  digitalWrite(valvePin, state);

  Serial.begin(9600);
  Serial.flush();

  Serial.println('a'); // send a character to matlab
  char a = 'b';
  while (a != 'a') {
    // Wait for matlab to send specific character to arduino
    a = Serial.read();
  }
  Serial.println("Starting");
  Serial.flush();

}

void loop() {
  if (Serial.available() > 0) {
    int val = Serial.parseInt();
    if (val == 1) {
      state = !state;
      digitalWrite(valvePin, state);
      Serial.println(state);
    }
  }
}
