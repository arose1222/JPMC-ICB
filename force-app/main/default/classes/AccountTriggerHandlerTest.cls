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
    static void testExistingReviewDateNotOverwritten() {
        // Test that existing review dates are preserved
        Date customDate = Date.today().addDays(-5);
        Test.startTest();
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium',
            Last_Review_Date__c = customDate
        );
        insert acc;
        Test.stopTest();
        
        Account insertedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(customDate, insertedAccount.Last_Review_Date__c,
            'Existing review date should not be overwritten');
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
    static void testReviewDateUnchangedWhenPriorityUnchanged() {
        // Create account
        Date originalDate = Date.today().addDays(-10);
        Account acc = new Account(
            Name = 'Test Account',
            Customer_Priority__c = 'Medium',
            Last_Review_Date__c = originalDate
        );
        insert acc;
        
        // Update without changing priority
        Test.startTest();
        acc.Name = 'Updated Name';
        update acc;
        Test.stopTest();
        
        Account updatedAccount = [SELECT Last_Review_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(originalDate, updatedAccount.Last_Review_Date__c,
            'Review date should not change when priority is unchanged');
    }

    @isTest
    static void testBulkInsert() {
        // Test bulk insert (200 records to test governor limits)
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Bulk Account ' + i,
                Customer_Priority__c = 'Low'
            ));
        }
        
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Last_Review_Date__c FROM Account WHERE Id IN :accounts];
        System.assertEquals(200, insertedAccounts.size(), 'All 200 accounts should be inserted');
        for (Account acc : insertedAccounts) {
            System.assertEquals(Date.today(), acc.Last_Review_Date__c,
                'All bulk inserted accounts should have review date set');
        }
    }

    @isTest
    static void testBulkUpdateWithPriorityChange() {
        // Test bulk update with priority changes
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Bulk Account ' + i,
                Customer_Priority__c = 'Low',
                Last_Review_Date__c = Date.today().addDays(-30)
            ));
        }
        insert accounts;
        
        // Update priorities
        for (Account acc : accounts) {
            acc.Customer_Priority__c = 'Medium';
        }
        
        Test.startTest();
        update accounts;
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Last_Review_Date__c FROM Account WHERE Id IN :accounts];
        for (Account acc : updatedAccounts) {
            System.assertEquals(Date.today(), acc.Last_Review_Date__c,
                'All bulk updated accounts should have review date updated');
        }
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