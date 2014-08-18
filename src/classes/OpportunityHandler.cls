/**
 * @description Trigger Handler for the Opportunity SObject. This class implements the ITrigger
 *              interface to help ensure the trigger code is bulkified and all in one place.
 * Currently only After Delete is used for the Opportunity object
 * Associated Unit Test Classes:
 *      - TestOpportunityTriger
 *      - TestOutboundEmailOnDelete
 */
public without sharing class OpportunityHandler implements ITrigger {
    // Constructor
    public OpportunityHandler() {
    }
    
    /******************* BEGIN BEFORE TRIGGER EVENT METHODS *************/
    
    /**@description This method is called for a full list of all of the BEFORE DELETE triggers.
     *              Iterate through the list here or farm the full list of triggers to another class.
     * @param List of old sObjects (Trigger.old)
     * @param Map of old sObjects (Trigger.oldMap)
     */
    public void bulkbeforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        
    }
    
    /**@description This method is called for a full list of all of the BEFORE INSERT triggers.
     *              Iterate through the list here or farm the full list of triggers to another class.
     * @param List of new sObjects (Trigger.new)
     */
    public void bulkBeforeInsert(List<SObject> newList) {

    }
    /**@description This method is called for a full list of all of the BEFORE UPDATE triggers.
     *              Iterate through the list here or farm the full list of triggers to another class.
     * @param Map of new sObjects (Trigger.newMap)
     * @param List of new sObjects (Trigger.new)
     * @param Map of old sObjects (Trigger.oldMap) (if needed, oldList can be recreated with oldMap.values())
     */
    public void bulkBeforeUpdate(Map<Id, SObject> newMap, List<SObject> newList, Map<Id, SObject> oldMap) {
        
    }
    /******************* END BEFORE TRIGGER EVENT METHODS *************/
    
    
    /******************* BEGIN AFTER TRIGGER EVENT METHODS *************/
    
    /**
     * @description This method is called once for the full list of records during an AFTER DELETE
     *              trigger.
     * @param List of old sObjects (Trigger.old)
     * @param Map of old sObjects (Trigger.oldMap)
     */
    public void bulkAfterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        
    }
    
    /**
     * @description This method is called once for the full list of records inserted during an AFTER INSERT
     *              trigger. Always put field validation in the 'After' methods in case another trigger
     *              has modified any values. The record is 'read only' by this point.
   * Used to update the Current Application field on Accounts when OARS adds a new Application.
   * This replaces the standalone trigger that is used in all previous OARS builds
   * 
   * @param Unit Test in TestUpdateCurrentApp.cls
   *
     * @param List of new sObjects (Trigger.new)
     */
    public void bulkAfterInsert(List<SObject> newList) {
        List<Opportunity> newOppList = (List<Opportunity>) newList;
        ApplicationToStudentMappingUtility.mapApplicationFieldToStudent((List<Opportunity>) newList);

        Global_Feature_Toggles__c scorToggle = Global_Feature_Toggles__c.getValues('OppScoring');
        if(scorToggle.Active__c) OppScoringUtility.OppScoringUtility(newOppList);             
    }
    
    /**
     * @description This method is called once for the full list of records during an AFTER UPDATE
     *              trigger. Always put field validation in the 'After' methods in case another trigger
     *              has modified any values. The record is 'read only' by this point.
     * @param Map of new sObjects (Trigger.newMap)
     * @param List of new sObjects (Trigger.new)
     * @param Map of old sObjects (Trigger.oldMap) (if needed, oldList can be recreated with oldMap.values())
     */
    public void bulkAfterUpdate(Map<Id, SObject> newMap, List<SObject> newList, Map<Id, SObject> oldMap) {
		List<Opportunity> newOppList = (List<Opportunity>) newList;
        Map<Id, Opportunity> oldOppMap = (Map<Id, Opportunity>) oldMap;
        
        ApplicationToStudentMappingUtility.mapApplicationFieldToStudent(newOppList, oldOppMap);

        Global_Feature_Toggles__c scorToggle = Global_Feature_Toggles__c.getValues('OppScoring');
        if(scorToggle.Active__c) OppScoringUtility.OppScoringUtility(newOppList);
    }

    /**
     * @description This method is called once for the full list of records during an AFTER UNDELETE
     *              trigger.
     * @param List of old sObjects (Trigger.new)
     */
    public void bulkAfterUndelete(List<SObject> newList) {
        
    }
    
    /******************* END AFTER TRIGGER EVENT METHODS *************/
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     * e.g. Accomplish tasks for lists created in after update and after insert methods without
     *      having to copy/paste the code.
     */
    public void andFinally() {

    }

}