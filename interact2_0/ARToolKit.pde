void initializeARToolKit()
{
  if(global.kinectTr)
  {
      //////////////AR Tracking Varibles/////////////
      // the full path to the camera_para.dat file
      String camPara = "C:\\Users\\kathyyue\\Documents\\Processing\\libraries\\nyar4psg\\data\\camera_para.dat";
      // the full path to the .patt pattern files
      String patternPath = "C:\\Users\\kathyyue\\Documents\\Processing\\projects\\interact2_0\\markers";
      // the number of pattern markers (from the complete list of .patt files) that will be detected, here the first 10 from the list.
      int numMarkers = 3; 
      //to correct for the scale difference between the AR detection coordinates and the size at which the result is displayed
      global.displayScale = (float) width / global.arWidth;
      //create a new MultiMarker at a specific resolution (arWidth x arHeight), with the default camera calibration and coordinate system
      nya = new MultiMarker(this, global.arWidth, global.arHeight, camPara, NyAR4PsgConfig.CONFIG_DEFAULT);
      //set the delay after which a lost marker is no longer displayed. by default set to something higher, but here manually set to immediate.
      nya.setLostDelay(1);
      //load the pattern filenames (markers)
     String[] patterns = loadPatternFilenames(patternPath);
  
     //load markers from folder
     for (int i=0; i<numMarkers; i++) {
        //add the marker for detection
        nya.addARMarker(patternPath + "/" + patterns[i], 80);
     }
     
  }
}

// this function loads .patt filenames into a list of Strings based on a full path to a directory (relies on java.io)
String[] loadPatternFilenames(String path) {
  File folder = new File(path);
  FilenameFilter pattFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".patt");
    }
  };
  return folder.list(pattFilter);
}
