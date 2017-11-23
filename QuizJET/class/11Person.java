
public class Person {
	
	private String name;
	private int age;
	
	public Person (String n, int a)
		throws IllegalArgumentException, NullPointerException {
		if (n == null)
			throw new NullPointerException("name is null"); 
		if(n.length() == 0)
			throw new IllegalArgumentException("name is empty");
		if (a < 0)
			throw new IllegalArgumentException("age is negative");
		name = n;
		age = a;
	}

	public int getAge() {
		return age;
	}

	public String getName() {
		return name;
	}

	
	
}
