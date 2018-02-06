void setupWifly()
{
    Serial.print("Free memory: ");
    Serial.println(wifly.getFreeMemory(),DEC);

    wifiSerial.begin(9600);

    if (!wifly.begin(&wifiSerial, &Serial)) {
        Serial.println("Failed to start wifly");
	terminal();
    }

    if (wifly.getFlushTimeout() != 10) {
        Serial.println("Restoring flush timeout to 10msecs");
        wifly.setFlushTimeout(10);
	wifly.save();
	wifly.reboot();
    }

    /* Join wifi network if not already associated */
    if (!wifly.isAssociated()) {
	/* Setup the WiFly to connect to a wifi network */
	Serial.println("Joining network");
	wifly.setSSID(mySSID);
	wifly.setPassphrase(myPassword);
	wifly.enableDHCP();

	if (wifly.join()) {
	    Serial.println("Joined wifi network");
	} else {
	    Serial.println("Failed to join wifi network");
	    terminal();
	}
    } else {
        Serial.println("Already joined network");
    }

    /* Ping the gateway */
    wifly.getGateway(buf, sizeof(buf));

    Serial.print("ping ");
    Serial.print(buf);
    Serial.print(" ... ");
    if (wifly.ping(buf)) {
	Serial.println("ok");
    } else {
	Serial.println("failed");
    }

    /*
    //check internet connection
    Serial.print("ping google.com ... ");
    if (wifly.ping("google.com")) {
	Serial.println("ok");
    } else {
	Serial.println("failed");
    }*/

    /* Setup for UDP packets, sent automatically */
    wifly.setIpProtocol(WIFLY_PROTOCOL_UDP);
    wifly.setHost(host, remote);	// Send UDP packet to this server and port

    Serial.print("MAC: ");
    Serial.println(wifly.getMAC(buf, sizeof(buf)));
    Serial.print("IP: ");
    Serial.println(wifly.getIP(buf, sizeof(buf)));
    Serial.print("Netmask: ");
    Serial.println(wifly.getNetmask(buf, sizeof(buf)));
    Serial.print("Gateway: ");
    Serial.println(wifly.getGateway(buf, sizeof(buf)));

    wifly.setDeviceID(deviceID);
    Serial.print("DeviceID: ");
    Serial.println(wifly.getDeviceID(buf, sizeof(buf)));

    //wifly.setHost("192.168.1.60", 8042);	// Send UPD packets to this server and port

    Serial.println("WiFly ready"); 
}

void sendMsg(String msg)
{ 
  if ((millis() - lastSend) > 1000 && rfidRead == true) {
        count++;
        if(wifiDebug == true)
        {
	  Serial.print("Sending message ");
	  Serial.println(count);
        }
        //int val = analogRead(0);
	//wifly.print("Hello, count=");
	wifly.println(msg);
	lastSend = millis();
    }
}

void recieveMsg()
{
   static char buffer[15];
   static int bufferIndex = 0;

   if(wifly.available()) {
        buffer[bufferIndex++] = wifly.read();
        if (buffer[bufferIndex-1] == 64 && bufferIndex < 15) {
            // End Of Line character received
            buffer[bufferIndex++] = '\0';  // Add a terminating null character
            bufferIndex = 0;
            
            Serial.println(buffer);
            //function to parse and clear UDP buffer
            processString(buffer); 
         }
         
         // Buffer Overflow
         if (bufferIndex > 15) 
         {
            if(wifiDebug == true)
            {
              bufferIndex = 0;
              Serial.println("Error! Buffer Overrun." + String(buffer));
              wifly.println(resend);
            }
         }
    }

    if (Serial.available()) {
        /* if the user hits 't', switch to the terminal for debugging */
        if (Serial.read() == 't') {
	    terminal();
	}
    }
}

void terminal()
{
    Serial.println("Terminal ready");
    while (1) {
	if (wifly.available() > 0) {
	    Serial.write(wifly.read());
	}

	if (Serial.available()) {
	    wifly.write(Serial.read());
	}
    }
}

void processString(char* s){
  //count number of ; to make sure string is correct
  int c = countChars( s, ';' );
  if( c == 4)
  {
    //if string format is correct, parse string by token
    char delims[] = ";";
    char *result = NULL;
    int count = 0;
    result = strtok( s, delims );
    while( result != NULL ) {
       //Serial.println(result);
       if(count != 4) 
       {
         rString[count] = result;
         //Serial.println(rString[count]);
       }
       else
       {
         break;
       }
       count++;
       result = strtok( NULL, delims );
    }
   
  }
  else if ( s[0] != 64 )
  {
    wifly.println(resend);
  }
  //convert char* to str
  //String str(parameter);
  //Serial.println(str);
}

int countChars( char* s, char c )
{
    return *s == '\0'
              ? 0
              : countChars( s + 1, c ) + (*s == c);
}
