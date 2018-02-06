class GraphManager
{
    DirectedGraph<Chair, DefaultEdge> neighbor_G = new DefaultDirectedGraph<Chair, DefaultEdge>(DefaultEdge.class);
    DirectedGraph<Chair, DefaultEdge> directed_G = new DefaultDirectedGraph<Chair, DefaultEdge>(DefaultEdge.class);
    ListMultimap<Integer,Chair> graphMap;
    ArrayList<Vec2D> intersections = new ArrayList<Vec2D>();
    
    GraphManager()
    {
        graphMap = ArrayListMultimap.create();
    }
    
    void addVertices(ArrayList<Chair> t)
    {  
      //add all objects to graph
      for(Chair chair: t)
      {
         neighbor_G.addVertex(chair);
         directed_G.addVertex(chair);
      }
    }
    
    void addEdges(ArrayList<Chair> gT)
    {
      for(Chair chair: gT)
      {
          chair.comparedTo.clear();
      }
      //add object edges from groups, interate each group for groupedChairs
      for(Chair chair1 : gT)
      {
          for(Chair chair2 : gT)
          {
              //see if objA has been compare to objB || objB compared to objA
              int indx_1 = Collections.binarySearch(chair1.comparedTo, chair2.objID);
              int indx_2 = Collections.binarySearch(chair2.comparedTo, chair1.objID);
              //if object is not the same
              if(!chair1.equals(chair2))
              {
                //has not bee compared yet.
                if(indx_1 < 0 && indx_2 < 0)
                {
              
                   chair1.comparedTo.add(chair2.objID);
                   neighbor_G.addEdge(chair1, chair2);
       
                   Vec2D intersection = new Vec2D(intersection2Lines(chair1.ref, chair2.ref));
                   //drawIntersection(intersection);
                   intersections.add(intersection);
                   
                   if((chair1.octLoc == chair2.octLoc) || (chair1.octLoc == 0 && chair2.octLoc == 8))
                   {
                         //are parallel, add to graph
                         directed_G.addEdge(chair1, chair2);
                   }
                   else if(checkObjectHeading(chair1.vec1, chair1.vec2, chair2.vec1, chair2.vec2,intersection))
                   { 
                         //is convex, add to graph
                         directed_G.addEdge(chair1, chair2);
                   }
                   else if( check_if_sections_are_facing(chair1.octLoc, chair2.octLoc) )
                   {
                         //are facing, add to graph
                         directed_G.addEdge(chair1, chair2);
                   }
                   else
                   {
                      //do noChair
                   }
                }
              }
            }
         }
    }//void
    
    boolean check_if_sections_are_facing(int a, int b) {
        boolean result = false;
        
        if (a == (b-4)) {
          result = true;
        } 
         
        if (b == (a-4)) {
          result = true;
        }
        
        return(result);
   }
    
    void drawIntersection(Vec2D pos)
    {  
        textSize(10);
        stroke(255);
        fill(255);
        ellipse(pos.x,pos.y,5,5);
        pos.set(formatDec(pos.x), formatDec(pos.y));
        text(pos.toString(),pos.x,pos.y-10);
    }
    
    Vec2D intersection2Lines(Line2D l1 , Line2D l2)
    {
        Line2D.LineIntersection isec = l1.intersectLine(l2);
        if (isec.getType() == Line2D.LineIntersection.Type.INTERSECTING) {
          Vec2D pos=isec.getPos();
          return pos;
        }
        else
        {
          return new Vec2D(0,0); 
        }
    }
    
    boolean checkObjectHeading(Vec2D a_1, Vec2D b_1, Vec2D a_2, Vec2D b_2, Vec2D i)
    {
       // check if heading object is similar to intersection of group
       float angleObj_1 = angle2Points(a_1, b_1);
       float angleGroup_1 = angle2Points(a_1, i);
       float angleObj_2 = angle2Points(a_2, b_2);
       float angleGroup_2 = angle2Points(a_2, i);
      // println(angleObj_1 + "," + angleGroup_1 + ";" + angleObj_2 + "," + angleGroup_2);
       if(((angleObj_1 - 1 < angleGroup_1) && (angleGroup_1 < angleObj_1 + 1)) && ((angleObj_2 - 1 < angleGroup_2) && (angleGroup_2 < angleObj_2 + 1)))
       {
           return true;
       }
       else
       {
           return false;
       }
     }
     
     float angle2Points(Vec2D a, Vec2D b)
     {
        //calulates the angle between two point and returns in degrees
        float deltaY = b.y - a.y;
        float deltaX = b.x - a.x;
        float angleInDegrees = atan2(deltaX, deltaY)*180/PI;
        return angleInDegrees;
     }
     
     void debugGraph()
     {       
       
       //Print out the graph to be sure it's really complete
        Iterator<Chair> iter = new DepthFirstIterator<Chair, DefaultEdge>(directed_G);
        Chair vertex;
        while (iter.hasNext()) {
            vertex = iter.next();
            println( "Vertex " + vertex.objID + " is connected to: " + directed_G.edgesOf(vertex).toString());
        }
     } 
      
     void listOriented()
     {
       for(Chair c: chairs)
       {
         graphMap.put(c.objID, c);
         //returns list
         NeighborIndex NI = new NeighborIndex(directed_G);
         List<Chair> list = new ArrayList<Chair>();
         list = NI.neighborListOf(c);
         c.addOriented(list);
         for(Chair t: list)
         {
             graphMap.put(c.objID, t);
         }
       }
     }
     
     void listNeighbors()
     {
       for(Chair c: chairs)
       {
         NeighborIndex NI = new NeighborIndex(neighbor_G);
         List<Chair> list = new ArrayList<Chair>();
         list = NI.neighborListOf(c);
         c.addNeighbor(list);
       }
     }

    void createGroups()
    {
      subgroups.clear();
      //iterate through whole hashmap through key
      for(Chair chair: chairs)
      {    
          //println(graphMap.get(Chair.objID).size());
          if(graphMap.get(chair.objID).size() > 1)
          {
            List x = graphMap.get(chair.objID);
            subgroups.add(new SubGroup(x, chair.objID, cm.c.get(chair.objID)));
          }
      }
    }
  
    void display()
    {
       for(Vec2D i : intersections)
       {
           drawIntersection(i);
           
       }
    }
    
    void run()
    {
       this.addVertices(chairs);
       for(Group group: groups)
       {
          this.addEdges(group.grouped);
       }
       //this.debugGraph();
       this.listNeighbors();
       this.listOriented();
       this.createGroups();
       this.display(); 
    }
     
}

void runGraphManager()
{
    gm = new GraphManager();
    gm.run();
}




