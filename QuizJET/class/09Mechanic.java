
public class Mechanic {
	
	private int cost;
	
	public static int TEST_PRICE = 10;
	public static int REPAIR_PRICE = 50;
	
	public Mechanic() {
		cost = 0;
	}
	
	public boolean needRepair(Mechanism m) {
		cost = cost + TEST_PRICE;
		if (m.reportProblems() > 0)
			return true;
		else
			return false;			
	}
	
	public void repair(Mechanism m) {
		cost = cost + REPAIR_PRICE * m.reportProblems();
		m.getFixed();
	}
	
	public int howMuch() {
		int charge = cost;
		cost = 0;
		return charge;
	}

}
