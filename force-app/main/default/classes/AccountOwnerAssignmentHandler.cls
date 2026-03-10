/**
 * Class: AccountOwnerAssignmentHandler
 * Description: Handler class for Account owner assignment logic
 * Best Practice: Separates business logic from trigger
 * 
 * IMPORTANT: Before using this in production, you need to:
 * 1. Update the email addresses in getRegionOwnerMapping() to match your org's actual users
 * 2. Or better yet, replace the hardcoded mapping with Custom Metadata Types or Custom Settings
 */
public class AccountOwnerAssignmentHandler {
    
    /**
     * Assigns account owners based on Region field
     * @param accounts List of Account records to process
     */
    public static void assignOwnerByRegion(List<Account> accounts) {
        
        // Get region owner mapping
        Map<String, Id> regionOwnerMap = getRegionOwnerMapping();
        
        // If no mapping found, exit early
        if (regionOwnerMap.isEmpty()) {
            System.debug('No region owner mapping found. Skipping owner assignment.');
            return;
        }
        
        // Process accounts
        for (Account acc : accounts) {
            // Only assign if Region is populated and mapping exists
            if (String.isNotBlank(acc.Region__c) && regionOwnerMap.containsKey(acc.Region__c)) {
                acc.OwnerId = regionOwnerMap.get(acc.Region__c);
            }
        }
    }
    
    /**
     * Retrieves region to owner mapping
     * @return Map of region code to User Id
     * 
     * NOTE: This is a simplified implementation for demonstration.
     * In production, consider using Custom Metadata Types or Custom Settings
     * for more flexible configuration.
     */
    @TestVisible
    private static Map<String, Id> getRegionOwnerMapping() {
        Map<String, Id> regionOwnerMap = new Map<String, Id>();
        
        // Query users by email - UPDATE THESE EMAILS TO MATCH YOUR ORG
        List<User> users = [
            SELECT Id, Email 
            FROM User 
            WHERE Email IN (
                'na.owner@test.com',
                'latam.owner@test.com',
                'emea.owner@test.com',
                'apac.owner@test.com'
            )
            AND IsActive = true
        ];
        
        // Build mapping
        for (User u : users) {
            if (u.Email == 'na.owner@test.com') {
                regionOwnerMap.put('NA', u.Id);
            } else if (u.Email == 'latam.owner@test.com') {
                regionOwnerMap.put('LATAM', u.Id);
            } else if (u.Email == 'emea.owner@test.com') {
                regionOwnerMap.put('EMEA', u.Id);
            } else if (u.Email == 'apac.owner@test.com') {
                regionOwnerMap.put('APAC', u.Id);
            }
        }
        
        return regionOwnerMap;
    }
}