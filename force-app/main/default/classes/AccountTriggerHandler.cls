public class AccountTriggerHandler {
    
    // Recursion control flags
    private static Boolean isBeforeInsertExecuting = false;
    private static Boolean isBeforeUpdateExecuting = false;
    
    /**
     * @description Handles before insert trigger context for Account records
     * @param newAccounts List of new Account records being inserted
     */
    public static void handleBeforeInsert(List<Account> newAccounts) {
        // Prevent recursion
        if (isBeforeInsertExecuting) {
            return;
        }
        
        try {
            isBeforeInsertExecuting = true;
            
            // Null safety check
            if (newAccounts == null || newAccounts.isEmpty()) {
                return;
            }
            
            setDefaultReviewDate(newAccounts);
            
        } catch (Exception e) {
            // Log error and add to first record for visibility
            System.debug(LoggingLevel.ERROR, 'Error in handleBeforeInsert: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            if (!newAccounts.isEmpty()) {
                newAccounts[0].addError('An error occurred while processing Account insert: ' + e.getMessage());
            }
        } finally {
            isBeforeInsertExecuting = false;
        }
    }
    
    /**
     * @description Handles before update trigger context for Account records
     * @param newAccounts List of updated Account records with new values
     * @param oldAccountsMap Map of Account Ids to their old values
     */
    public static void handleBeforeUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        // Prevent recursion
        if (isBeforeUpdateExecuting) {
            return;
        }
        
        try {
            isBeforeUpdateExecuting = true;
            
            // Null safety checks
            if (newAccounts == null || newAccounts.isEmpty()) {
                return;
            }
            
            if (oldAccountsMap == null || oldAccountsMap.isEmpty()) {
                return;
            }
            
            updateReviewDateOnPriorityChange(newAccounts, oldAccountsMap);
            
        } catch (Exception e) {
            // Log error and add to first record for visibility
            System.debug(LoggingLevel.ERROR, 'Error in handleBeforeUpdate: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            if (!newAccounts.isEmpty()) {
                newAccounts[0].addError('An error occurred while processing Account update: ' + e.getMessage());
            }
        } finally {
            isBeforeUpdateExecuting = false;
        }
    }
    
    /**
     * @description Sets the default review date to today for new accounts if not already set
     * @param accounts List of Account records to process
     */
    private static void setDefaultReviewDate(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            return;
        }
        
        Date today = Date.today();
        
        for (Account acc : accounts) {
            if (acc.Last_Review_Date__c == null) {
                acc.Last_Review_Date__c = today;
            }
        }
    }
    
    /**
     * @description Updates the review date when customer priority changes
     * @param newAccounts List of Account records with new values
     * @param oldAccountsMap Map of Account Ids to their old values
     */
    private static void updateReviewDateOnPriorityChange(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
        if (newAccounts == null || newAccounts.isEmpty() || oldAccountsMap == null) {
            return;
        }
        
        Date today = Date.today();
        
        for (Account acc : newAccounts) {
            // Null safety check for old account
            Account oldAccount = oldAccountsMap.get(acc.Id);
            if (oldAccount == null) {
                continue;
            }
            
            // Check if priority has changed (with null safety)
            String newPriority = acc.Customer_Priority__c;
            String oldPriority = oldAccount.Customer_Priority__c;
            
            // Handle null comparisons properly
            Boolean priorityChanged = false;
            if (newPriority != oldPriority) {
                if (newPriority == null || oldPriority == null) {
                    priorityChanged = true;
                } else if (!newPriority.equals(oldPriority)) {
                    priorityChanged = true;
                }
            }
            
            if (priorityChanged) {
                acc.Last_Review_Date__c = today;
            }
        }
    }
    
    /**
     * @description Resets all recursion flags - useful for testing
     * @testVisible
     */
    @TestVisible
    private static void resetRecursionFlags() {
        isBeforeInsertExecuting = false;
        isBeforeUpdateExecuting = false;
    }
}