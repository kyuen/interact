// class that defines the AROBject, both the AR detection and display are handled inside this class
class Chair {
  boolean display = false;
  //////////////////ARTRACKING Variables///////////
  int objID; // keep track of the current the ID of the object (corresponds with the ID i of the marker)
  PVector[] marker;  //marker points
  //ToxicLibs Library
  Vec2D vec1;        //absolute position
  Vec2D vec2;        //pointing orientation
  Vec2D prevPos;     //previous position
  Vec2D oct;    //pointing area
  Vec2D headingVec;  //absolute heading
  Line2D ref;        //heading reference line
  float angle = 0; 
  float slope = 0;
  int octLoc = 0;
  float octA = 0;
  int size = 100; //relative radius of marker
  boolean markerLive = false;
  boolean moved = false;
  //////////////////ARDUINO Variables////////////// 
  String ip;
  int lastReceived = 0;
  int recieveInterval = 1200;
  int lastSent = 0;  //time of last any message
  int prevSent = 0;  //time of last real msg
  int sendInterval = 2000;  //send interval
  int curTime = 0; //elapsed time
  int blockInterval = 60000; //check if any message has been sent in the last 1 min
  String prevMsg = null;
  ///////////////////Group/////////////////////////
  int personID = 100;
  ArrayList<Integer> bucketsIds = new ArrayList<Integer>();
  ArrayList<Integer> comparedTo = new ArrayList<Integer>();
  //////////////////twitter///////////////////////
  String user, pass, cs, csSecret, token, tokenSecret;
  TwitterHandler th;
  boolean twitterDebug = false;
  int lastTweet = 0;
  int tweetInterval = 500;  //send interval
  String p_update;
  String c_update;
  String prevTMsg_p = null;
  String prevTMsg_c = null;
  ArrayList<Chair> oriented = new ArrayList<Chair>();
  Hashtable<Integer,String> orientedMap = new Hashtable<Integer,String>();
  ArrayList<Chair> neighbors = new ArrayList<Chair>();
  Hashtable<Integer,String> neighborsMap = new Hashtable<Integer,String>();
  
  Chair(int ID, String ip_str, String a, String p, String auth, String authS, String aT, String aTS) {
    //hardware identifiers
    this.objID = ID;
    this.ip = ip_str;
    //hardware properties
    this.vec1 = new Vec2D();
    this.vec2 = new Vec2D();
    this.headingVec = new Vec2D();
    this.oct = new Vec2D();
    this.prevPos = new Vec2D(0,0); 
    this.ref = new Line2D(new Vec2D(0,0), new Vec2D(0,0));
    prevPos.set(vec1);
    
    //twitter
    this.user = a;
    this.pass = p;
    this.cs = auth;
    this.csSecret = authS;
    this.token = aT;
    this.tokenSecret = aTS;
    th = new TwitterHandler(this.user, this.cs, this.csSecret, this.token, this.tokenSecret);
  }

  void run() {
    //this.drawLoc();
    this.display();
    if(millis() - this.lastTweet > this.tweetInterval  && (vec1.x != 0.0 && vec1.y != 0.0))
    {
     this.lastTweet = millis();
     if(twitterDebug)
     {
       println("=====" + this.objID + "=====");
     }
     this.tweetUpdate();
     this.tweetPerson();
    }
  }
  
  void switchDebug()
  {
     if(twitterDebug == true)
     {
       twitterDebug = false;
     }
     else
     {
       twitterDebug = true;
     }
  }
  
   
  void switchTDebug()
  {
     if(display == true)
     {
       display = false;
     }
     else
     {
       display = true;
     }
  }
  
  void checkUDP()
  {
    //will unblock the recieve listener by sending out the terminating char
    if( (millis() - this.lastSent) > blockInterval)
    {
       int port = 4000;
       String msg = "@";
       if( global.debugUDP == true)
       {
     
        println( "send: \"" + msg + "\" to "+ this.ip + " on port " + port );
       }
       //udp is a global object that can be accessed by any object
       if(global.udpCom == true)
       {
         udp.send( msg, this.ip, port );
       }
        this.lastSent = millis();
        prevMsg = msg;
    }    
  }
  
