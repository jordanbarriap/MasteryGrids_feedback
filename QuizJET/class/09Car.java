
public class Car implements Mechanism {
	
	public static final int RIGHT_NUM_OF_WHEELS = 4; 
	public static final String PROBLEMATIC_BRAND = "Daewoo";
	public static final String GOOD_BRAND = "BMW";
	
	private String brand;
	private int numOfWheels;	

	public Car(String brand, int numOfWheels) {
		this.brand = brand;
		this.numOfWheels = numOfWheels;
	}
	
	public String getBrand() {
		return brand;
	}
	
	public int getNumOfWheels() {
		return numOfWheels;
	}

	public void getFixed() {
	
		if (numOfWheels != RIGHT_NUM_OF_WHEELS)
			numOfWheels = RIGHT_NUM_OF_WHEELS;
		
		if (brand.equalsIgnoreCase(PROBLEMATIC_BRAND))
			brand = GOOD_BRAND;		
	}

	public int reportProblems() {		
		int num = 0;
		
		if (numOfWheels < RIGHT_NUM_OF_WHEELS)
			num += (RIGHT_NUM_OF_WHEELS - numOfWheels);
		
		if (numOfWheels > RIGHT_NUM_OF_WHEELS)
			num += (numOfWheels - RIGHT_NUM_OF_WHEELS);
		
		if (brand.equalsIgnoreCase(PROBLEMATIC_BRAND))
			num += 1;
		
		return num;
	}

}
