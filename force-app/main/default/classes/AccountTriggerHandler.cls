public class AccountTriggerHandler {
    
    public static void handleBeforeInsert(List<Account> newAccounts) {
        setDefaultReviewDate(newAccounts);
    }
    
    public static void handleBeforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        updateReviewDateOnPriorityChange(newAccounts, oldAccountsMap);
    }
    
    // Set review date to today for only new accounts
    private static void setDefaultReviewDate(List<Account> accounts) {
        for (Account acc : accounts) {
            if (acc.Last_Review_Date__c == null) {
                acc.Last_Review_Date__c = Date.today();
            }
        }
    }
    
    // Update review date when priority changes
    private static void updateReviewDateOnPriorityChange(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        for (Account acc : newAccounts) {
            Account oldAccount = oldAccountsMap.get(acc.Id);
            if (acc.Customer_Priority__c != oldAccount.Customer_Priority__c) {
                acc.Last_Review_Date__c = Date.today();
            }
        }
    }
}