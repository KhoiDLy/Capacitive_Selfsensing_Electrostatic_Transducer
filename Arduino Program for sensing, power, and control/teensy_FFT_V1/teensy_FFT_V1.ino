#include <ADC.h>
#include <ADC_Module.h>
#include <RingBuffer.h>
#include <RingBufferDMA.h>

#include "arduinoFFT.h"  

#define ARM_MATH_CM4
#define pi 3.14159
#define window 10
#include <arm_math.h>

#define SAMPLES 1024               //Must be a power of 2
#define SAMPLING_FREQUENCY 40000  //Hz
#define REFRESH_RATE 30           //Hz
#define ARDUINO_IDE_PLOTTER_SIZE 1000
  
ADC *adc = new ADC(); // adc object;  

unsigned long sampling_period_us;
unsigned long useconds_sampling;
 
unsigned long refresh_period_us;
unsigned long useconds_refresh;
  
double vReal[SAMPLES];
double vImag[SAMPLES];

float MajorF = 0;
float MajorV = 0;
uint8_t SensePin = 15;

arduinoFFT FFT = arduinoFFT(vReal, vImag, SAMPLES, SAMPLING_FREQUENCY);
  
void setup() {
  Serial.begin(115200);
  pinMode(SensePin,INPUT);
  pinMode(13,OUTPUT);
  adc->setAveraging(1); // set number of averages (helps elimitate noise and such)
  adc->setResolution(12); // set bits of resolution 
  adc->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED); // change the conversion speed
  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED); // change the sampling speed

  adc->startContinuous(SensePin, ADC_0);
  
  sampling_period_us = round(1000000*(1.0/SAMPLING_FREQUENCY));
  refresh_period_us = round(1000000*(1.0/REFRESH_RATE));
 
}
  
void loop() {

  useconds_refresh = micros();
  float MajorF = 0;
  float MajorV = 0;
  /*SAMPLING*/
  digitalWrite(13,!digitalRead(13));
  for(int i=0; i<SAMPLES; i++)
  {
    useconds_sampling = micros();
  
    vReal[i] = analogRead(SensePin);
    vImag[i] = 0;
 
    while(micros() < (useconds_sampling + sampling_period_us)){
      //wait...
    }
  }
//  digitalWrite(13,LOW);  
  /*FFT*/
  FFT.DCRemoval();
  FFT.Windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
  FFT.Compute(FFT_FORWARD);
  FFT.ComplexToMagnitude();

 /*Check for Peak frequency*/
  for(int i=0; i<(SAMPLES/2); i++){
    if (MajorV < vReal[i]) {
      MajorV = vReal[i];
//      MajorF = (float) SAMPLING_FREQUENCY/SAMPLES*i; 
    }
  }

//  Serial.print(MajorF, 4);
//  Serial.print(", ");
  Serial.println(MajorV, 4);
  
  /*PRINT RESULTS*/
//  for(int i=0; i<(SAMPLES/2); i++){
//    Serial.print("    ");
//    Serial.print(vReal[i], 1);
//  }
//  Serial.println();
 
  while(micros() < (useconds_refresh + refresh_period_us)){
    //wait...
  }

}
