int cnt = 0;

void setup() {
  Serial.begin(9600);

  int done = 0;
  float val[4];
  while (done == 0) {
    while (Serial.available() > 0) {
      val[cnt] = Serial.parseFloat();
      Serial.print(cnt);
      Serial.print(" ");
      Serial.println(val[cnt]);
      unsigned long t = micros();
      Serial.println(t);
      unsigned long tEnd = t + ((unsigned long)val[cnt] * (float)1000000);
      while (micros() < tEnd) {
      }
      Serial.println(micros());
      cnt++;
      if (cnt == 4) {
        done = 1;
        break;
      }
    }
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}
