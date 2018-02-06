class Globals {
    //update only when something has changed state
    boolean update = true;
    //turn on debug udp
    boolean debugUDP = false;
    //turn on video tracking
    boolean kinectTr = true;
    //udp = true, turn on udp communication
    boolean udpCom = true;
    //turn on debug mode, debug = true
    boolean debug = false;
    
    //////ARTracking//////////
    float displayScale;
    // the dimensions at which the AR will take place. with the current library 1280x720 is about the highest possible resolution.
    // it will work just as well at a lower resolution such 640x360, in some case a lower resolution even seems to work better.
    int arWidth = 1280;
    int arHeight = 720;
    Globals()
    {
    }
}

