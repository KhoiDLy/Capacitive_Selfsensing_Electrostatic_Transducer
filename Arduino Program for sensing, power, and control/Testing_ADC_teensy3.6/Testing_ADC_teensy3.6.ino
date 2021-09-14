#include <ADC_Module.h>
#include <ADC.h>

ADC *adc = new ADC(); // adc object;

void setup() {
  Serial.begin(115200);
  pinMode(A12, INPUT);
  adc->setAveraging(2); // set number of averages (helps elimitate noise and such)
  adc->setResolution(12); // set bits of resolution

  // it can be any of the ADC_CONVERSION_SPEED enum: VERY_LOW_SPEED, LOW_SPEED, MED_SPEED, HIGH_SPEED_16BITS, HIGH_SPEED or VERY_HIGH_SPEED
  // see the documentation for more information
  // additionally the conversion speed can also be ADACK_2_4, ADACK_4_0, ADACK_5_2 and ADACK_6_2,
  // where the numbers are the frequency of the ADC clock in MHz and are independent on the bus speed.
  adc->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED); // change the conversion speed
  adc->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED); // change the sampling speed

  adc->startContinuous(A12, ADC_1);

}

void loop() {
    float displacement_true = 0;
    displacement_true = analogRead(A12) * 3.3 / adc->getMaxValue(ADC_1);
    Serial.println(displacement_true);
}
