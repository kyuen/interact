class ColorManager
{
   ArrayList<Color> c = new ArrayList<Color>();
   
   ColorManager ()
   {
     initColors();
   }
   
   void initColors()
   {
     c.add(new Color(0,130,180));
     c.add(new Color(138,43,226));
     c.add(new Color(127,255,0));
     c.add(new Color(255,165,0));
   }
    
}

class Color
{
  int r,g,b;
  Color(int red, int green, int blue)
  {
    this.r = red;
    this.g = green;
    this.b = blue;
  }
}
