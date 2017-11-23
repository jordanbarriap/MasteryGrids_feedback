public class Rectangle implements Shape{
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
  
  public boolean contains(double x, double y) {
    double x0 = this.x;
    double y0 = this.y;
    return (x >= x0 && y >= y0 && x < x0 + getWidth() && y < y0 + getHeight());
  }

}
