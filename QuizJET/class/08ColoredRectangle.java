public class ColoredRectangle extends Rectangle
{

  String color;

  public ColoredRectangle(double x, double y, double h, double w, String c)
  {
    super(x, y, h, w);
    color = c;
  }

  public String getColor() {
    return color;
  }


}
