//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Before starting the code, must run it without the trapzoidal wave function to measure the loop_time
// Must also measure the maximum output voltage from the gained DAC ( it is probably about 4.96V)
//
// This code will generate a trapzoidal wave to the HV EMCO C80 and obtain the DFT information
// It also trigger DAQ for DFT-LaserDisp synchronization
// The DFT data is compensated due to the DFT - Input Voltage dependency
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include <ADC_Module.h>
#include <ADC.h>
#include <AD9833.h>
#include <digitalWriteFast.h>

#define FNC_PIN 10       // Can be any digital IO pin

#define ARM_MATH_CM4
#define pi 3.14159
#include <arm_math.h>

// Setting up the sampling and DFT parameters
#define DFTSize 800               //Must be a power of 2
#define SAMPLING_FREQUENCY 40000  //Hz
unsigned long sampling_period_us;
unsigned long useconds_sampling;

ADC *adc = new ADC(); // adc object;
IntervalTimer myTimer; //timer object (for interrupts)

const int SensePin = A1; // ADC1 (A1 is pin 15)
const int TrigPin = 30;

float SumDFT_km = 0;
float SumDFT_k = 0;
float SumDFT_u = 0;
float delDFT = 0;
float Buffer[DFTSize];

float sinArray[DFTSize];
float cosArray[DFTSize];
int j = 0;

// Setting up parameters for digital filter
const float k1 = 0.239057;
const float k2 = 0.76094;

// Setting the serial plotter bounds
const int lower = 80;
const int upper = 150;

// Coefficient table for voltage dependence compensation
float coef_arr[2] = {0.25, -10}; // This is for 660pF? cap baseline
//float coef_arr[2] = {0, 0};
int av_i = 0; // Use this variable to loop the first 100 data point to find the compensation factor
float sum_of_first_100 = 0;

// Setting up the waveform generation
float ramp_time = 20; // (s)
float DAC_OUT_MAX = (3.7 - 0) * (4095 - 0) / (5.06 - 0) + 0;
int step_i = 0;
float loop_time = 1/49.64;
float input_voltage = 0;
bool waveGenFlag = false;

//--------------- Create an AD9833 object ---------------- 
// Note, SCK and MOSI must be connected to CLK and DAT pins on the AD9833 for SPI
AD9833 gen(FNC_PIN);       // Defaults to 25MHz internal reference frequency

void setup() {
  Serial.begin(115200);
  
  pinMode(TrigPin, OUTPUT);
  digitalWrite(TrigPin,HIGH);
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
    
  Serial.println("Complete setting up sine wave generator.");
  pinMode(SensePin, INPUT);

  // Initialize DAC signal to HV converter to zero
  analogWriteResolution(12);
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

  // Time delay for Triggering
  Serial.println("Complete Setup, Preparing to Trigger...");
  while (millis() < 10000) {
    delay(20);
  }
}

void DCRemoval()
{
  // calculate the mean of vData
  float  mean = 0;
  for (uint16_t j = 1; j <= DFTSize; j++)
  {
    mean += Buffer[j];
  }

  mean /= DFTSize;
  
  // Subtract the mean from vData
  for (uint16_t j = 1; j <= DFTSize; j++)
  {
    Buffer[j] -= mean;
  }
}

void loop() {
  int i;
  //  static int data_counter = 0;
  float Re = 0;
  float Im = 0;
  
  // Fixing the sampling rate of the ADC for the DFT computation
  for(i=0; i<DFTSize; i++)
  {
    useconds_sampling = micros();
  
    Buffer[i] = analogRead(SensePin)*3.3/adc->getMaxValue(ADC_0);
 
    while(micros() < (useconds_sampling + sampling_period_us)){
      //wait...
    }
  }
  
  DCRemoval();

  // DFT computation
  for (i = 0; i < DFTSize; i++) {
    Re = Re + Buffer[i]* cosArray[i];
    Im = Im + Buffer[i]* sinArray[i];
  }
    
  SumDFT_k = sqrt(Re * Re + Im * Im); 
//  SumDFT_k  = k1 * SumDFT_u + k2 * SumDFT_km; // Low pass filtering the DFT Signal
//  SumDFT_km = SumDFT_k;

  if (av_i <100) {
    sum_of_first_100 += SumDFT_k;
    av_i++;
  }
  else if(av_i == 100) {
    sum_of_first_100 = sum_of_first_100/av_i; // Taking the average of the first 100 data
//    SumDFT_k = SumDFT_k - sum_of_first_100 + 100; // Shift the data to the same baseline (100)
    waveGenFlag = true; // Starting from av_i = 101, the waveform starts
    av_i++;
  }
  else {
//    SumDFT_k = SumDFT_k - sum_of_first_100 + 100; // scaling the SumDFT by the determined factor with baseline (V = 0) is 100 for all hasels

    // DFT Drift due to HV compensation
    if (waveGenFlag){
      input_voltage = (trapzoid_wave(loop_time) - 0) * (5.06 - 0) / (4095 - 0) + 0;
      delDFT = coef_arr[0] * input_voltage * input_voltage + coef_arr[1] * input_voltage;
//      delDFT = coef_arr/ sum_of_first_100 * 100 * input_voltage;
      SumDFT_k = SumDFT_k - delDFT;
    }

    //  Displaying the results
//    Serial.print(lower);
//    Serial.print(" ");
//    Serial.print(upper);
//    Serial.print(" ");
    digitalWrite(TrigPin, LOW);
    Serial.println(SumDFT_k);
  }    
}

int trapzoid_wave(float update_time){
  float num_iteration = ramp_time / update_time / 4;
  float del_DAC_OUT = DAC_OUT_MAX / num_iteration;
  int DAC_OUT = 0;
//  Serial.print(DAC_OUT_MAX);
  if (step_i < round(num_iteration)) {
    DAC_OUT = 0.8*4095/5.06;
    analogWrite(A21, DAC_OUT);
  }
  else if (step_i>= round(num_iteration) && step_i < round(2*num_iteration)){
    DAC_OUT = round((step_i - round(num_iteration))*del_DAC_OUT)+ 0.8*4095/5.06;
    analogWrite(A21, DAC_OUT);
  }
  else if (step_i>= round(2*num_iteration) && step_i < round(3*num_iteration)){
    DAC_OUT = round(round(num_iteration)*del_DAC_OUT) + 0.8*4095/5.06;
    analogWrite(A21, DAC_OUT);
  }
  else if (step_i>= round(3*num_iteration) && step_i < round(4*num_iteration)){
    DAC_OUT = round( round(ramp_time / update_time - round(1+num_iteration) - (step_i - round(num_iteration)))*del_DAC_OUT) + 0.8*4095/5.06;
    analogWrite(A21, DAC_OUT);
  }
  step_i = (step_i + 1) % round(ramp_time / update_time);
//  Serial.print(step_i);
  return DAC_OUT;
}
