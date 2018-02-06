void initializePeople()
{
  if (db.connect())
  {
    db.query("SELECT * FROM users");
    while (db.next())
    {
      //(Id, posX, posY, firstName, lastName, uid, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)
      people.add(new Person(db.getInt(1)-1,db.getInt(1)*150,(720-50), db.getString(2), db.getString(3),db.getString(4),db.getString(5),db.getString(6),db.getString(7),db.getString(8),db.getString(9),db.getString(10)));
      rfidMap.put(db.getString(4),db.getInt(1));
    }
  }
}

void initializeChairs()
{
  if (db.connect())
  {
    db.query("SELECT * FROM chairs");
    while (db.next())
    {
      //(Id, markerId, ip_str, twitterAcct, twitterPass, OAuthK, OAuthS, accessToken, accessTokenS)
      chairs.add(new Chair(db.getInt(2), db.getString(3),db.getString(4),db.getString(5),db.getString(6),db.getString(7),db.getString(8),db.getString(9)));
      ipMap.put(db.getString(3),db.getInt(2));
       //println(db.getInt(1)*100);
    }
    //println(chairs);
  }
}

void initializeSM()
{
  //setup the spatial hash map manager
  sm = new SpatialManager();
  sm.setup(1440, 720, 240);
}

void initializeVM()
{
  //setup video manager
  //world width, world height, this applet, camera type "other" or "kinect"
  vm = new VideoManager(global.arWidth, global.arHeight, this, "other");
}

void initializeGM()
{
  //setup new graph mangaer
  gm = new GraphManager();
}

void initializePeopleMap()
{
  //setup new graph mangaer
  for(Chair c: chairs)
  {  
    String RFID = "";
    peopleMap.put(c.objID, RFID);
  }
}

void runSpatialManager()
{
     //reset spatial hash map
     sm.clearBuckets();
     groups.clear();

     //register all objects in buckets
     for(Chair chair: chairs)
     {
       sm.registerObject(chair);
     }

     //iterate through whole hashmap through key
     int prevKey = 10;
     Set keySet = sm.bucketMap.keySet();
     Iterator keyIterator = keySet.iterator();
     while (keyIterator.hasNext() ) {
        Integer curKey = (Integer) keyIterator.next();
        int num = sm.bucketMap.get(curKey);
        //only use key once when found, ignore duplicate keys
        if(num >= 2)
        {
          //create new gooup is bucketMap contains more
          groups.add(new Group(sm.buckets.get(curKey),num,curKey));
          //println(sm.buckets.get(curKey));
          prevKey = curKey;
        }
     }

     //inverse map
     //TreeMultimap<chair, Integer> inverse = Multimaps.invertFrom(sm.buckets, TreeMultimap.<Integer, chair> create());
    
     //query nearby objects for each object example
     /*List<chair> nearbyObjects = new ArrayList<chair>();
     for(chair chair: chairs)
     {
        nearbyObjects = sm.getNearby(chair);
        for (chair obj : nearbyObjects) {
          if (obj != null && chair != obj) {
            println("OBJECT " + chair.objNum + " is in proximity to OBJECT "+ obj.objNum);         
          }
        }
     }*/
}

void displayFrameRate()
{    
    //display framerate
    textSize(30);
    String frames = ceil(frameRate) + " fps";
    fill(0,100,255);
    text(frames,50+5,50+5);
}

void queryChairStatus(String ip, String msg)
{
  if(msg.equals("resend"))
  {
    int o  = ipMap.get(ip);
    Chair chair = (Chair) chairs.get(o);
    chair.sendUDP(chair.prevMsg);
  }
  else
  {
    int o  = ipMap.get(ip);
    Chair chair = (Chair) chairs.get(o);
    int p  = rfidMap.get(msg);
    Person person = (Person) people.get(p-1);
    
    String fromTable = peopleMap.get(chair.objID);
    //set person to chair and set rfid to chair
    if(!peopleMap.containsValue(msg))
    {
      person.setPos(chair.vec1);
      person.checkChair();
      chair.setRFID(msg);
      chair.th.createFriendship(person.user);
      chair.lastReceived = millis();
      global.update = true;
    } 
  }
}

float formatDec(float n)
{
    //round to 2 decimal places
    //Multiply by 1000, round, and divide back by 1000
    return (round(n*1000))/1000;
}

void deleteDupGroups()
{
    for(int x=0; x<groups.size(); x++)
    {
        Group g1 = (Group) groups.get(x);
        for(int y=0; y<groups.size(); y++)
        {  
            Group g2 = (Group) groups.get(y);
            if(g1.groupID != g2.groupID)
            {  

                if(g1.grouped.equals(g2.grouped))
                {
                  groups.remove(g2);
                }
            }
        }    
    }    
}

void checkGrouped()
{
    groupMap.clear();
    //populate groupMap
    for(SubGroup sb : subgroups)
    { 
      for(Chair chair : sb.grouped)
      {
          groupMap.put(chair.objID, sb.groupID);
      }
    }
    //query group map for objects that are not grouped
    for(Chair c: chairs)
    {  
        if(!groupMap.containsKey(c.objID))
        {
            c.resetLED();
        }
    }
}

void deleteDupSGroups()
{  
   //sort grouped listed by objNum
    for(SubGroup sb : subgroups)
    { 
      Collections.sort(sb.grouped, new Comparator<Chair>(){
            @Override
            public int compare(Chair c1, Chair c2) {
                 return ComparisonChain.start()
                       .compare(c1.objID, c2.objID).result();
                       //...
                       //.compare(c1.ip, c1.ip).result();
      }});
      //println(sb.grouped);
      //println(sb.groupID);
    }
      
    for(int x=0; x<subgroups.size(); x++)
    {
        SubGroup g1 = (SubGroup) subgroups.get(x);
        for(int y=0; y<subgroups.size(); y++)
        {  
            SubGroup g2 = (SubGroup) subgroups.get(y);
            if(g1.groupID != g2.groupID)
            {  
                if(g1.grouped.equals(g2.grouped))
                {
                  subgroups.remove(g2);
                  
                }
            }
        }
    }
}

String formatedTimestamp()
{
  Date d = new Date();
  return d.toString();
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

