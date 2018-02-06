void setupLED()
{
    pinMode(r,OUTPUT);
    pinMode(g,OUTPUT);
    pinMode(b,OUTPUT);
    if(ledDebug == true)
    {
      pinMode(13,OUTPUT);
    }
}

void switchLED()
{
  analogWrite(r, rString[0].toInt());
  analogWrite(g, rString[1].toInt());
  analogWrite(b, rString[2].toInt());
  if(ledDebug == true)
  {
    if(rString[3].equals("h"))
    {
      digitalWrite(13,HIGH);
    }
    else
    {
      digitalWrite(13,LOW);
    }
  }
}
