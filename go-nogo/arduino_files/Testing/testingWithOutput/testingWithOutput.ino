// Pin Variables
const int lickPin           = 2;
const int waterPin          = 5;
const int soundPin          = 3;
const int lickOut           = 8;
const int waterOut          = 9;

// State Variables
int taskState               = 0;
int patientLicks            = 0;
int W                       = 0;
int lastLickState           = LOW;
int lickState               = LOW;
int timeoutState            = LOW;
int responseWindow          = LOW;
int matlabTrialSignal;
int rewardStatus;
int stimulusMarker;
int proceed;

// Time Variables
unsigned long randNumber;
unsigned long delayStart;
unsigned long lastReward;
unsigned long t;
unsigned long responseStart;
unsigned long rewardTimer;
unsigned long delayTimer;
unsigned long rewardEnd;
unsigned long lastDebounceTime = 0;      // the last time the output pin was toggled
unsigned long debounceDelay = 7000;     // the debounce time; increase if the output flickers
unsigned long tEnd;

// Float Variables from Matlab
float rewardDur = 0;
float responseDur = 0;
float timeoutDur = 0;
float patientWait = 0;

void setup()
{
  pinMode(lickPin, INPUT);
  pinMode(waterPin, OUTPUT);
  pinMode(soundPin, INPUT);
  pinMode(lickOut, OUTPUT);
  pinMode(waterOut, OUTPUT);

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
  tEnd = (long)(timeoutDur * (float)1000000);
}

void loop() {
  randNumber = 2.50; // Eventually input this from MATLAB?

  switch (taskState)
  {
    case 0: { // wait RandNumber seconds (2.0-2.5) before starting trial
        delayStart = micros();
        while (patientLicks == 0) {
          if (digitalRead(lickPin) == HIGH) {
            delayStart = micros();
          }
          if ((micros() - delayStart) > (long)(patientWait * (float)1000000)) {
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
          digitalWrite(lickOut, lickState);
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
              if (matlabTrialSignal == 49 && W == 0) {
                Serial.print("R");
                Serial.println(micros());
                digitalWrite(waterPin, HIGH);
                digitalWrite(waterOut,HIGH);
                rewardTimer = micros();
                rewardStatus = 1;
              }
            }
          }
        }

        while (rewardStatus == 1) {
          if ((micros() - rewardTimer) > (long)(rewardDur * (float)1000000)) {
            digitalWrite(waterPin, LOW);
            digitalWrite(waterOut, LOW);
            rewardEnd = micros();
            W = 1;
            rewardStatus = 0;
            break;
          }
        }

        lastLickState = lickDetect;

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
          if ((micros() - delayTimer) > tEnd) {
            Serial.print("Q");
            Serial.println(micros());
            timeoutState = LOW;
            taskState = 0;
          }
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
