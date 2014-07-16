/*
OppScoring adaptation by Luke Cushanick

Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public global class OppScoring {

    private static Boolean oppScoringClassAlreadyCalled=FALSE;

    public global static boolean oppScoringClassAlreadyCalled(){
        return oppScoringClassAlreadyCalled;
    }
/*OppFork CM
    @future //this method is called from the trigger.  It's an asynch method so the trigger call has high governor limits
    public global static void evaluateCMs(Set<Id> oppIds){
        evaluateCMs2(oppIds);
    }//evaluateCMs

    
    this method is called from batch apex.  It cannot be an asynch method as batch apex can't call @future methods
    public global static void evaluateCMs2(Set<Id> CampaignMemberIds){
        Integer i,j;
        Double scoreChange;//safer to define as a double in case anyone tries to change the field's # decimals
        String cmFieldValue;
        String ruleFieldValue;
        Schema.DescribeFieldResult cmFieldDescribe;
        DisplayType cmFieldType;
        Set<Id> oppIDs=new Set<Id>();        
        Map<Id,Double> cmOldScores=new Map<Id,Double>();
        Map<Id,Double> cmNewScores=new Map<Id,Double>();
        Map<Id,Double> oppScores = new Map<Id,Double>();
        Set<String> RuleFieldNames=new Set<String>();
        String qrySOQL;
        List<CampaignMember> cms=new List<CampaignMember>();//Stores a list of the campaign members from this trigger along with all fields needed for evaluating criteria
        Integer CMCount=0;
        //Solves the infinite loop problem w/ Async Apex
        oppScoringClassAlreadyCalled=TRUE;

        //OppFork CM Get all of the Opportunity rules & store them
        OppScoringRule__c[] Rules=activeOppScoringRuleDetails('Campaign Member');
        
        //these maps house the field list as well as field types of the fields of CampaignMember
        Map<String, Schema.SObjectField> cmMap=Schema.SObjectType.CampaignMember.fields.getMap();
        Map<String,DisplayType> cmTypeMap=new Map<String,DisplayType>(); //this will hold the field type for all the fields in the OppScoringRule__c

        //gets the field types for each rule, needed for formula's later
        cmTypeMap=getRuleFieldInfo(cmMap, Rules);
        List<String> fieldNames=new List<String>();
        for (i=0;i<Rules.size();i++){
            if(cmTypeMap.containsKey(Rules[i].Field_Name__c)==True){
                fieldNames.add(Rules[i].Field_Name__c);
            } else {
                Rules.remove(i);//remove the rule if that field name isn't a valid field on Opportunity or Campaign Member
            }
        }
        //OppFork CM
        qrySOQL=getRuleFieldNames(fieldNames);
        qrySOQL='SELECT ' + qrySOQL +'Id,Campaign_Score__c,LeadId,CampaignId,ContactId FROM CampaignMember WHERE Id IN : CampaignMemberIds';

        cms=Database.query(qrySOQL);
        system.debug('Before the cms are processed, the #script statements is at: '+Limits.getScriptStatements());
        system.debug('Max #script statements that can be processed: '+Limits.getLimitScriptStatements());
        j=0;          
        //Now need to create a loop of the rules to get the CMs in each rule, then loop through the CM's and update ScoreChange for that CM            
        For (i=0;i<cms.size();i++){
        //Evaluate criteria here for each Campaign Member

            if (cms[i].Campaign_Score__c==null){
                scoreChange=0;
            } else {    
                scoreChange=-cms[i].Campaign_Score__c; //remove the old value of campaign score to avoid double counting as this value will be replaced
            }//if 1
            


            For(OppScoringRule__c currentRule:Rules){
                //default it in case the campaign isn't found
                if (!(currentRule.Campaign__c!=null&&(currentRule.Campaign__c!=cms[i].CampaignId))){//if 1
                        //if metCriteria==True, then add this score to ScoreChange    
                        if (evaluateCriteria(currentRule.Value__c, 
                                             currentRule.Operator__c,
                                             String.valueOf(cms.get(i).get(currentRule.Field_Name__c)), 
                                             cmTypeMap.get(currentRule.Field_Name__c))==TRUE){//if 2
                            scoreChange+=currentRule.Score_change__c;
                        }//if 2 
                    }//if 1
                }//for 2

            //if that Opportunity already has a score, increment it instead of overwriting it
            if (oppScores.containsKey(cms[i].LeadId)){    
                scoreChange+=oppScores.get(cms[i].LeadId);
                Double removedScore=oppScores.remove(cms[i].LeadId);//remove it so we can readd it with the incremented value
            }//if 1    
            oppScores.put(cms[i].LeadId,scoreChange);                    
            
            cmNewScores.put(cms[i].Id,scoreChange);  //this stores the campaign score for this campaign member, for tracking if the CM is updated or deleted
            oppIDs.add(cms[i].LeadId);
            system.debug('CM Count Successfully Processed: '+cmCount++ + ' with Script statement count at: '+limits.getScriptStatements());
        }//for 1   

        //Now update the Opportunities & campaign members with the new scores!  Note this fires all platform features for Opportunities (workflow, triggers, validation rules)
        updateCMs (cms,cmNewScores);
        updateOpps (oppIDs,oppScores, 'CampaignMember');
    }//evaluateCMs2
    */
    
    public static String getRuleFieldNames(List<String> fieldNames){
        String ruleFieldNameString='';
        Set<String> ruleFieldNames=new Set<String>();
        
        //Loop through the rules & get the field names possibly needed for criteria verification
        for (String fieldName:fieldNames){
            if (ruleFieldNames.contains(fieldName.toLowerCase())==False){//note that a set.Contains() doesn't match "Email" and "email"
                ruleFieldNames.add(fieldName.toLowerCase());
                ruleFieldNameString+=fieldName+',';
            }//if
        }//for
        return ruleFieldNameString;
    }//getRuleFieldNames;


    public static void updateOpps (Set<ID> oppIDs,Map<Id,Double> oppScores, String OppOrMemberScores){
        Opportunity[] opps=[SELECT Id, Opp_Score__c FROM Opportunity WHERE Id IN :oppIDs];
        //Loop through the Opportunities & add the campaign score to each opp
        For (Opportunity eachOpp : opps){
            //handle null values by replacing them with zero
            if (OppOrMemberScores=='Opportunity'){//if 1
                if (eachOpp.Opp_Score__c==null){//if 2
                    eachOpp.Opp_Score__c=0;
                }//if 2    
                eachOpp.Opp_Score__c+=oppScores.get(eachOpp.ID);

            } 
            /* OppFork CM
            else if (OppOrMemberScores=='CampaignMember') {    
                if (eachOpp.Campaign_Score__c==null){//if 2
                    eachOpp.Campaign_Score__c=0;
                }//if 2    
                eachOpp.Campaign_Score__c+=oppScores.get(eachOpp.ID);
            }//if 1
            */
        }//for
        
        //finally, update the Opportunities!  Note this will trigger opp workflow rules, triggers, etc
        Try{
            update opps;
        } catch (DMLException e) {
            system.debug('Opportunitys were not all updated properly: ' + e);
        }//try
    }//updateOpps
