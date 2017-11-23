
public class Dog extends Animal {

	public static final int NUM_OF_LEGS = 4;
	
	public static final int VENERABLE_AGE = 10;
	
	public Dog(int age, int legs) {
		super(age, legs);
	}
	
	public double computeSpeed() {
		if (getAge() < VENERABLE_AGE)
			return super.computeSpeed();
		else 
			return super.computeSpeed() / 2.0;
	}	
	
	public String speak () {
		return "bow-wow";
	}

}
