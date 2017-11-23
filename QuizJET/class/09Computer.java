
public class Computer implements Mechanism {

	public static final double MIN_REQUIRED_SPEED = 2.0;
	public static final double MIN_REQUIRED_CAPASITY = 1.0;	
	
	private double processorSpeed;
	private double memoryCpacity;
	private boolean networked;		
	
	public Computer(double processorSpeed, double memoryCpacity, boolean netwroked) {
		this.processorSpeed = processorSpeed;
		this.memoryCpacity = memoryCpacity;
		this.networked = netwroked;
	}
		
	public double getProcessorSpeed() {
		return processorSpeed;
	}
	
	public void changeProcessor(double newProcessorSpeed){
		processorSpeed = newProcessorSpeed;
	}
	
	public double getMemoryCpacity() {
		return memoryCpacity;
	}

	public void addMemory(double newMemory) {
		memoryCpacity += newMemory;
	}

	public boolean isNetwroked() {
		return networked;
	}

	public void connect() {
		networked = true;
	}
	
	public void disconnect() {
		networked = false;
	}
	
	public void getFixed() {
		
		if (processorSpeed < MIN_REQUIRED_SPEED)
			changeProcessor(MIN_REQUIRED_SPEED);
		
		if (memoryCpacity < MIN_REQUIRED_CAPASITY)
			addMemory(MIN_REQUIRED_CAPASITY-memoryCpacity);
		
		connect();
		
	}

	public int reportProblems() {
		int num = 0;
		if (processorSpeed < MIN_REQUIRED_SPEED)
			num += 1;
		if (memoryCpacity < MIN_REQUIRED_CAPASITY)
			num += 1;
		if (!networked)
			num += 1;		
		return num;
	}

}
