//UDP handler, use to pass messages to objects
void initializeUDP()
{
  //udp needs to be global for the recieve event handler to work
  if(global.udpCom)
  {
    udp = new UDP( this, 4001 );   
    udp.listen(true);
    //udp.log(true);         // <-- printout the connection activity
  }
}


