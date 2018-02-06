class VideoManager
{
    PKinect kinect;
    SimpleOpenNI context;
    String cam;
    PImage input, inputSmall, inputCopy;
    int arWidth, arHeight;
    boolean display;
    
    VideoManager(int w, int h, PApplet t, String x)
    {
        if(x.equals("kinect"))
        {
          kinect = new PKinect(t);
          cam = x;
        }
        else
        {
          context = new SimpleOpenNI(t);
          if(context.isInit() == false)
          {
             println("can't init SimpleOpenNI, camera is not connect");
             exit();
             return;
          }
          cam = "other";
          // disable mirror
          context.setMirror(false);
          context.enableRGB();
        }
        this.arWidth = w;
        this.arHeight = h;
    }
    
    void grabVideoFrame()
    {
       if(global.kinectTr)
       {
          if(cam.equals("kinect"))
          {
            this.input = kinect.GetImage();
          }
          else
          {
            context.update();
            PImage rgbImage = context.rgbImage();
            this.input = rgbImage;
          }
          this.input.resize(this.arWidth, this.arHeight);
          // to correct for the scale difference between the AR detection coordinates and the size at which the result is displayed
          //this.inputSmall = kinect.GetImage();
          //this.inputSmall.resize(this.arWidth, this.arHeight);
          nya.detect(this.input);
       } 
    }
    
   void switchDebug()
   {
     if(this.display)
     {
       println("EXIT VIDEO DEBUG");
       display = false;
     }
     else
     {
       println("ENTER VIDEO DEBUG");
       display = true;
     }
   }
   
  void display()
  {
    if(this.display)
    {
       tint(255, 100);
       image(this.input,0,0);
    }
  }  
}
