void keyPressed()
{
  if(key == 'g' || key == 'G')
  {
    sm.switchDebug();
    global.update = true;
  } 
  
  if (key=='s' || key=='S')
  {
     saveFrame(timestamp()+"_##.png");
  }
  
  if (key=='p' || key=='P') 
  {
      savePDF = true;
  }
  
  if(key == 'v' || key == 'V')
  {
        vm.switchDebug();
        global.update = true;
  }
  
  if(key == 't' || key == 'T')
  {
        for( Chair c : chairs )
        {
          c.switchTDebug();
        }
        println("Twitter Debug");
        global.update = true;
  }
  
  if(key == 'd' || key == 'D')
  {
        if(global.debug)
        {
           global.debug = false;
           global.update = true;
        }
        else
        {
            global.debug = true;
        }

  }
  
  if(key == 'u' || key == 'U')
  {
      if(global.debugUDP)
      {
        global.debugUDP = false;
        println("EXIT DEBUG UDP MODE");
      }
      else
      {
        global.debugUDP = true;
        println("DEBUG UDP MODE");
      }
  }
}
