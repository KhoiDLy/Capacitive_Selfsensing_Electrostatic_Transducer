Resistors: R1 = 199MEG, R2 = 116.8K
voltage follower using LM324AN at the output of the voltage divider
DAQ 6212 at 400kHz and storing 100ms data


Procedure:

1. Connect the power supply to the DC-DC converter (EMCO Q101, EMCO C80, and PICO 5VV10)
2. The high voltage output of the DC-DC converters are connected to the voltage divider. The voltage divider acts as both load and a way to measure the output voltage and its ripples
3. First, check the voltage using the high voltage probe Fluke 80K-40
4. Then, start running the LabView VI to collect the data at 400kHz.`

DATA: 
THE FIRST COLLUMN IS TIME
THE SECOND COLLUMN IS DAQ INPUT (HIGH VOLTAGE AFTER VOLTAGE DIVIDER)
