public class Point {
   private int x = 0;
   private int y = 0;
  	    

   public Point()
   {   
      x = 0;
      y = 0;
   }

  	//constructor
   public Point(int a, int b) {
  	    x = a;
  	    y = b;
   }
  	
   public void setX(int a)
   {   
      x = a;
   }
  
     public int getX()
   {   
      return x;
   }
  
     public int getY()
   {   
      return y;
   }  	
}