/**
 * Trigger: AccountTrigger
 * Description: Main trigger for Account object
 * Best Practice: Delegates logic to handler class
 */
trigger AccountTrigger on Account (before insert, before update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Assign owner based on Region
            AccountOwnerAssignmentHandler.assignOwnerByRegion(Trigger.new);
        }
    }
}