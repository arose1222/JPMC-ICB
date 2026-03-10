@isTest
private class AccountTriggerHandlerTest {
    
    @isTest
    static void testDefaultReviewDateOnInsert() {
        // Test that new accounts get today's date as review date
        Test.startTest();
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium'
        );
        insert acc;
        Test.stopTest();
        
        Account insertedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), insertedAccount.Last_Review_Date__c, 
            'Review date should be set to today');
    }
    
    @isTest
    static void testReviewDateUpdateOnPriorityChange() {
        // Create account with initial priority
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Low',
            Last_Review_Date__c = Date.today().addDays(-10)
        );
        insert acc;
        
        // Change priority
        Test.startTest();
        acc.Customer_Priority__c = 'High';
        acc.Phone = '555-1234'; // Required for high priority
        update acc;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), updatedAccount.Last_Review_Date__c, 
            'Review date should be updated when priority changes');
    }
    
    @isTest
    static void testValidationRuleForHighPriority() {
        // Test that high priority accounts require phone
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'High'
            // No phone number
        );
        
        Test.startTest();
        try {
            insert acc;
            System.assert(false, 'Expected validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Phone number is required'), 
                'Should get validation error for missing phone');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testHighPriorityWithPhone() {
        // Test that high priority accounts work with phone
        Test.startTest();
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'High',
            Phone = '555-1234'
        );
        insert acc;
        Test.stopTest();
        
        Account insertedAccount = [SELECT Id, Customer_Priority__c, Phone FROM Account WHERE Id = :acc.Id];
        System.assertEquals('High', insertedAccount.Customer_Priority__c);
        System.assertEquals('555-1234', insertedAccount.Phone);
    }
}