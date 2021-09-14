#include <ADC_Module.h>
#include <ADC.h>
#include <AD9833.h>
#include <digitalWriteFast.h>

#define FNC_PIN 10       // Can be any digital IO pin

#define ARM_MATH_CM4
#define pi 3.14159
#define window 10
#include <arm_math.h>

/////////////////////////////// Setting up the sampling frequency for control /////////////////////////////////////////
#define DFTSize 800
#define SAMPLING_FREQUENCY 20000  //Hz
unsigned long sampling_period_us;
unsigned long useconds_sampling;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ADC *adc = new ADC(); // adc object;
IntervalTimer myTimer; //timer object (for interrupts)

/////////////////////////////// Setting up the loop frequency for control /////////////////////////////////////////
#define LOOP_FREQUENCY 20  //Hz (change this number if you want to get a different fixed control update frequency)
unsigned long loop_control_period;
unsigned long loop_control_timing;
int counter = 0; // This counter will counts the number of steps to generate the required tracking reference data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const int SensePin_R = A1; // ADC0 (A1 is pin 15)
const int SensePin_T = A0; // ADC0 (A0 is pin 14)
const int dispPin = A13; // ADC1( A13 is pin 31)

// Setting variables for the DFT computation
float Buffer_R[DFTSize] = {0};
float Buffer_T[DFTSize] = {0};
float sinArray[DFTSize];
float cosArray[DFTSize];

float Gain_T = 33.845 / 542.331288 * 2; // 33.25 is the gain of the non-inverting op amp, 543 is the DFT to voltage conversion
float Gain_R = 1.02 / 0.215 / 542.331288 * 2; // 1.01 is the attenuation of the 2nd filter, 0.20145 is the attenuation of the inverting opamp
// Constants to compute the actuator's capacitance
float Rm = 31110;
float Rs = 3710; // Need measurement
float Cf = 220 * pow(10, -12);
float Rvs =  2650; // trek
float Rvp = 987600; // trek
float C = 3113 * pow(10, -12); // Emco C80
float F = 1000; // Sine-wave frequency

// Variables to compute the actuator's capacitance
float V_Rm    = 0; // Voltage drop across the measuring resistor
float V_Tot   = 0; // Total voltage
float theta   = 0; // Angle between V_Rm and V_Tot
float V_Junct = 0; // Junction Voltage
float phi     = 0; // Angle between V_Rm and V_J (but inside the triangle V_Rm, V_Tot, and V_J)
float gam     = 0; // Angle between V_Rm and V_J
float z       = 0; // Angle between I_f and I_Rm
float I_Rm    = 0; // Current through Rm, equals vec(I_a) + vec(I_f)
float I_f     = 0; // Current through Cf
float I_a     = 0; // Current through actuator
float x       = 0; // Anngle between I_Rm and I_a
float alpha   = 0; // Angle between I_a and V_J
float Zc      = 0; // Impedance of the HV internal Cap
float V_o     = 0; // Voltage drop across the internal impedance of HV converter
float y       = 0; // Angle between V_o and V_C
float w       = 0; // Angle between V_vs and V_o
float I_vp    = 0; // Current through the parallel resistance of the internal impedance of HV  converter
float k       = 0; // Angle between I_o and I_vs (but inside the triangle I_o, I_vp, and I_vs)
float m       = 0; // Angle between I_a and V_o
float n       = 0; // Angle between V_J and V_o
float V_a     = 0; // Voltage drop across the actuator
float p       = 0; // Angle between V_a and V_J
float beta    = 0; // Angle between I_a and V_a
float B       = 0; // Simplified parameter
float Zca     = 0; // Angle between the V_a and V_ca
float Ca      = 0; // Capacitance of the actuator
float del_Ca  = 0; // Comppensation delta ca

//// Coefficient table for voltage dependence compensation
//float coef_arr[2] = {0.25, -10}; // This is for 660pF? cap baseline

// Setting up parameters for digital filter
const float k1 = 0.239057;
const float k2 = 0.76094;
const int lower = 180;
const int upper = 300;

// Control Parameters:
float Kp = 2;
float Ki = 0;
float Kd = 0;
float T = 1/ LOOP_FREQUENCY;
float err[3] = {0,0,0};
float u_k[2] = {0,0};

////////////////////////////// Reference parameters /////////////////////////////////////////////////////////////
const bool displacement_ref_FLAG = 1; // Choose 0 for step tracking, 1 for sine tracking

