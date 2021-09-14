Testing step response of the HIGH VOLTAGE OUTPUT relative to the DAC input

INPUT: DAC output of the Microcontroller NXP K66
OUTPUT: HIGH VOLTAGE using probe FLUKE 80K-40

Three types of load: 100MEG, 400MEG, and one actuator with no-hole sensing electrode and 100MEG in parallel for draining + 136g weight stand +100g 

7 values of input signals: analogWrite(x) with x = 500, 1000, 1500, 2000, 2500, 3000, 3500

Each experiment (21 total) is repeated 8 times for average and standard deviation

The step reponses have 3 seconds of DAC ON and 5 seconds of DAC OFF


SAMPLING RATE OF THE STEP RESPONSE IS 200HZ (CHECK CSV FILE FOE CONFIRMATION)
CHANNEL 1 IS INPUT VOLTAGE (DAC)
CHANNEL 2 IS OUTPUT VOLTAGE (HV)