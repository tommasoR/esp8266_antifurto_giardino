#include <ESP8266WiFi.h>
//versione 1.0
//ultima modifica 6/2/2016
/* Insertita gestione per BUILTIN_LED e avvisare che antifurto ha suonato
 */


//////////////////////
// WiFi Definitions //
//////////////////////
//const char WiFiAPPSK[] = "sparkfun";
const char* ssid = "SSID_NONNO";
const char* password = "0119494246";

/////////////////////
// Pin Definitions //
/////////////////////
//https://github.com/ekstrand/ESP8266wifi
const int DIGITAL_PIN_RELE = 2; // GPIO2 rele a 5 volt
const int DIGITAL_PIN_SWITCH = 0;//gpio0 conatatto magnetico


//const int LED_PIN = 5; // Thing's onboard, green LED
//const int ANALOG_PIN = A0; // The only analog pin on the Thing
//const int DIGITAL_PIN = 12; // Digital pin to be read

//Variabili
unsigned long currentMillis = 0L;
unsigned long EventoIngressoMillis = 0L;
unsigned long SuonaPerMillis = 600000L;
bool allarme_attivo = true;

WiFiServer server(80);


void initHardware()
{
  Serial.begin(115200);
  pinMode(DIGITAL_PIN_SWITCH, INPUT_PULLUP);
  pinMode(DIGITAL_PIN_RELE, OUTPUT);
  digitalWrite(DIGITAL_PIN_RELE, LOW);
  // Don't need to set ANALOG_PIN as input,
  // that's all it can be.
  pinMode(BUILTIN_LED, OUTPUT);
}

void setupWiFi()
{
  WiFi.mode(WIFI_AP);

  // Do a little work to get a unique-ish name. Append the
  // last two bytes of the MAC (HEX'd) to "Thing-":
  uint8_t mac[WL_MAC_ADDR_LENGTH];
  WiFi.softAPmacAddress(mac);
  //  String macID = String(mac[WL_MAC_ADDR_LENGTH - 2], HEX) +
  //                 String(mac[WL_MAC_ADDR_LENGTH - 1], HEX);
  //  macID.toUpperCase();
  //  String AP_NameString = "ESP8266 Thing " + macID;
  //
  //  char AP_NameChar[AP_NameString.length() + 1];
  //  memset(AP_NameChar, 0, AP_NameString.length() + 1);
  //
  //  for (int i=0; i<AP_NameString.length(); i++)
  //    AP_NameChar[i] = AP_NameString.charAt(i);

  WiFi.softAP(ssid, password);
}

void readContatto() {
  int ingresso = digitalRead(DIGITAL_PIN_SWITCH);
  if (ingresso) {
    delay(200);
    if (digitalRead(DIGITAL_PIN_SWITCH) && ((currentMillis - EventoIngressoMillis) > 120000L)) {
      EventoIngressoMillis = currentMillis;
    }
  }
}

void attivaSirena() {
  if((currentMillis - EventoIngressoMillis) < SuonaPerMillis){
    digitalWrite(DIGITAL_PIN_RELE, HIGH);       // turn on Sirena
    ESP.deepSleep(25000000, WAKE_RF_DEFAULT); 
  } 
}

void setup()
{
  initHardware();
  setupWiFi();
  server.begin();
}

void loop()
{
  currentMillis = millis();

  // Check if a client has connected
  WiFiClient client = server.available();
  if (!client) {
    return;
  }

  // Read the first line of the request
  String req = client.readStringUntil('\r');
  Serial.println(req);
  client.flush();

  // Match the request
  int val = -1; // We'll use 'val' to keep track of both the
  // request type (read/set) and value if set.
  if (req.indexOf("/led/0") != -1)
    val = 0; // Will write LED low
  else if (req.indexOf("/led/1") != -1)
    val = 1; // Will write LED high
  else if (req.indexOf("/read") != -1)
    val = -2; // Will print pin reads
  // Otherwise request will be invalid. We'll say as much in HTML

  // Set GPIO2 according to the request
  if (val >= 0)
    digitalWrite(DIGITAL_PIN_RELE, val);

  client.flush();

  // Prepare the response. Start with the common header:
  String s = "HTTP/1.1 200 OK\r\n";
  s += "Content-Type: text/html\r\n\r\n";
  s += "<!DOCTYPE HTML>\r\n<html>\r\n";
  // If we're setting the LED, print out a message saying we did
  if (val >= 0)
  {
    s += "LED is now ";
    s += (val) ? "on" : "off";
  }
  else if (val == -2)
  { // If we're reading pins, print out those values:
    s += "Digital Pin 0 = ";
    s += String(digitalRead(DIGITAL_PIN_SWITCH));
    s += "<br>"; // Go to the next line.
    s += "Digital Pin 2 = ";
    s += String(val);
    s += "<br>"; // Go to the next line.
    s += "valore variabile EventoIngressoMillis= ";
    s += String(EventoIngressoMillis);
  }
  else
  {
    s += "Invalid Request.<br> Try /led/1, /led/0, or /read.";
  }
  s += "</html>\n";

  // Send the response to the client
  client.print(s);
  delay(1);
  Serial.println("Client disonnected");

  // The client will actually be disconnected
  // when the function returns and 'client' object is detroyed

  //gestione allarme
  if (allarme_attivo) {
    readContatto();
    if (EventoIngressoMillis > 0) {
      //evento di apertura porta valido per allarme attendo un minuto prima di suonare
      if ((currentMillis - EventoIngressoMillis) > 600000L) {
        attivaSirena();
      }
    }
  }
}




