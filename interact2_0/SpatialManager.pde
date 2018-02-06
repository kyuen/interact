//source
//http://conkerjo.wordpress.com/2009/06/13/spatial-hashing-implementation-for-fast-2d-collisions/
//http://zero2programmer.blogspot.com/2012/06/spacial-hashing-take-ii.html
class SpatialManager {
   ListMultimap<Integer,Chair> buckets;
   Hashtable<Integer, Integer> bucketMap = new Hashtable<Integer, Integer>();
   ArrayList<Integer> tmpIds = new ArrayList<Integer>();
   ArrayList<Integer> bucketsObjIsIn = new ArrayList<Integer>();
   List<Chair> objects = new ArrayList<Chair>();
   //List<Chair> objects = new ArrayList<Chair>();
   int cols = 0;
   int rows = 0;
   int sceneWidth = 0;
   int sceneHeight = 0;
   int cellSize = 0;
   boolean display = false;
   SpatialManager sp = null;

  SpatialManager() {
      //initialize buckets
      buckets = ArrayListMultimap.create();
  }

  SpatialManager getInstance() {
    if (sp == null) {
      sp = new SpatialManager();
    }
    return sp;
  }

  void setup(int sceneWidth, int sceneHeight, int cellSize) {
    this.sceneWidth = sceneWidth;
    this.sceneHeight = sceneHeight;
    this.cellSize = cellSize;
    this.cols = sceneWidth / cellSize;
    this.rows = sceneHeight / cellSize;
  }
  
   void switchDebug()
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
  
  void displayGrid(boolean d)
  {
    if(d)
    {
      int count = 0;
      //println("Display");
      //draw grid
      rectMode(CORNER);
      //println("Number of Cells: " + this.cols * this.rows);
      for(int i = 0; i < this.cols; i++)
      {
        for(int j = 0; j < this.rows; j++)
        {
          float x = (i*cellSize) + cellSize/2;
          float y = (j*cellSize) + cellSize/2;
          //println(x + "," + y);
          int cellPosition = int(i + (j * this.cols));
          
          stroke(255);
          strokeWeight(2);
          noFill();
          rect(i*cellSize,j*cellSize,cellSize,cellSize);
          //label grid
          textSize(18);
          String label = "cell: " + cellPosition;
          fill(255); //<>//
          text(label, x-textWidth(label)/2, y-15);  
        }
      }
    }
    else
    {
        background(0);
    }
  }

  void clearBuckets() {
    buckets.clear();
    bucketMap.clear();
    /*for (int i = 0; i < cols * rows; i++) {
      buckets.put(i, null);
    }*/
  }

  void registerObject(Chair t) {
    //place object in buckets 
    tmpIds = getIdForObj(t);
    for (Integer c : tmpIds) {
      buckets.put(c, t);
      
      //create map of items in bucket
      if(bucketMap.containsKey(c))
      {
        //if key is already in use, increment value to count number of items in bucket
        bucketMap.put(c, bucketMap.get(c)+1);
      }
      else
      {
        //create new key for bucket
        bucketMap.put(c, 1);
      }
    } 
  }

  ArrayList<Integer> getIdForObj(Chair t) { 
    //equation to put items in cells
    bucketsObjIsIn.clear();
    //Vector2 min = new Vector2(obj.Position.X - (obj.Radius), obj.Position.Y - (obj.Radius));   
    //Vector2 max = new Vector2(obj.Position.X + (obj.Radius),obj.Position.Y + (obj.Radius));
    PVector min = new PVector(t.vec1.x , t.vec1.y , 0);
    PVector max = new PVector(t.vec1.x + (t.size*2.25) , t.vec1.y + (t.size*2.25) , 0);   
    float width = sceneWidth / cellSize;

    // TopLeft
    addBucket(min, width, bucketsObjIsIn);
    // TopRight
    addBucket(new PVector(max.x, min.y, 0), width, bucketsObjIsIn);
    // BottomRight
    addBucket(new PVector(max.x, max.y, 0), width, bucketsObjIsIn);
    // BottomLeft
    addBucket(new PVector(min.x, max.y, 0), width, bucketsObjIsIn);
    
    //println("buckets in: " + bucketsObjIsIn);
    //println("buckets: " + buckets);
    
    //pass buckets in to Chair.
    t.setBuckets(bucketsObjIsIn);
    //buckets that the object is in
    //println(t.objID + ":   " + bucketsObjIsIn);
    
    return bucketsObjIsIn;
  }

  void addBucket(PVector vector, float width, ArrayList<Integer> bucketToAddTo) {
    //calculate cell position
    int cellPosition = (int) ((Math.floor(vector.x / cellSize)) + (Math.floor(vector.y / cellSize))* width);
    if (!bucketToAddTo.contains(cellPosition)) {
      bucketToAddTo.add(cellPosition);
    }
  }

  ArrayList<Chair> getNearby(Chair t) {
    ArrayList<Chair> objects = new ArrayList<Chair>();
    //ArrayList<Integer> bucketIds = getIdForObj(t);
    for (Integer b : t.bucketsIds) {
     objects = getBuckets(b);
      //println(getBuckets(b));
    }
    return objects;
  }
  
  ArrayList<Chair> getBuckets(Integer key) {
   //convert List to Arraylist using Arraylist.addAll()  
   ArrayList<Chair> listOfObjects = new ArrayList<Chair>();
   listOfObjects.addAll(buckets.get(key));   
   //println(listOfObjects);  
   return listOfObjects;
  }
  
  void run()
  {
    displayGrid(display);
  }
}