  void checkPerson()
  {
    //if marker is live now and wasn't before
    if (nya.isExistMarker(objID) && markerLive == false)
    { 
      
        String RFID = peopleMap.get(this.objID);
        //if person exists
        if(!RFID.isEmpty() && RFID != null && personID != 100)
        {
          //reset RFID
          Person person = (Person) people.get(personID-1);
          //rest person
          person.setPos(new Vec2D(personID*150, (720-50)));
          //reset person
          personID = 100;
          
          //destroy friendship
          int id = rfidMap.get(RFID);
          Person p = (Person) people.get(id-1);
          th.destroyFriendship(p.user);
          
          String RFIDnull = "";
          peopleMap.put(this.objID, RFIDnull);
          
          global.update = true;
        }
        global.update = true;
        markerLive = true;
    }
    else
    {
        markerLive = false;
    }
  }
  

  
  void calculatePos()
  {
     // scale from AR detection size to sketch display size (changes the display of the coordinates, not the values)
    scale(global.displayScale);
    //Check if marker exists
    if ((nya.isExistMarker(this.objID))) {  
        // the following code is only reached and run if the marker DOES EXIST
        //marker is Live
        markerLive = true;
        
        // get the four marker coordinates into an array of 2D PVectors
        marker = nya.getMarkerVertex2D(objID);
        
        //calculate center from 4 corners of marker and set position
        float xCenter = (marker[0].x + marker[1].x + marker[2].x + marker[3].x)/marker.length; 
        float yCenter = (marker[0].y + marker[1].y + marker[2].y + marker[3].y)/marker.length; 
        
        //check if it has moved with a tolerance of one pixel
        if((prevPos.x+1 > xCenter && prevPos.x - 1 < xCenter) && (prevPos.y+1 > yCenter && prevPos.y - 1 < yCenter))
        {
            moved = false;
            prevPos.set(vec1);
        }
        else
        {
            moved = true;
            //set new absolute position
            this.prevPos.set(vec1);
            this.vec1.set(xCenter, yCenter);
            
            //update angles
            //calulate orientation of marker, returns range from -PI to PI
            float a = atan2( marker[3].y - marker[0].y, marker[3].x - marker[0].x );
            calculateAngle(this.vec1, a);
            //calculate oct orientation using 8 octs, quantize 2dvector from pos and angle       
            calculateOctant(a);
            //slope is y/x, flipped oct
            calculateSlope();
            //heading is the change in <x,y>
            setHeading();
            //set extented heading
            setOverlay();

            global.update = true;
        }
    }
    else if(!nya.isExistMarker(this.objID))
    {
        prevPos.set(vec1);
        markerLive = false;
        //println(this.objID + " is not live");
    }    
  }
  
  float locateNeighbor(Vec2D v1, Vec2D v2)
  {
    return atan2( v1.y - v2.y, v1.x - v2.x );
  }
  
  
  void drawMarkerV()
  {
       // draw each vector both textually and with a red dot
      for (int j=0; j<marker.length; j++) 
      {
        String s = "(" + int(marker[j].x) + "," + int(marker[j].y) + ")";
        fill(255);
        noStroke();
        fill(255, 20, 147);
        ellipse(marker[j].x, marker[j].y, 5, 5);
      }
  }
  
  void calculateOctant(float angle)
  {
      //println(degrees(angle));
      this.octA = round( angle*8/TWO_PI ) * TWO_PI/8;
      this.octLoc = (int) map(this.octA, -PI, PI, 0, 7);
      //this.octLoc = (int) map(this.octA, 0, TWO_PI, 1, 8);
      //this.octLoc = int((degrees(angle)-1)/45);
      float qEndX = vec1.x + 50 * cos(this.octA);
      float qEndY = vec1.y + 50 * sin(this.octA);
      oct.set(qEndX, qEndY);
  }
  
  
  void calculateAngle(Vec2D v1, float a)
  {
     this.angle  = a;
     float endX  = v1.x + 50 * cos(a);
     float endY  = v1.y + 50 * sin(a);
     vec2.set(endX, endY);
  }
  
  void calculateSlope()
  {
    //slope = (y2 - y1)/(x2 - x1)
    slope = (this.vec1.y - this.vec2.y)/(this.vec1.x - this.vec2.x);
  }
 
 void setHeading()
 {
   //<x2-x1, y2-y1> 
   headingVec.set(int(this.vec1.x - this.vec2.x),(this.vec1.y - this.vec2.y));
 }
 
