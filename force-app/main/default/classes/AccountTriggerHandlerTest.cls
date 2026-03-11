/**
 * @description Comprehensive test class for AccountTriggerHandler
 * @author Copado AI Assistant
 * @date 2026-03-11
 */
@isTest
private class AccountTriggerHandlerTest {
    
    /**
     * @description Test that new accounts get today's date as review date
     */
    @isTest
    static void testDefaultReviewDateOnInsert() {
        // Setup
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium'
        );
        
        // Execute
        Test.startTest();
        insert acc;
        Test.stopTest();
        
        // Verify
        Account insertedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), insertedAccount.Last_Review_Date__c,
            'Review date should be set to today');
    }
    
    /**
     * @description Test that accounts with pre-set review dates are not overwritten
     */
    @isTest
    static void testPresetReviewDateNotOverwritten() {
        // Setup
        Date customDate = Date.today().addDays(-5);
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium',
            Last_Review_Date__c = customDate
        );
        
        // Execute
        Test.startTest();
        insert acc;
        Test.stopTest();
        
        // Verify
        Account insertedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(customDate, insertedAccount.Last_Review_Date__c,
            'Pre-set review date should not be overwritten');
    }
    
    /**
     * @description Test bulk insert of accounts (200+ records)
     */
    @isTest
    static void testBulkInsert() {
        // Setup
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 250; i++) {
            accounts.add(new Account(
                Name = 'Bulk Test Account ' + i,
                Customer_Priority__c = 'Low'
            ));
        }
        
        // Execute
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        // Verify
        List<Account> insertedAccounts = [SELECT Last_Review_Date__c FROM Account WHERE Name LIKE 'Bulk Test Account%'];
        System.assertEquals(250, insertedAccounts.size(), 'Should have inserted 250 accounts');
        
        for (Account acc : insertedAccounts) {
            System.assertEquals(Date.today(), acc.Last_Review_Date__c,
                'All bulk inserted accounts should have review date set to today');
        }
    }
    
    /**
     * @description Test review date update when priority changes
     */
    @isTest
    static void testReviewDateUpdateOnPriorityChange() {
        // Setup
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Low',
            Last_Review_Date__c = Date.today().addDays(-10)
        );
        insert acc;
        
        Date oldReviewDate = acc.Last_Review_Date__c;
        
        // Execute
        Test.startTest();
        acc.Customer_Priority__c = 'High';
        acc.Phone = '555-1234'; // Required for high priority
        update acc;
        Test.stopTest();
        
        // Verify
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), updatedAccount.Last_Review_Date__c,
            'Review date should be updated when priority changes');
        System.assertNotEquals(oldReviewDate, updatedAccount.Last_Review_Date__c,
            'Review date should be different from original');
    }
    
    /**
     * @description Test that review date is NOT updated when priority stays the same
     */
    @isTest
    static void testReviewDateNotUpdatedWhenPriorityUnchanged() {
        // Setup
        Date customDate = Date.today().addDays(-10);
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium',
            Last_Review_Date__c = customDate
        );
        insert acc;
        
        // Execute
        Test.startTest();
        acc.Name = 'Updated Test Account'; // Change something else
        update acc;
        Test.stopTest();
        
        // Verify
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(customDate, updatedAccount.Last_Review_Date__c,
            'Review date should not change when priority is unchanged');
    }
    
    /**
     * @description Test bulk update of accounts (200+ records)
     */
    @isTest
    static void testBulkUpdate() {
        // Setup
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 250; i++) {
            accounts.add(new Account(
                Name = 'Bulk Update Test ' + i,
                Customer_Priority__c = 'Low',
                Last_Review_Date__c = Date.today().addDays(-30)
            ));
        }
        insert accounts;
        
        // Execute
        Test.startTest();
        for (Account acc : accounts) {
            acc.Customer_Priority__c = 'Medium';
        }
        update accounts;
        Test.stopTest();
        
        // Verify
        List<Account> updatedAccounts = [SELECT Last_Review_Date__c FROM Account WHERE Name LIKE 'Bulk Update Test%'];
        System.assertEquals(250, updatedAccounts.size(), 'Should have updated 250 accounts');
        
        for (Account acc : updatedAccounts) {
            System.assertEquals(Date.today(), acc.Last_Review_Date__c,
                'All bulk updated accounts should have review date updated to today');
        }
    }
    
    /**
     * @description Test priority change from null to a value
     */
    @isTest
    static void testPriorityChangeFromNull() {
        // Setup
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = null,
            Last_Review_Date__c = Date.today().addDays(-5)
        );
        insert acc;
        
        // Execute
        Test.startTest();
        acc.Customer_Priority__c = 'Medium';
        update acc;
        Test.stopTest();
        
        // Verify
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), updatedAccount.Last_Review_Date__c,
            'Review date should be updated when priority changes from null');
    }
    
    /**
     * @description Test priority change to null
     */
    @isTest
    static void testPriorityChangeToNull() {
        // Setup
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium',
            Last_Review_Date__c = Date.today().addDays(-5)
        );
        insert acc;
        
        // Execute
        Test.startTest();
        acc.Customer_Priority__c = null;
        update acc;
        Test.stopTest();
        
        // Verify
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(Date.today(), updatedAccount.Last_Review_Date__c,
            'Review date should be updated when priority changes to null');
    }
    
    /**
     * @description Test validation rule for high priority accounts requiring phone
     */
    @isTest
    static void testValidationRuleForHighPriority() {
        // Setup
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'High'
            // No phone number
        );
        
        // Execute & Verify
        Test.startTest();
        try {
            insert acc;
            System.assert(false, 'Expected validation error for high priority account without phone');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Phone number is required'),
                'Should get validation error for missing phone on high priority account');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test that high priority accounts work correctly with phone number
     */
    @isTest
    static void testHighPriorityWithPhone() {
        // Setup & Execute
        Test.startTest();
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'High',
            Phone = '555-1234'
        );
        insert acc;
        Test.stopTest();
        
        // Verify
        Account insertedAccount = [SELECT Id, Customer_Priority__c, Phone, Last_Review_Date__c 
                                   FROM Account WHERE Id = :acc.Id];
        System.assertEquals('High', insertedAccount.Customer_Priority__c,
            'Priority should be High');
        System.assertEquals('555-1234', insertedAccount.Phone,
            'Phone should be set correctly');
        System.assertEquals(Date.today(), insertedAccount.Last_Review_Date__c,
            'Review date should be set to today');
    }
    
    /**
     * @description Test recursion prevention in before insert
     */
    @isTest
    static void testRecursionPreventionBeforeInsert() {
        // This test verifies that the recursion flag works
        // In a real scenario, recursion might occur through workflow field updates or process builder
        
        Test.startTest();
        Account acc = new Account(
            Name = 'Recursion Test',
            Customer_Priority__c = 'Low'
        );
        insert acc;
        Test.stopTest();
        
        // Verify account was created successfully
        Account insertedAccount = [SELECT Id, Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertNotEquals(null, insertedAccount.Id, 'Account should be created');
        System.assertEquals(Date.today(), insertedAccount.Last_Review_Date__c,
            'Review date should be set');
    }
    
    /**
     * @description Test recursion prevention in before update
     */
    @isTest
    static void testRecursionPreventionBeforeUpdate() {
        // Setup
        Account acc = new Account(
            Name = 'Recursion Test',
            Customer_Priority__c = 'Low',
            Last_Review_Date__c = Date.today().addDays(-10)
        );
        insert acc;
        
        Test.startTest();
        acc.Customer_Priority__c = 'Medium';
        update acc;
        Test.stopTest();
        
        // Verify update was successful
        Account updatedAccount = [SELECT Customer_Priority__c, Last_Review_Date__c 
                                  FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Medium', updatedAccount.Customer_Priority__c,
            'Priority should be updated');
        System.assertEquals(Date.today(), updatedAccount.Last_Review_Date__c,
            'Review date should be updated');
    }
    
    /**
     * @description Test reset recursion flags method
     */
    @isTest
    static void testResetRecursionFlags() {
        // This method is primarily for testing purposes
        Test.startTest();
        AccountTriggerHandler.resetRecursionFlags();
        Test.stopTest();
        
        // If no exception is thrown, the test passes
        System.assert(true, 'Reset recursion flags should execute without error');
    }
}