/* OppFork CM    
     public static void updateCMs (CampaignMember[] cms,Map<Id,Double> cmNewScores){
        //Loop through the campaign members & assign the campaign score to each member
        For (CampaignMember cm : cms){
            if (cm.Campaign_Score__c==null){//if 2
                    cm.Campaign_Score__c=0;
                }//if 2    
            cm.Campaign_Score__c+=cmNewScores.get(cm.ID);
        }//for
        
        //finally, update the members!  Note this will trigger opp workflow rules, triggers, etc a second time, but will not cause an infinite loop
        Try{
            update cms;
        } catch (DMLException e) {
            system.debug('Campaign Members were not all updated properly: ' + e);
        }//try
    }//updatecms

    @future
    public global static void deletedCMs(Set<Id> campaignMemberIds){
        Set<Id> oppIDs=new Set<Id>();        
        Map<Id,Double> oppScores = new Map<Id,Double>();
        //Solves the infinite loop problem w/ Async Apex
        oppScoringClassAlreadyCalled=TRUE;

        List<CampaignMember> cms=[SELECT Id, LeadId, Campaign_Score__c FROM CampaignMember WHERE Id IN: campaignMemberIds];
        for (CampaignMember eachCM: cms){
            if(eachCM.Campaign_Score__c!=0 &&eachCM.Campaign_Score__c!=null){                
                oppIDs.add(eachCM.LeadId);
                oppScores.put(eachCM.LeadId,-eachCM.Campaign_Score__c);
            }//if
        }//for    
        updateOpps (oppIDs,oppScores, 'CampaignMember');
    }//deleteCMs
*/    
    public static OppScoringRule__c[] activeOppScoringRuleDetails(String ruleType){
        //Once all the active rules criteria are saved, return them as a list to wherever they were called from        
        return [Select Name, Campaign__c, Field_Name__c, Operator__c, Value__c, Score_Change__c FROM OppScoringRule__c WHERE Active__c=TRUE AND Type__c=:ruleType];
    }
      
    @future //this method is called from the trigger.  It's an asynch method so the trigger call has high governor limits
    public global static void evaluateOpps(Set<Id> oppIds){
        evaluateOpps2(oppIds);
    }//evaluateOpps    
    
    //this method is called from batch apex.  It cannot be an asynch method as batch apex can't call @future methods
    public global static void evaluateOpps2(Set<Id> oppIds){
        Integer i,j;
        Double scoreChange;//safer to define as a double in case anyone tries to change the field's # decimals
        Schema.DescribeFieldResult cmFieldDescribe;
        Map<Id,Double> oppOldScores=new Map<Id,Double>();
        Map<Id,Double> oppNewScores=new Map<Id,Double>();
        Map<Id,Double> oppScores = new Map<Id,Double>();
        String qrySOQL='';
        List<Opportunity> opps = new List<Opportunity>();
        Integer OppCount=0;        
        //Solves the asynch apex infinite loop problem
        oppScoringClassAlreadyCalled=TRUE;
        
        OppScoringRule__c[] Rules=activeOppScoringRuleDetails('Opportunity');
        
        //These maps house the field list as well as field types of the fields of Opportunity
        Map<String, Schema.SObjectField> oppMap=Schema.SObjectType.Opportunity.fields.getMap();
        Map<String,DisplayType> oppTypeMap=new Map<String,DisplayType>(); //this will hold the field type for all the fields in the OppScoringRule__c
        
        oppTypeMap=getRuleFieldInfo(oppMap, Rules);//check back here
        List<String> fieldNames=new List<String>();//could change to set to not require "contains key" check; check if sets gack on dupes
        for (i=0;i<Rules.size();i++){
            if(oppTypeMap.containsKey(Rules[i].Field_Name__c)==True){
                fieldNames.add(Rules[i].Field_Name__c);
            } else {
                Rules.remove(i);//remove the rule if that field name isn't a valid field on Opportunity or Campaign Member
            }
        }

        qrySOQL=getRuleFieldNames(fieldNames);
        qrySOQL='SELECT ' + qrySOQL +'Id,Opp_Score__c FROM Opportunity WHERE Id IN : oppIds';
        opps=Database.query(qrySOQL);
        
        system.debug('Before the Opportunities are processed, the #script statements is at: '+Limits.getScriptStatements());
        system.debug('Max #script statements that can be processed: '+Limits.getLimitScriptStatements());
        
        For (i=0;i<opps.size();i++){
        //Evaluate criteria here for each opp
//            if(opps[i].IsConverted==TRUE){
                //first set the score to zero if it was previously null            
                scoreChange = opps[i].Opp_Score__c==null?0:-opps[i].Opp_Score__c;
    
                For(OppScoringRule__c currentRule:Rules){
                    if (evaluateCriteria(currentRule.Value__c, 
                                         currentRule.Operator__c,
                                         String.ValueOf(opps.get(i).get(currentRule.Field_Name__c)),
                                         oppTypeMap.get(currentRule.Field_Name__c))){
                         scoreChange+=currentRule.Score_change__c;
                     }//if 3
                         
                }//for 2
    
                //if that opp already has a score, increment it instead of overwriting it
                if (oppScores.containsKey(opps[i].Id)){    
                    scoreChange+=oppScores.get(opps[i].Id);
                    Double removedScore=oppScores.remove(opps[i].Id);//remove it so we can read it with the incremented value
                }//if 2    
                oppScores.put(opps[i].Id,scoreChange);                    
//            }//if 1                
            system.debug('Opportunity Count Successfully Processed: '+OppCount++ + ' with Script statement count at: '+limits.getScriptStatements());
        }//for 1   
       
        try{
            updateOpps (oppIds,oppScores,'Opportunity');
        } catch (Exception e){
            system.debug('Opportunitys were not updated: '+e);
        }//catch

    }//evaluateOpps
    
    public static Boolean evaluateCriteria(String ruleFieldValue, String operator, String recordFieldValue, DisplayType ruleFieldType){
                  
        Boolean metCriteria=false;
            if (operator=='equals'){//if 1
                if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(ruleFieldValue.equalsIgnoreCase(recordFieldValue));
                } else if (ruleFieldType==Schema.DisplayType.BOOLEAN){//if 2
                        metCriteria=(recordFieldValue.toLowerCase()==ruleFieldValue.toLowerCase());
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)==decimal.valueOf(ruleFieldValue));
                }//if 2                
            }else if (operator=='not equal to'){//if 1
                if (ruleFieldType==Schema.DisplayType.BOOLEAN){//if 2
                        metCriteria=!(ruleFieldValue.equalsIgnoreCase(recordFieldValue));
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)!=decimal.valueOf(ruleFieldValue));
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(recordFieldValue.toLowerCase()!=ruleFieldValue.toLowerCase());
                }//if 2                
           } else if (operator=='greater than'){//if 1
                if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(recordFieldValue.toLowerCase()>ruleFieldValue.toLowerCase());
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)>decimal.valueOf(ruleFieldValue));
                }//if 2  
           } else if (operator=='less than'){//if 1
                if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(recordFieldValue.toLowerCase()<ruleFieldValue.toLowerCase());
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)<decimal.valueOf(ruleFieldValue));
                }//if 2  
           } else if (operator=='greater or equal'){//if 1
                if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(recordFieldValue.toLowerCase()>=ruleFieldValue.toLowerCase());
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)>=decimal.valueOf(ruleFieldValue));
                }//if 2  
           }else if (operator=='less or equal'){//if 1
                if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.STRING || ruleFieldType==Schema.DisplayType.ComboBox ||ruleFieldType==Schema.DisplayType.Picklist ||ruleFieldType==Schema.DisplayType.email||ruleFieldType==Schema.DisplayType.encryptedString||ruleFieldType==Schema.DisplayType.Phone||ruleFieldType==Schema.DisplayType.url)){
                        metCriteria=(recordFieldValue.toLowerCase()<=ruleFieldValue.toLowerCase());
                } else if (recordFieldValue!=null&&(ruleFieldType==Schema.DisplayType.Double||ruleFieldType==Schema.DisplayType.Currency||ruleFieldType==Schema.DisplayType.Percent ||ruleFieldType==Schema.DisplayType.Integer)){
                        metCriteria=(decimal.valueOf(recordFieldValue)<=decimal.valueOf(ruleFieldValue));
                }//if 2  
             }else if (operator=='contains'){//if 1
                    if(recordFieldValue!=null){//if 3;  Checks for null values to avoid null pointer exception for blank opp or cm values
                        metCriteria=recordFieldValue.toLowerCase().contains(ruleFieldValue.toLowerCase());
                    }//if 3    
             }else if (operator=='does not contain'){//if 1
                    if(recordFieldValue!=null){//if 3;  Checks for null values to avoid null pointer exception for blank opp or cm values
                            metCriteria=!recordFieldValue.toLowerCase().contains(ruleFieldValue.toLowerCase());
                    }//if 3    
             }else if (operator=='starts with'){//if 1
            //took out the DisplayType check with the assumption that the controller code only allows string types to use Starts With
                if(recordFieldValue!=null){//if 3;  Checks for null values to avoid null pointer exception for blank opp or cm values
                    metCriteria=recordFieldValue.startsWith(ruleFieldValue);
                }//if 2 
           }//if 1        
        return metCriteria;
    }
    //

    
    //this gets the field type for each OppScoringRule__c.  The type is needed for comparison later    
    public static Map<String,DisplayType> getRuleFieldInfo(Map<String, Schema.SObjectField> objectMap, OppScoringRule__c[] Rules){
        Set<String> RuleFieldNames=new Set<String>();
        Map<String,DisplayType> fieldTypeMap=new Map<String,DisplayType>();
        
        for (OppScoringRule__c rule:Rules){
            if (RuleFieldNames.contains(rule.Field_Name__c)==FALSE){
                RuleFieldNames.add(rule.Field_Name__c);
                try{    //try to get the field type for this field for casting the object later.  
                        //This will fail if the rule.Field_Name__c doesn't match the API name for a field in CampaignMember
                    Schema.SObjectField fieldToken=objectMap.get(rule.Field_Name__c);
                    fieldTypeMap.put(rule.Field_Name__c,fieldToken.getDescribe().getType());
                } catch (Exception e){
                    system.debug('The field name in this customers rule is likely invalid: '+ rule.Field_Name__c);
                    system.debug('Error when trying to get the type of this field: '+ e);
                }//try    
            }//if
        }//for    
        
        return fieldTypeMap;
    }//getRuleFieldInfo
    
    
}//class