 void setOverlay()
 {
     //point slope formula, y = m(x-Px) + Py
     float  y1 = this.slope*(width-this.vec1.x) + this.vec1.y;
     float  x1 = this.vec1.x + (y1 - this.vec1.y)/this.slope;
     float  y2 = this.slope*(0-this.vec1.x) + this.vec1.y;
     float  x2 = this.vec1.x + (y2 - this.vec1.y)/slope;
   
     ref.set(new Vec2D(x1,y1),new Vec2D(x2,y2));
 }
 
 void drawOverlay()
 {
     stroke(255);
     strokeWeight(1);
     line(ref.a.x,ref.a.y,ref.b.x,ref.b.y);
 }
 
  // the display chair information
  void display () {
    this.drawOverlay();
    
    // set the text alignment (to the left) and size (small)
    textAlign(LEFT, TOP);
    textSize(10);
    noStroke();
    
    //oct orientation
    stroke(20, 150, 0);
    strokeWeight(4);
    line(vec1.x, vec1.y, oct.x, oct.y);
    //actual orientation
    stroke(255, 20, 147);
    line(vec1.x, vec1.y, vec2.x, vec2.y);
    ellipseMode(CENTER);
    //center point
    noFill();
    ellipse(vec1.x, vec1.y, 3,3); 
    //radius of chair
    ellipse(this.vec1.x, this.vec1.y, this.size, this.size);  
        
    //chair tag
    textSize(14);
    String chair = "chair " + objID;
    fill(255);
    noStroke();
    rect(vec1.x, vec1.y-(this.size-10), textWidth(chair) + 3, textAscent() + textDescent() + 3);
    fill(0);
    text(chair, vec1.x+2, vec1.y-(this.size-10));     
  } 
  
  //get Normalized Direction
  int getNormDirection()
  {
    return octLoc;
  }
  
  Vec2D getPos()
  {
    return vec1;
  }
  
  //set RFID
  void setRFID(String r)
  {  
     this.personID = rfidMap.get(r);
     peopleMap.put(this.objID, r);
  }

  void drawLoc()
  {
     textSize(10);
     fill(20, 150, 0);
     String label = "" + this.octLoc ;
     if( octLoc > 3)
     {
       text(label, oct.x, oct.y - 10);
     }
     else
     {
       text(label, oct.x, oct.y + 15);
     } 
  }
  
  void setBuckets(ArrayList buckets)
  {
   bucketsIds.clear();
   bucketsIds.addAll( buckets );
  }
  
  
  //reset person in chair
  void resetPerson()
  {
    personID = 100;
    peopleMap.put(this.objID, "");
  }
  
  void addNeighbor(List<Chair> n)
  {
      neighbors.clear();
      neighbors.addAll(n);
      
      for(int x = 0; x < neighbors.size(); x++)
      {
         Chair t = (Chair) neighbors.get(x);

         if( this.objID == t.objID)
         {  
           neighbors.remove(x);
         }
      }  
  }
  
  void addOriented(List<Chair> n)
  {
      oriented.clear();
      oriented.addAll(n);
  }
  
