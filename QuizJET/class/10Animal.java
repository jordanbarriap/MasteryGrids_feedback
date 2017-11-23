
public class Animal {
	
	public static final int MINIMUM_SPEED = 10;
	
	private int age; 
	private int numOfLegs;
	
	public Animal(int age, int legs) {
		this.age = age; 
		numOfLegs = legs;
	}	
	
	public int getAge() {
		return age;
	}
	
	public int getNumOfLegs() {
		return numOfLegs;
	}
	
	public double computeSpeed() {
		return MINIMUM_SPEED * numOfLegs;
	}
	
	public String speak(){
		return "gibberish";
	}
	
	public String toString() {
		return getClass().getName() + "[age=" + age + "][legs=" + numOfLegs + "]";
	}
	
	public boolean equals(Object anObject) {
		Animal animal = (Animal) anObject;
		return this.age == animal.age && this.numOfLegs == animal.numOfLegs;
	}
	
}
