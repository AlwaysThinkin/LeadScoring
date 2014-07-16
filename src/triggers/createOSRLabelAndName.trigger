trigger createOSRLabelAndName on OppScoringRule__c (before insert, before update) {
    //This simple trigger creates a name for the opp scoring rule automatically so that customers don't have to type it themselves
    //Also, this converts field names to lowercase as Apex Set() considers "email" and "Email" to be 2 different entries
    Map<String, Schema.SObjectField> oppFieldMap=Schema.SObjectType.Opportunity.fields.getMap();
    Map<String, Schema.SObjectField> cmFieldMap=Schema.SObjectType.CampaignMember.fields.getMap();
    
    for (OppScoringRule__c osr:trigger.new){
        if(osr.Field_Name__c!=null){//if 1
            if(osr.Type__c=='Opportunity'){//if 2
                try{
                    osr.Field_Label__c=oppFieldMap.get(osr.Field_Name__c).getDescribe().getLabel();
                }catch (Exception e){
                    system.debug('Field name is likely invalid for Opportunity.  Field Name: '+osr.Field_Name__c+'.  Error: '+e);
                    osr.adderror('Error: Invalid Opportunity field name entered: '+osr.Field_Name__c+'.  Please enter a valid field name.');
                }    
            } else if (osr.Type__c=='Campaign Member'){
                try{
                    osr.Field_Label__c=cmFieldMap.get(osr.Field_Name__c).getDescribe().getLabel();
                }catch (Exception e){
                    system.debug('Field name is likely invalid for campaign member. Field Name: '+osr.Field_Name__c+'.  Error: '+e);
                    osr.adderror('Error: Invalid Campaign Member field name entered: '+osr.Field_Name__c+'.  Please enter a valid field name.');
                }
            }//if 2    
            String ruleName=osr.Type__c+' '+osr.Field_Label__c+' '+osr.Operator__c+' '+osr.Value__c;
            if(ruleName.length()>=80){
                ruleName=ruleName.substring(0,79);
            }
            osr.name=ruleName;
            if(osr.Field_Name__c!=null){//if 1
                osr.Field_Name__c=osr.Field_Name__c.toLowerCase();
            }//if 2
        }//if 1    
    }//for
    

    
}