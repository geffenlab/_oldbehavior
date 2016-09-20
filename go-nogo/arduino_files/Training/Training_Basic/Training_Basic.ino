/* Training Task:
 * Matlab plays either signal or noise (signal = 1, noise = 0)
 * Wait for licks...
 * If 1 && lick detected during response window, dispense reward.
 * If 1 && no licks, wait 2.5 seconds.
 * If 0 && lick detected during response window, timeout.
 * If 0 &&no licks, wait 2.5 seconds
 */

const int lickPin = 2;
const int waterPin = 5;

// Variables
int taskState = 0;
char incomingByte = 0;
int patientLicks = 0;
long randNumber;
long delayStart;
long taskLength = 3;
int trialType; // eventually feed from MATLAB, signal or noise
int lastButtonState = LOW;
int buttonState = LOW;
int rewardStatus;
long lastReward;
int reading;

long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 20000;    // the debounce time; increase if the output flickers

void setup() { //////////////////////////////////////////////////////////////////////

  pinMode(lickPin, INPUT);
  pinMode(waterPin, OUTPUT);

  Serial.begin(9600);
  Serial.println("Starting...");
  Serial.println();
  //Serial.println("Waiting for MATLAB input...");
 
 Serial.println('a'); // send a character to matlab
  char a = 'b';
  while (a != 'a'){
    // Wait for matlab to send specific character to arduino
    a = Serial.read();
  }
  Serial.flush();
  
}

void loop() {/////////////////////////////////////////////////////////////////////////

  // Variables
  randNumber = 2.50; // Eventually input this from MATLAB?
  int rewardState = 1;
  
  
  Serial.print("Waiting ");
  Serial.print(randNumber, DEC);
  Serial.println(" seconds with no licks to proceed...");

  // wait RandNumber seconds (2.0-2.5) before starting trial
  delayStart = micros();
  while (patientLicks == 0) {
    if (digitalRead(lickPin) == 1) {
      delayStart = micros();
    }
    if (micros() - delayStart > (randNumber * 1000000)) {
      break; }
    else if (micros() - delayStart > (randNumber * 1000000)) {
    }
  }

  // Display "timestamp Begin Task" in Serial Monitor
  Serial.print(micros());
  Serial.println(" Begin Task");
  delayStart = micros();
  rewardStatus = 1;

  //Determine Trial Type (signal = 1, noise = 0)
  int incomingByte = Serial.read();
//  if (incomingByte == 49) {
    trialType = 1;
//  }
//  if (incomingByte == 48){
//    trialType = 0;
//  }

  // Actual Task //////////////////////////////////////////////////////////////////////
  while (taskState == 0){

    if ((micros() - lastReward) > 300000) {
        digitalWrite(waterPin, LOW);
      }
    
    //Signal Case//....................................................................//

    // Checks trial type
    if (trialType == 1){
      reading = digitalRead(lickPin);

      // Start debounce timer when lick detected
      if (reading != lastButtonState) {
        lastDebounceTime = micros();
      }

      // Debounced lick ensured
      if ((micros() - lastDebounceTime) > debounceDelay && reading != buttonState) {
        buttonState = reading;

        if (reading == HIGH) {
          Serial.print(lastDebounceTime);
          Serial.println(" LICK");
          
          if (rewardStatus == 1 && (micros() - delayStart) > 1200000 && (micros() - delayStart) < 2400000){
            Serial.print(micros());
            Serial.println(" REWARD");
            digitalWrite(waterPin, HIGH);
            lastReward = micros();
            rewardStatus = 0;
          }
        }
      }

      lastButtonState = reading;

      if (micros() - delayStart > (taskLength * 1000000)) {
        break;
      }
//    Serial.println(1);
  }

    //Noise Case//...................................................................
  }
   /* 
   // send data only when you receive data:
    if (Serial.available() > 0) {
      // read the incoming byte:
      // incomingByte = Serial.read();
      //incomingByte = 49 means noise
      //incomingByte = 50 means signal
  
      digitalWrite(waterPin, HIGH);
      delay(500);
      digitalWrite(waterPin, LOW);
      break;
      
    } 
  }*/
}
 
  

  // if (signal) {
  // wait until stimulus ends (1.2s)
  //}

    // if (lick detected in response window) {
    

