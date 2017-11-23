
public class SimpleMath {
	
   private int x;
   private int y;
	
   public static final int MAX_POW = 3;
	
   public SimpleMath(int a, int b) {
      x = a;
      y = b;
   }
	
   public String verifyArguments() {
      try {
         if (x < 0)
            throw new NegativeArgumentException("First argument is negative: " + x);
         if (y < 0)
            throw new NegativeArgumentException("Second argument is negative: " + y);
         return "Arguments are OK";
      } catch (NegativeArgumentException e) {
         return e.getMessage();
      }
   }
	
   public String reportAdd() {
      return ""+ (x + y);
   }
	
   public String reportSubtract () {
      try {
         if (x < y)
            throw new Exception("Second Argument " + y + "is gerater then first " + x);
         return "" + (x - y);
      } catch (Exception e) {
         return e.getMessage();
      }
   }
	
   public String reportMultiply() {
      return "" + (x * y);
   }
	
   public String reportDivide() {
      try {
         if (x < y)
            throw new Exception("Second Argument " + y + "is gerater then first " + x);
            return "" + (x / y);
      } catch (Exception e) {
         return e.getMessage();
      }
   }
	
   public String reportPower() {
      String report = ""; 
      try {
         if (y > MAX_POW)
            throw new Exception("Too big power " + y);
         if (x == 0)
            throw new IllegalArgumentException("Not interested in " + x);
         if (y == 0)
            throw new IllegalArgumentException("Not interested in " + y);
         report += Math.pow(x, y);
      } catch (IllegalArgumentException e){
         report += e.getMessage();
      } catch (Exception e) {
         report += e.getMessage();
      }
      return report;
   }	

}
