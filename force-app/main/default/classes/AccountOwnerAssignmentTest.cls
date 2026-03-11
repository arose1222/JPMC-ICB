/**
 * Test Class: AccountOwnerAssignmentTest
 * Description: Tests for Account owner assignment functionality
 */
@isTest
private class AccountOwnerAssignmentTest {
    
    // Create test users for each region
    @TestSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        
        List<User> testUsers = new List<User>();
        
        // Create NA owner
        testUsers.add(new User(
            Alias = 'naown',
            Email = 'na.owner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'NA Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'na.owner@yourcompany.com.' + System.currentTimeMillis()
        ));
        
        // Create LATAM owner
        testUsers.add(new User(
            Alias = 'latamow',
            Email = 'latam.owner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'LATAM Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'latam.owner@yourcompany.com.' + System.currentTimeMillis()
        ));
        
        // Create EMEA owner
        testUsers.add(new User(
            Alias = 'emeaown',
            Email = 'emea.owner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'EMEA Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'emea.owner@yourcompany.com.' + System.currentTimeMillis()
        ));
        
        // Create APAC owner
        testUsers.add(new User(
            Alias = 'apacown',
            Email = 'apac.owner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'APAC Owner',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'apac.owner@yourcompany.com.' + System.currentTimeMillis()
        ));
        
        insert testUsers;
    }
    
    @isTest
    static void testOwnerAssignmentOnInsert_NA() {
        User naOwner = [SELECT Id FROM User WHERE Email = 'na.owner@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create account with NA region
        Account acc = new Account(
            Name = 'Test Account NA',
            Region__c = 'NA'
        );
        
        insert acc;
        
        Test.stopTest();
        
        // Verify owner was assigned
        Account insertedAccount = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals('NA', insertedAccount.Region__c, 'Region should be NA');
        System.assertEquals(naOwner.Id, insertedAccount.OwnerId, 'Owner should be NA owner');
    }
    
    @isTest
    static void testOwnerAssignmentOnInsert_LATAM() {
        User latamOwner = [SELECT Id FROM User WHERE Email = 'latam.owner@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create account with LATAM region
        Account acc = new Account(
            Name = 'Test Account LATAM',
            Region__c = 'LATAM'
        );
        
        insert acc;
        
        Test.stopTest();
        
        // Verify owner was assigned
        Account insertedAccount = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals('LATAM', insertedAccount.Region__c, 'Region should be LATAM');
        System.assertEquals(latamOwner.Id, insertedAccount.OwnerId, 'Owner should be LATAM owner');
    }
    
    @isTest
    static void testOwnerAssignmentOnInsert_EMEA() {
        User emeaOwner = [SELECT Id FROM User WHERE Email = 'emea.owner@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create account with EMEA region
        Account acc = new Account(
            Name = 'Test Account EMEA',
            Region__c = 'EMEA'
        );
        
        insert acc;
        
        Test.stopTest();
        
        // Verify owner was assigned
        Account insertedAccount = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals('EMEA', insertedAccount.Region__c, 'Region should be EMEA');
        System.assertEquals(emeaOwner.Id, insertedAccount.OwnerId, 'Owner should be EMEA owner');
    }
    
    @isTest
    static void testOwnerAssignmentOnInsert_APAC() {
        User apacOwner = [SELECT Id FROM User WHERE Email = 'apac.owner@test.com' LIMIT 1];
        
        Test.startTest();
        
        // Create account with APAC region
        Account acc = new Account(
            Name = 'Test Account APAC',
            Region__c = 'APAC'
        );
        
        insert acc;
        
        Test.stopTest();
        
        // Verify owner was assigned
        Account insertedAccount = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals('APAC', insertedAccount.Region__c, 'Region should be APAC');
        System.assertEquals(apacOwner.Id, insertedAccount.OwnerId, 'Owner should be APAC owner');
    }
    
    @isTest
    static void testOwnerAssignmentOnUpdate() {
        User naOwner = [SELECT Id FROM User WHERE Email = 'na.owner@test.com' LIMIT 1];
        
        // Create account without region
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        Test.startTest();
        
        // Update account with region
        acc.Region__c = 'NA';
        update acc;
        
        Test.stopTest();
        
        // Verify owner was updated
        Account updatedAccount = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals('NA', updatedAccount.Region__c, 'Region should be updated to NA');
        System.assertEquals(naOwner.Id, updatedAccount.OwnerId, 'Owner should be NA owner');
    }
    
    @isTest
    static void testBulkOwnerAssignment() {
        Map<String, Id> ownerMap = new Map<String, Id>();
        ownerMap.put('NA', [SELECT Id FROM User WHERE Email = 'na.owner@test.com' LIMIT 1].Id);
        ownerMap.put('LATAM', [SELECT Id FROM User WHERE Email = 'latam.owner@test.com' LIMIT 1].Id);
        ownerMap.put('EMEA', [SELECT Id FROM User WHERE Email = 'emea.owner@test.com' LIMIT 1].Id);
        ownerMap.put('APAC', [SELECT Id FROM User WHERE Email = 'apac.owner@test.com' LIMIT 1].Id);
        
        Test.startTest();
        
        // Create 200 accounts with different regions
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            String region;
            Integer mod = Math.mod(i, 4);
            if (mod == 0) {
                region = 'NA';
            } else if (mod == 1) {
                region = 'LATAM';
            } else if (mod == 2) {
                region = 'EMEA';
            } else {
                region = 'APAC';
            }
            
            accounts.add(new Account(
                Name = 'Bulk Account ' + i,
                Region__c = region
            ));
        }
        
        insert accounts;
        
        Test.stopTest();
        
        // Verify all accounts were created with correct owners
        List<Account> insertedAccounts = [SELECT Id, Region__c, OwnerId FROM Account WHERE Id IN :accounts];
        System.assertEquals(200, insertedAccounts.size(), 'All 200 accounts should be created');
        
        for (Account a : insertedAccounts) {
            System.assertEquals(ownerMap.get(a.Region__c), a.OwnerId, 'Owner should match region');
        }
    }
    
    @isTest
    static void testNullRegion() {
        Id currentUserId = UserInfo.getUserId();
        
        Test.startTest();
        
        // Create account without region
        Account acc = new Account(
            Name = 'No Region Account'
        );
        
        insert acc;
        
        Test.stopTest();
        
        // Verify account was created
        Account insertedAccount = [SELECT Id, Name, Region__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('No Region Account', insertedAccount.Name, 'Account should be created');
        System.assertEquals(null, insertedAccount.Region__c, 'Region should be null');
    }
    
    @isTest
    static void testGetRegionOwnerMapping() {
        Test.startTest();
        
        // Call the private method to increase coverage
        Map<String, Id> regionMap = AccountOwnerAssignmentHandler.getRegionOwnerMapping();
        
        Test.stopTest();
        
        // Verify the map contains all regions
        System.assertNotEquals(null, regionMap, 'Region map should not be null');
        System.assertEquals(4, regionMap.size(), 'Should have 4 region mappings');
        System.assert(regionMap.containsKey('NA'), 'Should contain NA');
        System.assert(regionMap.containsKey('LATAM'), 'Should contain LATAM');
        System.assert(regionMap.containsKey('EMEA'), 'Should contain EMEA');
        System.assert(regionMap.containsKey('APAC'), 'Should contain APAC');
    }
}