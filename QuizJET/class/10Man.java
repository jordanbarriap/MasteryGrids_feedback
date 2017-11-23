
public class Man extends Animal{

	private double weight;	
	public static final int NUM_OF_LEGS = 2;
	public static final int VENERABLE_AGE = 50;
	
	public Man(int age, int legs, double weight) {
		super(age, legs);
		this.weight = weight;
	}
	
	public double getWeight() {
		return weight;
	}
	
	public double computeSpeed() {
		return super.computeSpeed() * 10 / weight;
	}	
	
	public String speak () {
		if (getAge() < VENERABLE_AGE)
			return "How are you doing?";
		else 
			return "How are you doing, honey?";
	}
	
	public String toString() {
		return super.toString() + "[weight=" + weight + "]"; 
	}
	
	public boolean equals(Object anObject) {		
		Man man = (Man) anObject;
		return super.equals(anObject) && this.weight == man.weight;
	}
	
}
