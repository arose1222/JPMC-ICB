/**
 * Trigger: AccountTrigger
 * Description: Main trigger for Account object
 * Best Practice: Delegates logic to handler class
 */
trigger AccountTrigger on Account (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            // Assign owner based on Region
            AccountOwnerAssignmentHandler.assignOwnerByRegion(Trigger.new);
            // Set default review date
            AccountTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        
        if (Trigger.isUpdate) {
            // Assign owner based on Region
            AccountOwnerAssignmentHandler.assignOwnerByRegion(Trigger.new);
            // Update review date on priority change
            AccountTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}