//////////// Step tracking
const float displacement_target = 3.2; // (mm) this is what we are trying to track here
const int off_time = 5; // (s) time to delay the step generator
const int on_time = 8; // (s) duration of the step generator

/////////// Sine tracking
float target_offset = 1.5; // This is the offset of your target displacement
float target_amp = 1.5; // This is the amplitude of your target displacement
float target_frequency = 0.1; // This is the frequency of your target displacement
#define factor 10 // This factor is calculated by 1/target_frequency if target_frequency < 1
float buffer_sine[LOOP_FREQUENCY*factor] = {}; // factor = 1 if 1 < target frequency <10
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


//--------------- Create an AD9833 object ----------------
// Note, SCK and MOSI must be connected to CLK and DAT pins on the AD9833 for SPI
AD9833 gen(FNC_PIN);       // Defaults to 25MHz internal reference frequency

void setup() {
  /////////////////////////////////////////// Setting up the Sine Wave Generator //////////////////////////////////////////////////////////
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
  gen.ApplySignal(SINE_WAVE, REG0, 1000);

  gen.EnableOutput(true);   // Turn ON the output - it defaults to OFF
  // There should be a 1000 Hz sine wave on the output of the AD9833
 

  // Important!: USe digitalWrite 10 LOW for Teensy 3.6
  digitalWrite(FNC_PIN, LOW);
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Serial.begin(115200);

  // Initialize DAC signal to HV converter to zero
  analogWriteResolution(12);
  analogWrite(A21, 0);
  delay(5000);
  analogWrite(A21, 0);

  /////////////////////////////////////////////////// setting up the ADC //////////////////////////////////////////////////////////////////
  pinMode(SensePin_R, INPUT);
  pinMode(SensePin_T, INPUT);
  pinMode(dispPin, INPUT);
  
  //Computation of the Sin and Cosine Array
  for (int i = 0; i < DFTSize; i++) {
    sinArray[i] = sin(-2 * pi * i * 1000 / SAMPLING_FREQUENCY);
    cosArray[i] = cos(-2 * pi * i * 1000 / SAMPLING_FREQUENCY);

  }
  adc->setAveraging(2); // set number of averages (helps elimitate noise and such)
  adc->setResolution(12); // set bits of resolution

  // it can be any of the ADC_CONVERSION_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED_16BITS, HIGH_SPEED or VERY_HIGH_SPEED
  // see the documentation for more information
  // additionally the conversion speed can also be ADACK_2_4, ADACK_4_0, ADACK_5_2 and ADACK_6_2,
  // where the numbers are the frequency of the ADC clock in MHz and are independent on the bus speed.
  adc->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED); // change the conversion speed
  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED); // change the sampling speed

  adc->startContinuous(SensePin_R, ADC_0);
  adc->startContinuous(SensePin_T, ADC_0);
  adc->startContinuous(dispPin, ADC_1);
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  sampling_period_us = round(1000000 * (1.0 / SAMPLING_FREQUENCY));

  loop_control_period = round(1000*(1.0/LOOP_FREQUENCY)); //////////////////////// This is for loop control If you need micro, change 1000 to 1000000

  ////////////////////////////////////// Initializing array buffer for the sine wave generator for target displacement //////////////////////////////
  for (int n = 0; n < LOOP_FREQUENCY*factor; n++){
    buffer_sine[n] = target_offset + (target_amp * cos((2 * pi * n * target_frequency) / LOOP_FREQUENCY - pi));
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  delay(500);

}

