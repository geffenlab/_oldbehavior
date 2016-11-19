
const int buttonPin   = 2;      // the number of the pushbutton pin
const int ledPin      = 5;      // the number of the LED pin
const int lickOut     = 8;
const int waterOut    = 9;

int ledState = LOW;         // the current state of the output pin
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin
unsigned long lickStamp;
long lastReward;

// the following variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 7000;    // the debounce time; increase if the output flickers

// float variables from MATLAB (sent each session)
float rewardDur;
float patientWait;

void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(lickOut, OUTPUT);
  pinMode(waterOut, OUTPUT);

  // set initial LED state
  digitalWrite(ledPin, ledState);
  digitalWrite(waterOut, LOW);

  Serial.begin(9600);
  Serial.println("Starting...");
  Serial.println();

  Serial.println('a'); // send a character to matlab
  char a = 'b';
  while (a != 'a') {
    // Wait for matlab to send specific character to arduino
    a = Serial.read();
  }
  Serial.flush();

  while (1) {
    if (Serial.available() > 0) {
      patientWait = Serial.parseFloat();
      rewardDur = Serial.parseFloat();
      break;
    }
  }
}

void loop() {
  // read the state of the switch into a local variable:
  int reading = digitalRead(buttonPin);

  // check to see if you just pressed the button
  // (i.e. the input went from LOW to HIGH),  and you've waited
  // long enough since the last press to ignore any noise:

  // If the switch changed, due to noise or pressing

  if ((micros() - lastReward) > (long)(rewardDur * (float)1000000)) {
    digitalWrite(ledPin, LOW);
    digitalWrite(waterOut, LOW);  
  }

  if (reading != lastButtonState) {
    // reset the debouncing timer
    lastDebounceTime = micros();
    lickStamp = lastDebounceTime;
  }

  if ((micros() - lastDebounceTime) > debounceDelay && reading != buttonState) {

    buttonState = reading;
    digitalWrite(lickOut,buttonState);

    if (buttonState == HIGH) {
      Serial.print("1  ");
      Serial.println(lickStamp);

      if ((micros() - lastReward) > (long)(patientWait * (float)1000000)) {
        digitalWrite(ledPin, HIGH);
        digitalWrite(waterOut, HIGH);
        lastReward = micros();
        Serial.print("0  ");
        Serial.println(micros());
      }
    }
  }

  // save the reading. Next time through the loop,
  // it'll be the lastButtonState:
  lastButtonState = reading;
}

