class SubGroup
{
    ArrayList<Chair> grouped= new ArrayList<Chair>();
    int numObjInGroup; 
    int groupID;
    Color col;
    Vec2D m;
    
    SubGroup( List<Chair> t, int id, Color c)
    {
      this.groupID = id;
      this.grouped.addAll(t);
      this.numObjInGroup = grouped.size();
      m = new Vec2D();
      this.col = c;
    }
    
    void calculatePos()
    {
      //calculate midpoint between all objects
       int tX = 0;
       int tY = 0;
       for(Chair Chair : grouped)
       {
         tX += Chair.vec1.x;
         tY += Chair.vec1.y;
       }
       m = new Vec2D( tX/numObjInGroup, tY/numObjInGroup);
    }
    
    void display()
    { 
       noStroke();
       ellipseMode(CENTER);
       fill(255);
       ellipse(m.x, m.y, 5, 5);
       fill(col.r, col.g, col.b, 55);
       ellipse(m.x, m.y, (this.numObjInGroup * 200) + 100, (this.numObjInGroup * 200) + 100);
       //label group
       textSize(14);
       String label = "group: " + groupID ;
       fill(255);
       noStroke();
       rectMode(CORNER);
       fill(255);
       text(label, m.x+5, m.y+15);       
   }
   
  void displayChairs()
  {
    //use udp to send color msg to arduino
    //use the list of chairs to get each ip address, pass group color.
    for(Chair chair : grouped)
    {
      String msg = this.col.r + ";" +  this.col.g + ";" + this.col.b + ";h;@" ;
      if(global.debugUDP == true)
      {
        println( "send: \"" + msg + "\" to "+ chair.ip + " on port " + 4000 );
      }
      if(global.udpCom == true)
      {
        chair.sendUDP( msg );
      }
    }
  }
   
   void run()
   {
      this.calculatePos();
      this.display();
      this.displayChairs();
   }  
   
}
