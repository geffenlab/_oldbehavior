// Read a debounced digital signal from the lickport every loop,
// then choose actions accordingly based on the timing of the lick

const int buttonPin = 2;

int state;
int lastState = LOW;

long t = 0;
long dt = 20;


void setup() {
  Serial.begin(9600);
  Serial.println("Monitoring presses...");
  Serial.println();
}

void loop() {
  // Read button
  int reading = digitalRead(buttonPin);

  // If the state changes
  if (reading != lastState) {
    // Start the timer
    t = millis();
  }

  // If the current time is greater than the delay
  if ((millis() - t) > dt) {
    // then our state has officially changed:
    if (reading != state) {
      state = reading;

      // Print output
      if (state == HIGH) {
        Serial.println(t);
        Serial.println(state);
        Serial.println();
      }
    }
  }

  // Save out the reading
  lastState = reading;
}
