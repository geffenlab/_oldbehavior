const int lickPin = 2;
const int waterPin = 5;
const int soundPin = 3;

// Variables
int taskState = 0;
int patientLicks = 0;
int lastLickState = LOW;
int lickState = LOW;
int matlabTrialSignal;
int rewardStatus;
int one = 1;
int stimulusMarker;
int timeoutState = LOW;
int responseWindow = LOW;
int proceed;
int W;

// Time Variables
unsigned long randNumber;
unsigned long delayStart;
unsigned long lastReward;
unsigned long t;
unsigned long responseStart;
unsigned long rewardTimer;
unsigned long delayTimer;
unsigned long rewardEnd;

// Float Variables from Matlab (Default Values)
float rewardDur = 100000;
float responseDur = 1200000;
float timeoutDur = 7000000;
float patientWait = 2000000;

// Debounce Variables
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 7000;    // the debounce time; increase if the output flickers

void setup()
{
  pinMode(lickPin, INPUT);
  pinMode(waterPin, OUTPUT);
  pinMode(soundPin, INPUT);

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
      responseDur = Serial.parseFloat();
      timeoutDur = Serial.parseFloat();
      break;
    }
  }

  // seed random number generator
  randomSeed(analogRead(0));
}

void loop() {

  switch (taskState)
  {
    case 0: { // wait RandNumber seconds (2.0-2.5) before starting trial
        delayStart = micros();
        randNumber = random(0, 500000);
        while (patientLicks == 0) {
          if (digitalRead(lickPin) == HIGH) {
            delayStart = micros();
          }
          if (micros() - delayStart > ((long)(patientWait * (float)1000000) + randNumber)) {
            taskState = 1;
            t = micros();
            Serial.println(t);
            //rewardStatus = 0;
            break;
          }
        }
        break;
      }

    case 1: { //Determine Trial Type from Matlab input
        matlabTrialSignal = Serial.read();
        if (matlabTrialSignal == 48) {
          taskState = 2;
        }
        if (matlabTrialSignal == 49) {
          taskState = 2;
        }
        break;
      }

    case 2: { //Listen for sound
        stimulusMarker = digitalRead(soundPin);
        if (stimulusMarker == HIGH) {
          Serial.print("S");
          Serial.println(micros());
          taskState = 3;
          proceed = 0;
        }
        break;
      }

    case 3: {//Lick Logic
        int lickDetect = digitalRead(lickPin);

        if (lickDetect != lastLickState) {
          lastDebounceTime = micros();
        }

        stimulusMarker = digitalRead(soundPin);
        if (stimulusMarker == LOW && responseWindow != HIGH) {
          proceed = 1;
        }
        if (stimulusMarker == HIGH && responseWindow != HIGH && proceed == 1) {
          responseStart = micros();
          responseWindow = HIGH;
          Serial.print("O");
          Serial.println(micros());
          proceed = 0;
        }

        if ((micros() - lastDebounceTime) > debounceDelay && lickDetect != lickState) {
          lickState = lickDetect;
          if (lickState == HIGH) {
            Serial.print("L");
            Serial.println(micros());
            if ((micros() - responseStart) > 0 && (micros() - responseStart) < 1200000) {
              if (matlabTrialSignal == 48) {
                Serial.print("T");
                Serial.println(micros());
                timeoutState = HIGH;
                delayTimer = micros();
              }
              if (matlabTrialSignal == 49 && rewardStatus == 0) {
                Serial.print("R");
                Serial.println(micros());
                digitalWrite(waterPin, HIGH);
                rewardTimer = micros();
                rewardStatus = 1;
              }
            }
          }
        }

        lastLickState = lickDetect;

        while (rewardStatus == 1 && W == 0) {
          if ((micros() - rewardTimer) > (long)(rewardDur * (float)1000000)) {
            digitalWrite(waterPin, LOW);
            rewardEnd = micros();
            W = 1;
            break;
          }
        }

        if ((micros() - responseStart) >= (long)(responseDur * (float)1000000) && responseWindow == HIGH) {
          taskState = 4;
          responseWindow = LOW;
          Serial.print("C");
          Serial.println(micros());
        }
        break;
      }

    case 4: {
        while (timeoutState == HIGH) {
          if ((micros() - delayTimer) > (long)(timeoutDur * (float)1000000)) {
            Serial.print("Q");
            Serial.println(micros());
            timeoutState = LOW;
            taskState = 0;
          }
          //          else {
          //            Serial.print("T");
          //            Serial.println(delayTimer);
          //          }
        }
        while (W == 1) {
          Serial.print("W");
          Serial.println(rewardEnd);
          W = 0;
          rewardStatus = 0;
        }
        if (timeoutState != HIGH) {
          taskState = 0;
        }
        break;
      }

  }

}
