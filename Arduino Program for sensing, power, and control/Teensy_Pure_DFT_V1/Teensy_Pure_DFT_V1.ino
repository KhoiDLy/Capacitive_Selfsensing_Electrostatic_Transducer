#include <ADC_Module.h>
#include <ADC.h>
#include <AD9833.h>
#include <digitalWriteFast.h>

#define FNC_PIN 10       // Can be any digital IO pin

#define DFTSize 1600               //Must be a power of 2
#define SAMPLING_FREQUENCY 40000  //Hz

#define ARM_MATH_CM4
#define pi 3.14159
#define window 10
#include <arm_math.h>

unsigned long sampling_period_us;
unsigned long useconds_sampling;
 
unsigned long refresh_period_us;
unsigned long useconds_refresh;

ADC *adc = new ADC(); // adc object;
IntervalTimer myTimer; //timer object (for interrupts)

const int SensePin = A1; // ADC1 (A1 is pin 15)

float SumDFT_km = 0;
float SumDFT_k = 0;
float SumDFT_u = 0;
float Buffer[DFTSize];

float sinArray[DFTSize];
float cosArray[DFTSize];
int j = 0;

// Setting up parameters for digital filter
const float k1 = 0.239057;
const float k2 = 0.76094;
const int lower = 180;
const int upper = 300;

//--------------- Create an AD9833 object ---------------- 
// Note, SCK and MOSI must be connected to CLK and DAT pins on the AD9833 for SPI
AD9833 gen(FNC_PIN);       // Defaults to 25MHz internal reference frequency

void setup() {

  // This MUST be the first command after declaring the AD9833 object
  gen.Begin();              

  // Apply a 1000 Hz sine wave using REG0 (register set 0). There are two register sets,
  // REG0 and REG1. 
  // Each one can be programmed for:
  //   Signal type - SINE_WAVE, TRIANGLE_WAVE, SQUARE_WAVE, and HALF_SQUARE_WAVE
  //   Frequency - 0 to 12.5 MHz
  //   Phase - 0 to 360 degress (this is only useful if it is 'relative' to some other signal
  //           such as the phase difference between REG0 and REG1).
  // In ApplySignal, if Phase is not given, it defaults to 0.
  gen.ApplySignal(SINE_WAVE,REG0,1000);
 
  gen.EnableOutput(true);   // Turn ON the output - it defaults to OFF
  // There should be a 1000 Hz sine wave on the output of the AD9833
  //delay(100);

  // Important!: USe digitalWrite 10 LOW for Teensy 3.6
  digitalWrite(FNC_PIN,LOW);
    
  Serial.begin(115200);
  pinMode(SensePin, INPUT);

  // Initialize DAC signal to HV converter to zero
  analogWrite(A21,0);
  delay(5000);
  analogWrite(A21,0);

  //Computation of the Sin and Cosine Array
  for (int i = 0; i < DFTSize; i++) {
    sinArray[i] = sin(-2 * pi * i * 1000 / SAMPLING_FREQUENCY);
    cosArray[i] = cos(-2 * pi * i * 1000 / SAMPLING_FREQUENCY);
  }

  //start the timer to interrupt based on the desired frequency to update the circular buffer

  adc->setAveraging(2); // set number of averages (helps elimitate noise and such)
  adc->setResolution(12); // set bits of resolution

  // it can be any of the ADC_CONVERSION_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED_16BITS, HIGH_SPEED or VERY_HIGH_SPEED
  // see the documentation for more information
  // additionally the conversion speed can also be ADACK_2_4, ADACK_4_0, ADACK_5_2 and ADACK_6_2,
  // where the numbers are the frequency of the ADC clock in MHz and are independent on the bus speed.
  adc->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED); // change the conversion speed
  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED); // change the sampling speed

  adc->startContinuous(SensePin, ADC_0);

  sampling_period_us = round(1000000*(1.0/SAMPLING_FREQUENCY));
  
  delay(500);

}

void DCRemoval()
{
  // calculate the mean of vData
  float  mean = 0;
  for (uint16_t i = 1; i <= DFTSize; i++)
  {
    mean += Buffer[i];
  }

  mean /= DFTSize;
  
  // Subtract the mean from vData
  for (uint16_t i = 1; i <= DFTSize; i++)
  {
    Buffer[i] -= mean;
  }
}

void loop() {
  
  int i, ref;
  //  static int data_counter = 0;
  float Re = 0;
  float Im = 0;

  for(i=0; i<DFTSize; i++)
  {
    useconds_sampling = micros();
  
    Buffer[i] = analogRead(SensePin)*3.3/adc->getMaxValue(ADC_0);
 
    while(micros() < (useconds_sampling + sampling_period_us)){
      //wait...
    }
  }
  
//  DCRemoval();

  for (i = 0; i < DFTSize; i++) {
    Re = Re + Buffer[i]* cosArray[i];
    Im = Im + Buffer[i]* sinArray[i];
  }
  SumDFT_u = 0;
  SumDFT_u = SumDFT_u + sqrt(Re * Re + Im * Im);
  
//  SumDFT_k  = k1 * SumDFT_u + k2 * SumDFT_km;
//  SumDFT_km = SumDFT_k;

//  Serial.print(lower);
//  Serial.print(" ");
//  Serial.print(upper);
//  Serial.print(" ");
  Serial.println(SumDFT_u);
  SumDFT_u = 0;
}
