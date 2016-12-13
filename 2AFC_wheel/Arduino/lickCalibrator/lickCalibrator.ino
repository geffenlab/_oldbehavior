/*
  solenoid_calibration_routine
  Takes an integer number of milliseconds from the Serial Monitor and clicks a solenoid
  100 times at that millisecond duration.
 
  Note: Serial monitor must have Newline character and 9600 Baud selected to work correctly.
  Brian Isett, 2016-06-19
 
*/
const int solenoidPin =  9;      // change this to the pin connected to the solenoid driver circuit,
                                  //pin 13 will flash the onboard Arduino Uno LED
const int offDuration = 500; // Value in ms to wait in-between solenoid openings (you might need to adjust this)
int openDuration = 0;
const int numClicks = 100; // Number of solenoid clicks to deliver during one "open duration" calibration run
 
void setup() {
  // set the digital pin as output:
  pinMode(solenoidPin, OUTPUT);
  Serial.begin(9600);  // For our example, lets us type in a duration into the Serial Monitor
  Serial.println("Ready!");
}
 
void loop()
{  
  //Read in a value input typed into the Arduino IDE Serial Monitor as an open duration (in milliseconds). 
  if (Serial.available()){
    openDuration=Serial.parseInt(); //Make sure 'Newline' is enabled in your serial monitor!
  }else{
    openDuration=0;
  }
  if (openDuration > 0)
  {
    Serial.print("Using ");
    Serial.print(openDuration);
    Serial.println("ms solenoid open duration");
    for (int i=0; i < numClicks;i++)
    {
      digitalWrite(solenoidPin,HIGH);
      delay(openDuration);
      digitalWrite(solenoidPin,LOW);
      delay(offDuration);
    }
    Serial.print("Delivered ");
    Serial.print(numClicks);
    Serial.println(" solenoid clicks.");
  }
}