void loop() {
  loop_control_timing = millis();
  float Re_R = 0;
  float Im_R = 0;
  float Re_T = 0;
  float Im_T = 0;
  float displacement_ref = 0; 
  float displacement_est = 0;
  float displacement_true = 0;
  int output_signal;
  
  for (int i = 0; i < DFTSize; i++)
  {
    useconds_sampling = micros();
    Buffer_R[i] = analogRead(SensePin_R) * 3.3 / adc->getMaxValue(ADC_0);
    Buffer_T[i] = analogRead(SensePin_T) * 3.3 / adc->getMaxValue(ADC_0);
    while (micros() < (useconds_sampling + sampling_period_us)) {
      //wait...
    }
  }
  for (int i = 0; i < DFTSize; i++) {
    Re_R = Re_R + Buffer_R[i] * cosArray[i];
    Im_R = Im_R + Buffer_R[i] * sinArray[i];
    Re_T = Re_T + Buffer_T[i] * cosArray[i];
    Im_T = Im_T + Buffer_T[i] * sinArray[i];
  }

  V_Rm  = sqrt(Re_R * Re_R + Im_R * Im_R) * Gain_R;
  V_Tot = sqrt(Re_T * Re_T + Im_T * Im_T) * Gain_T;
  theta = atan2(Im_R, Re_R) + (12.0 + 180) * pi / 180 - atan2(Im_T, Re_T);

  if (theta > 6.28) {
    theta = theta - 2 * pi;
  }
//  Serial.print(theta*180/pi); // Making sure that theta is between 0 and pi/2
//  Serial.print("   ");
//  Serial.print(V_Rm);
//  Serial.print("   ");
//  Serial.println(V_Tot);
  /////////////////////////////////////////////////////////////////////////////////////
  /////////////////// Computing the exact capacitance of the actuators ////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  V_Junct = sqrt( V_Tot * V_Tot + V_Rm * V_Rm - 2 * V_Tot * V_Rm * cos(theta));
  phi     = pi - asin( V_Tot / V_Junct * sin(theta) );
  gam   = pi - phi;
  z       = pi / 2 - gam;
  I_Rm    = V_Rm / Rm;
  I_f     = V_Junct * ( 2 * pi * Cf * F);
  I_a     = sqrt(I_Rm * I_Rm + I_f * I_f - 2 * I_Rm * I_f * cos(z));
  x       = asin(I_f / I_a * sin(z));
  alpha   = pi / 2 - z - x;

  Zc      = 1 / (2 * pi * C * F);
  V_o     = I_a * sqrt(Rvs * Rvs + Zc * Zc) * Rvp / (Rvp + sqrt(Rvs * Rvs + Zc * Zc));
  y       = atan(Rvs / Zc);
  w       = pi / 2 - y;
  I_vp    = V_o / Rvp;
  k       = asin(I_vp / I_a * sin(pi - w));
  m       = pi - ( pi - w) - k;
  n       = m - alpha;
  V_a     = sqrt( V_Junct * V_Junct + V_o * V_o - 2 * V_Junct * V_o * cos(n) );
  p       = asin( V_o / V_a * sin(n));
  beta    = alpha - p;

  B       =  V_a * sin(beta) / I_a;
  Zca     =  ( B * (1 / tan(beta) / tan(beta) + 1) + sqrt(B * B * (1 / tan(beta) / tan(beta) + 1) * (1 / tan(beta) / tan(beta) + 1) - 4 * Rs * Rs)) / 2;
  Ca      =  1 / (2 * pi * Zca * F) * pow(10, 12);

  //////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////// Capacitance to displacement conversion ///////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////

  displacement_est = 0.7049+0.07832*exp(0.0028*Ca); // A calibrated function that maps the estimated displacement and the capacitance
  displacement_ref = tracking_generator();
  
  //////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////// Closed Loop Control using Ziegler-Nichols /////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////
  err[0] = err[1];
  err[1] = err[2];
  err[2] = displacement_ref - displacement_est;
  
  u_k[0] = u_k[1];
  u_k[1] = u_k[0] + (Kp + Ki*T/2 + Kd/T)*(err[2]) + (-Kp + Ki*T/2 - 2*Kd/T)*(err[1]) + Kd/T*(err[0]);
  u_k[1] = 0.8;
  if (u_k[1] <= (2.5)){
    output_signal =  round(u_k[1]/5.04*4095); 
    analogWrite(A21 ,output_signal);
  }
  else
    output_signal =  round(2.5/5.04*4095);
    analogWrite(A21 ,output_signal);

    ///////////////////////// Data to store in Matlab ////////////////////////////////////////
    displacement_true = analogRead(dispPin) * 3.3 / adc->getMaxValue(ADC_1);
//    Serial.println(displacement_ref);
    Serial.println(displacement_true);

    while(millis() < (loop_control_timing + loop_control_period)){
    //wait...
  }
digitalWrite(31,!digitalRead(31));
}

float tracking_generator(){
  float displacement = 0; 
  if (displacement_ref_FLAG == 0) {
    if (counter < (off_time * LOOP_FREQUENCY) ) {
      displacement = 0;
    }
    else if (counter < (off_time + on_time) * LOOP_FREQUENCY) {
      displacement = displacement_target;
    }
    counter = (counter + 1) % ((on_time + off_time)*LOOP_FREQUENCY);
    return displacement;
  }
  else {
    if (counter < LOOP_FREQUENCY*factor) {
      displacement = buffer_sine[counter];
    }
    counter = (counter + 1)%(LOOP_FREQUENCY*factor);
    return displacement;
  }
}