  void tweetPerson()
  {
    String update = timestamp() + "\n";
    int count = 0;
    String msg = "";
    String nmsg = "";
    ArrayList<Person> n_users = new ArrayList<Person>();
    ArrayList<Person> o_users = new ArrayList<Person>();
    
    String RFID = peopleMap.get(this.objID);
    
    if (RFID != null && !RFID.isEmpty()) {
       //current user on chair
       int person = rfidMap.get(RFID);
       Person p = (Person) people.get(person-1);
       msg = "@" + p.user + ", You are sitting on me.\n";

       //get list of neighbors sitting
       if(!neighbors.isEmpty())
       {       
           for(Chair c: neighbors)
           {
               String c_rfid = peopleMap.get(c.objID);
               if( c_rfid != null && !c_rfid.isEmpty() && rfidMap.containsKey(c_rfid) )
               {
                     int pID2 = rfidMap.get(c_rfid);
                     Person p2 = (Person) people.get(pID2-1);
                     n_users.add(p2);
               }
           }
       }
       
       //iterate list of neighbors sitting
       if( !n_users.isEmpty())
       {
           for(int x = 0; x < n_users.size(); x++)
           {
                Person p2 = (Person) n_users.get(x);
                if(x == n_users.size()-1)
                {
                    msg += "@" +  p2.user + " ";
                }
                else
                {
                    msg += "@" +  p2.user + ",";
                }
            } 
            msg += "is sitting near you";
        }
        else
        {
           msg += "No one is sitting near you.";
        }
     }
     
     //get list of oriented sitting
     if(!oriented.isEmpty())
     {  
          for(Chair c: oriented)
           {
               String c_rfid = peopleMap.get(c.objID);
               if( c_rfid != null && !c_rfid.isEmpty() && rfidMap.containsKey(c_rfid) )
               {
                     int pID2 = rfidMap.get(c_rfid);
                     Person p2 = (Person) people.get(pID2-1);
                     o_users.add(p2);
               }
           }
    }
    
    //iterate list of oriented sitting          
    if( !o_users.isEmpty())
    {
         for(int x = 0; x < o_users.size(); x++)
         {
              Person p2 = (Person) o_users.get(x);
              if(x == n_users.size()-1)
              {
                  nmsg += "@" +  p2.user + " ";
              }
              else
              {
                  nmsg += "@" +  p2.user + ", ";
              }
          } 
          nmsg += "is oriented with you.";
      }
      else
      {
         nmsg += "\n" + "I am not oriented with/towards another chair.";
      }

    
     if(msg != null)
     {
       if(!msg.equals(this.prevTMsg_p))
       {
         update += msg + "\n" + nmsg;
         if(twitterDebug)
         {
           println("length:" + update.length() + ". " + update);
         }
         th.postTweet(msg + "\n" + nmsg);
         //th.postTweet(update);
         this.prevTMsg_p = msg;
       }
     }
  }
 
  void tweetUpdate()
  {
     String update = formatedTimestamp() + "\n";
     String msg = "\n" + "My Location: " + this.vec1.toString() + "\n" + "My Heading: " + degrees(this.angle) + " degrees" ;
     String nmsg = formatedTimestamp() + "\n";
     if(!neighbors.isEmpty())
     {  
          nmsg = "I am neighbors of";
          for(int x = 0; x<neighbors.size(); x++)
          {
 
            Chair t = (Chair) neighbors.get(x);
            if(x == neighbors.size()-1)
            {
              nmsg += " @" +  t.user + ".";
              //update +=    t.user + ".";
            }
            else
            {
              nmsg += " @" +  t.user + ",";
              //update +=  t.user + ", ";
            }
          } 
     }
     else
     {
       nmsg = "I don't have any neighbors.";
     }
     
     if(!oriented.isEmpty())
     {  
          nmsg += "\n" + "I am oriented with/towards";
          for(int x = 0; x<oriented.size(); x++)
          {
            Chair t = (Chair) oriented.get(x);
            if(x == oriented.size()-1)
            {
              nmsg += " @" +  t.user + ".";
              //update +=    t.user + ".";
            }
            else
            {
              nmsg += " @" +  t.user + ",";
              //update +=  t.user + ", ";
            }
          } 
     }
     else
     {
       nmsg += "\n" + "I am not oriented with/towards another chair.";
     }
     
     String complete = msg + "\n" +  nmsg;
     
     if(!complete.equals(this.prevTMsg_c))
     {
       update += msg;
       if(twitterDebug)
       {
          println( update + nmsg); 
       }
       th.postTweet(update);
       th.postTweet(nmsg);
       this.prevTMsg_c = complete;
     }
  }

  //send a udp message
  void sendUDP(String msg)
  {
    //only send message once and at 1 sec interval
      if(millis() - prevSent >  sendInterval && prevMsg != msg)
      {
         //recieving port on all devices is the same
         int port = 4000;
         if( global.debugUDP == true)
         {
              println( "send: \"" + msg + "\" to "+ this.ip + " on port " + port );
         }
         //udp is a global object that can be accessed by any object
         if(global.udpCom == true)
         {
           udp.send( msg, this.ip, port );
         }
         this.prevSent = millis();
         this.lastSent = millis();
         this.prevMsg = msg;
      }
   }
   
  //turn leds off
  void resetLED()
  {
    String msg = "0;0;0;L;@";
    //only send message once and at 1 sec interval
    if(millis() - prevSent >  sendInterval)
    {
      if(global.udpCom)
      {
        if( global.debugUDP == true)
        {
          println( "send: \"" + msg + "\" to "+ this.ip + " on port " + 4000 );
        }
        if(global.udpCom)
        {
        udp.send( msg, this.ip, 4000 );
        }
      }
       prevSent = millis();
       lastSent = millis();
       prevMsg = msg;
    }
  }
}
