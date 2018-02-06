////////Native Java Libraries///////////
import java.util.Calendar;
import java.io.*; 
import java.awt.*;
import java.lang.String;  
//java collections libraries
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.*;
import java.util.Iterator;
import java.util.Set;
////////Native Processing Libraries//////
import processing.pdf.*;
import processing.core.PApplet;
import processing.opengl.*;
////////External Libraries//////////////
// the NyARToolkit Processing library
import jp.nyatla.nyar4psg.*; 
//kinect video library
import pKinect.PKinect; 
import pKinect.SkeletonData;
//SimpleOpenNI
import SimpleOpenNI.*;
//sql interface library
import de.bezier.data.sql.*; 
//geometry library
import toxi.geom.*;
import toxi.processing.*;
//twitter4j library, twitter interface
import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.json.*;
import twitter4j.internal.util.*;
import twitter4j.management.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;
import twitter4j.internal.json.*;
//udp library, udp communication
import hypermedia.net.*;
//google guava library
import com.google.common.collect.*;
import com.google.common.hash.*;
//jgrapht library
import org.jgrapht.*;
import org.jgrapht.graph.*;
import org.jgrapht.traverse.*;
import org.jgrapht.alg.*;
import org.jgrapht.alg.NeighborIndex;

//save pdf
boolean savePDF = false;
//debug
boolean debug1 = false;


////////global objects///////////
Globals global = new Globals();
ArrayList <Chair> chairs = new ArrayList <Chair>();
ArrayList <Group> groups = new ArrayList <Group>();
ArrayList <Person> people = new ArrayList <Person>();
ArrayList <SubGroup> subgroups = new ArrayList <SubGroup>();
Hashtable<String,Integer> ipMap = new Hashtable<String,Integer>();
Hashtable<String,Integer> rfidMap = new Hashtable<String,Integer>();
Hashtable<Integer,Integer> groupMap = new Hashtable<Integer,Integer>();
Hashtable<Integer,String> peopleMap = new Hashtable<Integer, String>();
/////////////managers////////////
SpatialManager sm;
GraphManager gm;
VideoManager vm;
ColorManager cm;
//////////////SQLite//////////////
SQLite db;
/////////////ARToolKit////////////
MultiMarker nya;
//////////////////UDP/////////////
UDP udp; 
//////////////Kinect/////////////

void setup()
{
  //setup window
  size(1280, 720, OPENGL);
  background(0);
   
  //initialize text
  textFont(createFont("Arial", 80));

  //init sql
  db = new SQLite( this, "C:\\Users\\kathyyue\\Documents\\Processing\\projects\\interact2_0\\Chairs.db" ); 

  initializeARToolKit();
  initializeUDP();
  initializeChairs();
  initializeSM();
  initializeGM();
  cm = new ColorManager();
  initializePeople();
  initializeVM();  
  initializePeopleMap();
  
  while(millis() < 20000)
  {
    //wait 20sec for everything to initialize
  }
  
}

void draw()
{
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  //things to always update
  //grabs image from kinect and processes the image for trackers
  vm.grabVideoFrame();
  //always calculates the position and heading of each chair from marker
  for (Chair chair : chairs) 
  { 
    //check udp status
    chair.checkUDP();
    //check rfid status
    chair.checkPerson();
    //check marker status
    chair.calculatePos();
    
  }  

  //run only when update is true, redraw
  if(global.update == true)
  {
      //clear window
      background(0);
      //draw spatial hash grid, if toggled
      sm.run();
      //update spatial hash map
      runSpatialManager();
      //check for none grouped objects
      checkGrouped();
      deleteDupGroups();
      //update and draw all groups from spatial hash map
      for (Group group : groups) { group.run(); }
      //grab and draw trees
      runGraphManager();
      //delete duplicate branches
      deleteDupSGroups();
      //draw groups from branches
      for (SubGroup sg : subgroups) { sg.run(); }
      //update and draw all chairs
      for (Chair chair : chairs) { chair.run(); }
      //update person location
      for (Person person : people) { person.run(); }
      //turn update off
      global.update = false;
  }
  
  if(global.debug)
  {
        //redraw with video
        background(0);
        //draw spatial hash grid, if toggled
        sm.run();
        //display video capture, if toggled
        vm.display();
        displayFrameRate();
        
        gm.display();
        for (SubGroup sg : subgroups) { sg.display(); }  
        for (Chair chair : chairs) { chair.display(); }
        //for (Group group : groups) { group.display(); }
        for (Person person : people) { person.display(); }
  }

  
  // end of pdf recording
  if (savePDF) {
     savePDF = false;
     endRecord();
  }
}

//udp recieve event handler
void receive( byte[] data, String src_ip, int src_port ) {  // <-- extended handler
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  //use ip to retrieve and update object, via hashmap or db query
  queryChairStatus(src_ip, message);
  // print the result
  if(global.debugUDP == true)
  {
    println("receive: \"" + message + "\" from  "+ src_ip + " on port " + src_port );
  }
}
