// Runs with matlab code, if you press space bar the solenoid will open for x ms then close.
int solenoidOut = 9;
int openDuration = 0.1;
int offDuration = 0.5;

void setup() {
  Serial.begin (9600);
  // check serial comm - acknowledgement routine
  Serial.println('a'); // send a character to matlab
  char a = 'b';
  while (a != 'a')
  {
    // Wait for matlab to send specific character to arduino
    a = Serial.read();
  }
  pinMode(solenoidOut, OUTPUT);
  delay(100);
  Serial.println("start");
}

void loop() {
  openDuration = 0;
  while (openDuration == 0){
 if (Serial.available() > 0) {
        // read the incoming byte:
        openDuration = Serial.read();
        digitalWrite(solenoidOut,HIGH);
      delay(openDuration);
      digitalWrite(solenoidOut,LOW);
      delay(offDuration);
      openDuration=0;
      }
  }

}
