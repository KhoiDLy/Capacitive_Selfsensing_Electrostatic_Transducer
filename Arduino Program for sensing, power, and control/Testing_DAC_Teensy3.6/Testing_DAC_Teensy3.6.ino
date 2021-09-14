void setup() {

  // put your setup code here, to run once:
pinMode(13,OUTPUT);
digitalWrite(13,HIGH);
analogWriteResolution(12);
analogWrite(A21,0);
delay(1000);
}

void loop() {
  // put your main code here, to run repeatedly:
//analogWrite(A21,400); // maximum is 4096 for 5V out, which is 10kV
//delay(500);
//analogWrite(A21,800); // maximum is 4096 for 5V out, which is 10kV
//delay(500);
//analogWrite(A21,1200); // maximum is 4096 for 5V out, which is 10kV
//delay(500);
//analogWrite(A21,1600); // maximum is 4096 for 5V out, which is 10kV
//delay(500);
//analogWrite(A21,2000); // maximum is 4096 for 5V out, which is 10kV
//delay(500);
//analogWrite(A21,2400); // maximum is 4096 for 5V out, which is 10kV
//delay(3000);
analogWrite(A21,4095); // maximum is 4096 for 5V out, which is 10kV
//delay(3000);
//analogWrite(A21,0); // maximum is 4096 for 5V out, which is 10kV
//delay(5000);
//analogWrite(A21,800); // maximum is 4096 for 5V out, which is 10kV
//delay(5000);
//analogWrite(A21,1200); // maximum is 4096 for 5V out, which is 10kV
//delay(5000);
//analogWrite(A21,1600); // maximum is 4096 for 5V out, which is 10kV
//delay(5000);
//analogWrite(A21,2000); // maximum is 4096 for 5V out, which is 10kV
//delay(5000);
//analogWrite(A21,2400); // maximum is 4096 for 5V out, which is 10kV
//delay(20000);
}
