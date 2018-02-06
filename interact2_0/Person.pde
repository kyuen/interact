class Person
{
  String RFID;
  String fName, lName;
  String name;
  int ID;
  Vec2D pos;
  int currChair;
  int prevChair;
  String user, pass, cs, csSecret, token, tokenSecret;
  /////////////twitter4j/////////////////////
  TwitterHandler th;
  
  Person(int id, float x, float y, String fname, String lname, String rfid,String u, String p, String c, String cs, String t, String ts)
  {
    this.ID = id;
    this.pos = new Vec2D(x,y);
    this.fName = fname;
    this.lName = lname;
    this.name = fname + " " + lname;
    this.RFID = rfid;
    this.cs = c;
    ///twitter handler
    this.csSecret = cs;
    this.token = t;
    this.tokenSecret = ts;
    this.user = u;
    this.pass = p;
    th = new TwitterHandler(this.user, this.cs, this.csSecret, this.token, this.tokenSecret);
  }
  
  void run() {
    //this.checkChair();
    this.display();
  }
  
  void display()
  {
    noStroke();
    fill(0,191,255);
    ellipseMode(CENTER);
    ellipse(pos.x, pos.y, 50,50); 
    
    //chair tag
    textSize(14);
    String person = fName +  " " + lName;
    fill(255);
    noStroke();
    rect(pos.x, pos.y, textWidth(person) + 3, textAscent() + textDescent() + 3);
    fill(0);
    text(person, pos.x, pos.y+2);
  }
  
  void setPos(Vec2D p)
  {
    this.pos = p;
  }
  
  void checkChair()
  {
      if(peopleMap.containsValue(this.RFID))
      {      
           Set keySet = peopleMap.keySet();
           Iterator keyIterator = keySet.iterator();
           
           while (keyIterator.hasNext() ) {
               Integer curKey = (Integer) keyIterator.next();
                
               String id = peopleMap.get(curKey);
               if(id == this.RFID)
               {
                  Chair chair = (Chair) chairs.get(curKey);
                  this.setPos(chair.vec1);
                  global.update = true;
                  break;
               } 
          }
     }
  }
}


