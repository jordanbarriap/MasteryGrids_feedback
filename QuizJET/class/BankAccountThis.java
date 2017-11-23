/**
A bank account has a balance that can be changed by 
deposits and withdrawals.
*/
public class BankAccountThis
{  
/**
   Constructs a bank account with a zero balance.
*/
public BankAccountThis()
{   
   this.balance = 0;
}

/**
   Constructs a bank account with a given balance.
   @param initialBalance the initial balance
*/
public BankAccountThis(double initialBalance)
{   
   this.balance = initialBalance;
}

/**
   Deposits money into the bank account.
   @param amount the amount to deposit
*/
public void deposit(double amount)
{  
   double newBalance = this.balance + amount;
   this.balance = newBalance;
}

/**
   Withdraws money from the bank account.
   @param amount the amount to withdraw
*/
public void withdraw(double amount)
{   
   double newBalance = this.balance - amount;
   this.balance = newBalance;
}

public void monthlyFee()
{   
   withdraw(10); 
}

/**
   Gets the current balance of the bank account.
   @return the current balance
*/
public double getBalance()
{   
   return this.balance;
}

private double balance;
}
