public class Rectangle {
  private double x;
  private double y;
  private double height;
  private double width;
  
  public Rectangle (double x, double y, double height, double width){
    this.x = x;
    this.y = y;
    this.height = height;
    this.width = width;
  }
  
  public double getWidth(){
    return width;
  }

  public double getHeight(){
    return height;
  }
  
  public void magnify (int ratio) {
    height = height * ratio;
    width = width * ratio;
  }
}
