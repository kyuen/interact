class Group{
  
  ArrayList<Chair> grouped = new ArrayList<Chair>(); 
  int[] colorMsg = new int[3];
  Vec2D m; //midpoint of all objects
  int numObjInGroup; 
  int groupID;
  
  Group(List<Chair> t, int num, int id)
  {
    this.groupID = id;
    this.numObjInGroup = num;
    this.grouped.addAll(t);
    m = new Vec2D();
  }
  
  void calculatePos()
  {
    //calculate midpoint between all objects to find midpoint of group
     int tX = 0;
     int tY = 0;
     for(Chair chair : grouped)
     {
       tX += chair.vec1.x;
       tY += chair.vec1.y;  
     }
      m = new Vec2D( tX/numObjInGroup, tY/numObjInGroup);
  }
  
  void display()
  { 
       noStroke();
       ellipseMode(CENTER);
       fill(0, 120,  110, 55);
       ellipse(this.m.x, this.m.y, (this.numObjInGroup * 200) + 100, (this.numObjInGroup * 200) + 100);
       fill(255);
       ellipse(this.m.x, this.m.y, 5, 5);
       //label group
       textSize(14);
       String label = "group: " + this.groupID ;
       fill(255);
       noStroke();
       rectMode(CORNER);
       rect(this.m.x, this.m.y, textWidth(label) + 10, textAscent() + textDescent() + 10);
       fill(0);
       text(label, this.m.x+5, this.m.y+5);       
  }
  
  void run()
  { 
    //this.updateGroups();
    this.calculatePos();
    //this.display();
  }
}


