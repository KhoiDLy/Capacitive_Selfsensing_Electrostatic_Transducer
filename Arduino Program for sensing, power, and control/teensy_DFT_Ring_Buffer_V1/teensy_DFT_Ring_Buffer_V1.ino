
#include <ADC_Module.h>
#include <ADC.h>
#include <SD.h>
#include <SPI.h>

#define ARM_MATH_CM4
#define pi 3.14159
#define window 10
#include <arm_math.h>


ADC *adc = new ADC(); // adc object;
IntervalTimer myTimer; //timer object (for interrupts)

//const int chipSelect = BUILTIN_SDCARD;
const int DFTSize = 2200;
const int buffSize = 2300;
const int SampleRate = 10000; //in Hz
const int SensePin = A1; // ADC0 (A1 is pin 15)
const int knobPin = A17; // ADC1 (A17 is pin 36)
const int outPin = 29; //output pin for pwm
float SumDFT_km = 0;
float SumDFT_k = 0;
float SumDFT_u = 0;
volatile float ringBuffer[buffSize];
volatile int put_index = 0;
float sinArray[DFTSize];
float cosArray[DFTSize];
int j = 0;

// Setting up parameters for digital filter
const float k1 = 0.05911;
const float k2 = 0.94088;
const int lower = 1300;
const int upper = 1800;
// Interrupt pin to trigger data collection synchronization
const byte interruptPin = 13;
volatile byte state = LOW;

void setup() {
  Serial.begin(9600);
//  pinMode(13,OUTPUT);
  pinMode(SensePin,INPUT);
  pinMode(knobPin,INPUT);
  pinMode(outPin, OUTPUT); //use this pin for the PWM output (look online for more suitable PWM pins)

  // Setup Interrupt Pin Here
  pinMode(interruptPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(interruptPin), blink, RISING);

  // Setup High Voltage Controller Pin
  analogWriteResolution(12);
  analogWrite(A21,0);
  delay(5000);
  analogWrite(A21,0);
  
  //Computation of the Sin and Cosine Array
  for (int i = 0; i <DFTSize; i++) {
    sinArray[i] = sin(-2*pi*i*1550/SampleRate);
    cosArray[i] = cos(-2*pi*i*1550/SampleRate);
  }
  
  //start the timer to interrupt based on the desired frequency to update the circular buffer
  
  
  adc->setAveraging(10); // set number of averages (helps elimitate noise and such)
  adc->setResolution(12); // set bits of resolution 

    // it can be any of the ADC_CONVERSION_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED_16BITS, HIGH_SPEED or VERY_HIGH_SPEED
    // see the documentation for more information
    // additionally the conversion speed can also be ADACK_2_4, ADACK_4_0, ADACK_5_2 and ADACK_6_2,
    // where the numbers are the frequency of the ADC clock in MHz and are independent on the bus speed.
    adc->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED); // change the conversion speed
    adc->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED); // change the sampling speed

    adc->startContinuous(SensePin, ADC_0);
//    SD.begin(chipSelect);
    
    myTimer.begin(updateBuffer, round(1000000/SampleRate/2)); 
    delay(500);
}

void updateBuffer(){
  ringBuffer[put_index] = analogRead(SensePin)*2.5/adc->getMaxValue(ADC_0)-1.25;
  put_index = (put_index + 1) % buffSize;

}

void blink() {
  state = HIGH;
}

void loop() {
//  String dataString = "";
  int pop_index ,i, ref;
  static int data_counter = 0;
  float Re = 0;
  float Im = 0;
// counter1 = micros();
    myTimer.end();
////    ref = analogRead(knobPin);
    pop_index = put_index+200; 
    myTimer.begin(updateBuffer,1000000/2/SampleRate);
    for (i=0; i<DFTSize; i++)
      {
       pop_index = pop_index % buffSize;        
       Re = Re + ringBuffer[pop_index]*cosArray[i];
       Im = Im + ringBuffer[pop_index]*sinArray[i];    
//    dataString = String(ringBuffer[pop_index],4);
//    File dataFile = SD.open("datalog.txt", FILE_WRITE);
//    if (dataFile) {
//    dataFile.println(dataString);
//    dataFile.close();
//       }
//  Serial.println(pop_index,DEC);
       pop_index++;   
    }
    delayMicroseconds(150);
    SumDFT_u = SumDFT_u + sqrt(Re*Re+Im*Im);
    if (j == 99) {
      SumDFT_u = SumDFT_u*10;
//      if (data_counter > 100) {
//        if (SumDFT_u >1.1*SumDFT_km || SumDFT_u <0.9*SumDFT_km) {
//          SumDFT_u = SumDFT_km;
//          data_counter = 101;
//        }
//      }
      SumDFT_k  = k1*SumDFT_u + k2*SumDFT_km;
      SumDFT_km = SumDFT_k;
//      Serial.print(lower);
//      Serial.print(" ");
//      Serial.print(upper);
//      Serial.print(" ");
//      Serial.print(SumDFT_u);
//      Serial.print(" ");
//      if (state == HIGH) {
        Serial.println(SumDFT_k);
//      } 
      SumDFT_u = 0;     

      data_counter++;    
//      digitalWriteFast(13,!digitalReadFast(13));
    } 
      j = (j+1)%100;
}
