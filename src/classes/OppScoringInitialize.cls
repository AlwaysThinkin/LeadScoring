/*
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
global class OppScoringInitialize implements Database.Batchable<sObject>{
//OppFork this query is no longer viable. Replace when rebuilding initialize functionality
   global String oppQuery ='Select Id FROM Opportunity WHERE ConvertedContactID = NULL' ;
//   global String cmQuery ='Select Id FROM CampaignMember WHERE ContactID = NULL' ;

   global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(oppQuery);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> opps=new Set<Id>();

        system.debug('Going into the for loop');

        for(sObject s : scope){
            Opportunity o=(Opportunity)s;
            opps.add(o.Id);//add all the relevent Opportunity Id's.
        }//for
    
        try{
            OppScoring.evaluateOpps2(opps);    
            system.debug(opps.size()+' Opportunitys have been scored!');
        } catch (Exception e) {
            system.debug('The following error occurred when trying to set Opportunity Score to zero: '+e);
        }//try
   }

   global void finish(Database.BatchableContext BC){
       //Send an email once done with success message
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
       List<OppScoringRule__c> osrs=[Select Id FROM OppScoringRule__c WHERE Active__c=True AND Type__c='Opportunity'];
       String emailMessage='';
       // Send an email to the Apex job's submitter notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Opportunity Score initialization for all Opportunitys ' + a.Status);
       if (a.NumberOfErrors>0){
           emailMessage=a.TotalJobItems + ' groups of 200 Opportunitys have been scored.  '+ a.NumberOfErrors + ' groups of 200 Opportunitys had 1+ errors.  Errors likely result from rules with incorrect field names or impossible values.  Please confirm the criteria used in your active Opportunity rules.  '+osrs.size()+' active Opportunity rules were used as criteria for scoring.';           
       }else{
           emailMessage=a.TotalJobItems + ' groups of 200 Opportunitys have been scored.  There were no errors.  '+osrs.size()+' active Opportunity rules were used as criteria for scoring.';           
       } 
       mail.setPlainTextBody(emailMessage);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   
   }

}