//Wifly UDP and RFID

#include <WiFlyHQ.h>
#include <Adafruit_PN532.h>
#include <SoftwareSerial.h>

SoftwareSerial wifiSerial(8,7);

#define SCK  (2)
#define MOSI (3)
#define SS   (4)
#define MISO (5)

Adafruit_PN532 nfc(SCK, MISO, MOSI, SS);

//recieve test pin
boolean ledState = false;

/* Change these to match your WiFi network */
const char mySSID[] = "wifly";
const char myPassword[] = "easy1234";
const char host[] = "172.16.2.2";
const char deviceID[] = "WiFly-003";
String trigger = "h";
int remote = 4001;
WiFly wifly;

//parsed udp buffer
char rChar[4];
String rString[4];
char buf[32];
uint32_t lastSend = 0;
uint32_t count=0;
String resend = "resend";

//rfid buffer
uint32_t cardid;
boolean rfidRead = false;

//rgb leds
const int r = 9;
const int g = 10;
const int b = 11;

//debug
boolean wifiDebug = true;
boolean rfidDebug = false;
boolean ledDebug = false;

void terminal();

void setup(void) {
  Serial.begin(115200);
  
  setupWifly();
  setupRFID(); 
  setupLED();
}


void loop(void) {
  //check if device reads rfid card
  readRFID();
  //if card is read and timer is satisfied, send msg over udp 
  sendMsg(String(cardid));
  //recieve message from PC
  recieveMsg();
  //turn on LEDS
  switchLED();
}


