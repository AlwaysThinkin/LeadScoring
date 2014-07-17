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
@isTest 
private class OppScoringTests{
    //used to run the tests quicker by ignoring the batch tests with 90 Opportunities & 80 rules
    static Boolean runBatchTests=true;
    
    static campaign c;//used to store the campaign value for creaing CM's later if needed

    //utility class to create dummy data to test
    public static List<Opportunity> createOpps(Long NumOpps, String OppName, String NxtS, String LeadSrc, Boolean PrivateOpp, Double Amt) {
        List<Opportunity> opps = new List<Opportunity>{};
        Integer i;
        for (i=0;i<numOpps;i++){
            Opportunity l = new Opportunity(Name=OppName+i, NextStep=NxtS, LeadSource=LeadSrc, IsPrivate=PrivateOpp, Amount = Amt);
            opps.add(l);
        }//for
        insert opps;

        return opps;
    }//createOpps
    
    //utility class to create dummy data to test. Overloaded to include Type
    public static List<Opportunity> createOpps(Long NumOpps, String OppName, String NxtS, String type, String LeadSrc) {
        List<Opportunity> opps = new List<Opportunity>{};
        Integer i;
        for (i=0;i<numOpps;i++){
            Opportunity l = new Opportunity(Name=OppName+i, NextStep=NxtS, Type=type, LeadSource=LeadSrc);
            opps.add(l);
        }//for
        insert opps;

        return opps;
    }//createOpps    
    
    public static void createCampaign(String CampaignName){
        Campaign c1= new Campaign(Name=CampaignName);
        insert c1;
        c=c1;//lets the campaign be referenced in the method that calls this method
    }

    public static OppScoringRule__c createOSR(Boolean Active, String OSRType, Double OSRScore, String OSRFN, String OSROperator, String OSRValue) {
        OppScoringRule__c osr;
        if (c==null){
            osr=new OppScoringRule__c(Active__c=Active, Type__c=OSRType, Score_Change__c=OSRScore, Field_Name__c=OSRFN, Operator__c=OSROperator, Value__c=OSRValue);
        } else {
            osr=new OppScoringRule__c(Active__c=Active, Type__c=OSRType, Campaign__c=c.id, Score_Change__c=OSRScore, Field_Name__c=OSRFN, Operator__c=OSROperator, Value__c=OSRValue);    
        }
        return osr;
    }//createOSR

/* OppFork cm May not be necessary to geneate CMs for OppScoring
    public static List<CampaignMember> createCMs(Long numOpps, Id CID,List<Opportunity> opps,String cmStatus) {
       List<CampaignMember> campaignMembers = new List<CampaignMember>{};
       
       for(Integer i = 0; i < numOpps; i++){
            Id OppIdi=opps[i].id;
            CampaignMember cm=new CampaignMember( CampaignId=CID, OppId=OppIdi, Status=cmStatus);
            campaignmembers.add(cm);
       }//for
        
       return campaignMembers;

    }//createCMs
*/
    public static void cleanUpTestData() {
        List<OppScoringRule__c> osrs=[Select ID from OppScoringRule__c LIMIT 500];
        delete osrs;
    }//cleanUpTestData
       
    static testMethod void verifyOppStringEquals(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>{};
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator='eQuals';//testing capitalization as well
        String OSRValue='NextStep';//testing capitalization as well
        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();

        String OppName='TestOpp';
        String NextStep=OSRValue;
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='';
        
        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        
        NextStep='asdf';
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);

        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppStringEquals
    
    
    static testMethod void verifyOppStringNotEqualTo(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator='Not Equal To';
        String OSRValue='TestString';
        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();

        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        NextStep='TestString';
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppStringNotEqualTo

    static testMethod void verifyOppPicklistContains(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='LeadSource';
        String OSROperator='Contains';
        String OSRValue='we';//note testing case sensitivity of the OSR value here
        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        LeadSource='Referral';
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppPicklistContains

    static testMethod void verifyOppPicklistDoesNotContain(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='LeadSource';
        String OSROperator='Does Not Contain';
        String OSRValue='eferr';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        LeadSource='ReFerral';//note testing case sensitivity here as well
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();


        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, LeadSource,Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.debug('Lead Source: '+o.LeadSource +' should not contain '+LeadSource);
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppPicklistDoesNotContain

    static testMethod void verifyOppStringStartsWith(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Name';
        String OSROperator='Starts With';
        String OSRValue='Test';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        OppName='oppTest';
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppStringStartsWith

  static testMethod void verifyOppBooleanEquals(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='IsPrivate';
        String OSROperator='Equals';
        String OSRValue='True';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = True;
        Double Amt = 1000;

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;

          
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);

    }//verifyOppBooleanEquals
    
  static testMethod void verifyOppBooleanNotEqualTo(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='IsPrivate';
        String OSROperator='Not Equal to';
        String OSRValue='True';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = True;
        Double Amt = 1000;

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
          
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertNotEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppBooleanNotEqualTo

  static testMethod void verifyOppDoubleEquals(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Equals';
        String OSRValue='1000';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=2000;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDoubleEquals

  static testMethod void verifyOppDoubleNotEqualTo(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Not Equal To';
        String OSRValue='999';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=999;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDoubleNotEqualTo

  static testMethod void verifyOppDoubleGreaterThan(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Greater Than';
        String OSRValue='999';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=998;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDoubleGreaterThan

     static testMethod void verifyOppDoubleGreaterorEqual(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Greater or Equal';
        String OSRValue='1000';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs; 
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=999;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=1001;
        List<Opportunity> opps3=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();
        
        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(OSRScore,o.Opp_Score__c);

        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(OSRScore,o.Opp_Score__c);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps3[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        
    }//verifyOppDoubleGreaterorEqual

  static testMethod void verifyOppDoubleLessOrEqual(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Less Or Equal';
        String OSRValue='1000';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=1001;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=999;
        List<Opportunity> opps3=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps3[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDoubleLessOrEqual

  static testMethod void verifyOppDoubleLessThan(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='Amount';
        String OSROperator='Less Than';
        String OSRValue='1001';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Amt=1002;
        List<Opportunity> opps2=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore);
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps2[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDoubleLessThan

  static testMethod void verifyOppDateEquals(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='CreatedDate';
        String OSROperator='Equals';
        String OSRValue=String.valueOf(DateTime.now());

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
//        system.assertEquals(o.Opp_Score__c,OSRScore);
//Date criteria don't yet work
        //Negative test in next test method
    }//verifyOppDateEquals

  static testMethod void verifyOppDateEqualsNegativeTest(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='CreatedDate';
        String OSROperator='Equals';
        DateTime dateValue=DateTime.now();
        DateTime dateValue2=dateValue.addDays(3);
        String OSRValue=String.valueOf(dateValue2);

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, CreatedDate,NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.debug('Created Date: '+o.CreatedDate+' ; OSRValue : '+OSRValue);
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDateEqualsNegativeTest

 static testMethod void verifyOppDateNotEqualTo(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='CreatedDate';
        String OSROperator='Not Equal To';
        Date dateValue=Date.today();
        Date dateValue2=dateValue.addDays(2);
        String OSRValue=String.valueOf(dateValue2);

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
//        system.assertEquals(o.Opp_Score__c,OSRScore);
//Date criteria don't yet work
        //Negative test in next test method
    }//verifyOppDateNotEqualTo

  static testMethod void verifyOppDateNotEqualToNegativeTest(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='CreatedDate';
        String OSROperator='Not Equal To';
        String OSRValue=String.valueOf(Date.today());

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyOppDateNotEqualToNegativeTest

  static testMethod void verifyDupeRulesDoesntGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator='Equals';
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore*2);
    }//verifyDupeRulesDoesntGack

  static testMethod void verifyNullFieldNameDoesntGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName=null;
        String OSROperator='Equals';
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        try{
            insert osrs;
        } catch(Exception e){
            system.debug('OSR insert failed as expected due to null FieldName ' + e);       
        }
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyNullFieldNameDoesntGack
    
static testMethod void verifyNullOperatorDoesntGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator=null;
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyNullOperatorDoesntGack

  static testMethod void verifyInvalidFieldNameDoesntGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='bob';
        String OSROperator='Equals';
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        try{
            osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        } catch (exception e){
            Boolean expectedExceptionThrown=e.getMessage().contains('System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Error: Invalid Opportunity field name entered:');
            system.AssertEquals(expectedExceptionThrown, true);
        }
    }//verifyInvalidFieldNameDoesntGack
    
    static testMethod void verifyInvalidOperatorDoesntGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator='bob';
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertNOTEquals(o.Opp_Score__c,OSRScore);
    }//verifyInvalidOperatorDoesntGack

    static testMethod void verifyFieldNameCapitalsDontGack(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='NextStep';
        String OSROperator='Equals';
        String OSRValue='NextStep';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        OSRFieldName='NextStep';
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        
        Test.StartTest();
        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        Test.StopTest();

        Opportunity o=[Select Id, NextStep,Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(o.Opp_Score__c,OSRScore*2);
    }//verifyFieldNameCapitalsDontGack

/* OppFork cm There may not need to be a test of the Delete Trigger as it pertains to a related Campaign Member for OppScoring
    static testMethod void verifyDeleteTrigger(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=5;
        String OSRType='Campaign Member';
        String OSRFieldName='Status';
        String OSROperator='Equals';
        String OSRValue='Sent';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        String OppName='TestOpp';
        String NextStep='NextStep';
        String LeadSource='Web';
        Boolean PrivateOpp = False;
        Double Amt = 1000;
        String CampaignName='2009-Q3-Event-Dreamforce 2009';

        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        insert osrs;
        createCampaign(CampaignName);

        opps=createOpps(numOpps,OppName,NextStep, LeadSource, PrivateOpp, Amt);
        List<CampaignMember> cms=createCMs(NumOpps, c.Id,opps,'Sent');

        test.startTest();
        insert cms;
        cms=[SELECT Id, Campaign_Score__c FROM CampaignMember WHERE Id IN: cms];
//      system.debug('# CamapignMembers is :'+cms.size());
//      system.debug('CampaignMemberScore for the first is :'+cms[0].Campaign_Score__c);
        system.assertEquals(OSRScore, cms[0].Campaign_Score__c);

        Opportunity o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(OSRScore, o.Campaign_Score__c);
//        system.debug('Campaign score on the Opportunity is :'+o.Campaign_Score__c);
        
        delete cms;
        test.stopTest();
        o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
        system.assertEquals(0, o.Campaign_Score__c);
    }//verifyDeleteTrigger 
*/        

    static testMethod void verifyOSRLabelAndName(){
        Boolean Active=True;
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='StageName';
        String OSROperator='Equals';
        String OSRValue='Closed Won';
        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();

        cleanUpTestData();
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    

        insert osrs;
        OppScoringRule__c osr=[Select Id, Name, Field_Label__c, Field_Name__c FROM OppScoringRule__c WHERE Id=:osrs[0].Id LIMIT 1];
        //Check it first upon insert
        system.assertEquals(osr.Field_Label__c,Schema.SObjectType.Opportunity.fields.getMap().get(OSRFieldName).getDescribe().getLabel());
        
        OSRFieldName='Type';
        osr.Field_Name__c=OSRFieldName;
        update osr;
        osr=[Select Id, Name, Field_Label__c, Field_Name__c FROM OppScoringRule__c WHERE Id=:osrs[0].Id LIMIT 1];
        //Check again after update
        system.assertEquals(osr.Field_Label__c,Schema.SObjectType.Opportunity.fields.getMap().get(OSRFieldName).getDescribe().getLabel());
    }//verifyOSRLabelAndName


    public static testMethod void testOppScoringRulesController() {
        
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.OppScoringRulesEdit;
        
        //In this case, the Visualforce page named 'success' is the starting point of this test method. 
        Test.setCurrentPage(pageRef);

        OppScoringRule__c osr=new OppScoringRule__c();
        osr.Type__c='Opportunity';
        osr.Field_Name__c='IsPrivate';//this will run the checkbox check
        osr.Score_Change__c=5;
        osr.Operator__c='Equals';
        osr.Value__c='True';

        ApexPages.StandardController sc = new ApexPages.StandardController(osr);
        OppScoringRulesController scExt = new OppScoringRulesController(sc);
        scExt.getOSRFieldNames();
        scExt.getOSROperator();
        scExt.getValuePicklistOptions();
        
        osr.Type__c='Opportunity';
        osr.Field_Name__c='StageName';//this will run the checkbox check
        apexPages.StandardController sc2 = new ApexPages.StandardController(osr);
        OppScoringRulesController scExt2 = new OppScoringRulesController(sc2);
        scExt.getOSRFieldNames();
        scExt.getOSROperator();
        scExt2.getValuePicklistOptions();
        
        scExt.savenew();//test no exception upon saving & creating a new record
                        //Also having active=false by default should ensure the limits trigger doesn't gack if active = false.
                        //Note due to Apex test deficiencies the limit can't be tested directly (limited to 100 record inserts in 1 method)
    }//testOppScoringRulesController        

/* Commenting the following unit tests as these test the batch processing of Opportunities
* and campaigns. These are not required as of 11/21/2011 */
 /* public static testMethod void testOppScoringInitialize () {//tests the batch apex method for campaign members
        if(runBatchTests==True){//if 1
            Long NumOpps=10;//test methods can't test more than ~100 records inserted, so no point in even trying as the app scales over 200 Opportunity rules
            Long NumOppRules=10;
            
            List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
            cleanUpTestData();
            
            List<Opportunity> opps=createOpps(NumOpps, 'Opportunity', 'NextStep', False, 'Web', False,1000);
      
            for (Integer i=0;i<NumOppRules;i++){
                osrs.add(createOSR(TRUE, 'Opportunity', 1, 'NextStep', 'equals', 'NextStep'));
            }//for 1    
    
            insert osrs;
            
            Test.StartTest(); 
                OppScoringInitialize initLS=new OppScoringInitialize ();
                initLS.oppQuery='Select Id FROM Opportunity  LIMIT 10';
                Database.executeBatch(initLS, 10);
            Test.StopTest();
                
            Opportunity o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
                
    //        system.debug('Assert Opp_Score__c = 1 (or 10, or 100).  Actual: ' +o.Opp_Score__c);
            System.AssertEquals(NumOppRules,o.Opp_Score__c);
    //        system.debug('Assert Total_Opp_Score__c = '+NumOppRules+'.  Actual:' +o.Total_Opp_Score__c);
            System.AssertEquals(NumOppRules,o.Total_Opp_Score__c);
        }//if 1
   }//testOppScoringInitialize */
   
  /* public static testMethod void testOppCampaignScoreInitialize () {//tests the batch apex method for campaign members
       if(runBatchTests==True){//if 1
            Long NumOpps=1;//test methods can't test more than ~100 records inserted, so no point in even trying as the app scales over 200 Opportunity rules
            Integer i;
            Integer cmScore=2;
            List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();

            cleanUpTestData();
            
            List<Opportunity> opps=createOpps(NumOpps, 'Opportunity', 'NextStep', False, 'Web', False,1000);
            createCampaign('Campaign 1');
            List<CampaignMember> cms=createCMs(NumOpps, c.Id,opps,'Sent');
            insert cms;
                   
            Long NumCMRules=10;
            for (i=0;i<NumCMRules;i++){
                osrs.add(createOSR(TRUE, 'Campaign Member', cmScore, 'Status', 'equals', 'Sent'));
            }    
            insert osrs;
             
            Test.StartTest();      
                OppCampaignScoreInitialize initCS=new OppCampaignScoreInitialize();
                initCS.cmQuery='Select Id, hasResponded,Campaign_Score__c FROM CampaignMember LIMIT 10';
                Database.executeBatch(initCS, 10);
            Test.StopTest();

            Opportunity o=[Select Id, Opp_Score__c FROM Opportunity WHERE Id=:opps[0].Id LIMIT 1];
            CampaignMember cm=[Select Id, Campaign_Score__c FROM CampaignMember WHERE OppId=:opps[0].Id LIMIT 1];
            
//            system.debug('Assert cm Campaign_Score__c = '+cmScore+'.  Actual: ' +cm.Campaign_Score__c);
            System.AssertEquals(cmScore*NumCMRules,cm.Campaign_Score__c);
//            system.debug('Assert Opportunity Campaign_Score__c = '+cmScore+'.  Actual: ' +o.Campaign_Score__c);
            System.AssertEquals(cmScore*NumCMRules,o.Campaign_Score__c);
//            system.debug('Assert Total_Opp_Score__c = '+NumCMRules+cmScore+'.  Actual:' +o.Total_Opp_Score__c);
            System.AssertEquals(NumCMRules*cmScore,o.Total_Opp_Score__c);
       }//if 1            
   }//testOppCampaignScoreInitialize */

   /*  public static testMethod void testOppScoringSetupController() {
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.OppScoringSetup;
        cleanUpTestData();
        test.startTest();
        Test.setCurrentPage(pageRef);
        OppScoringBatchInitialize ctr = new OppScoringBatchInitialize();

        ctr.autorun();
        test.stopTest();
   }//testOppScoringSetupController   */     
   
   static testMethod void verifyLongRuleNameDoesntBreak(){
        Long numOpps=1;
        List<Opportunity> opps = new List<Opportunity>();
        Boolean Active=True;
        
        Double OSRScore=1;
        String OSRType='Opportunity';
        String OSRFieldName='LeadSource';
        String OSROperator='Does Not Contain';
        String OSRValue='123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';

        List<OppScoringRule__c> osrs=new List<OppScoringRule__c>();
        
        cleanUpTestData();
        
        osrs.add(createOSR(Active, OSRType , OSRScore, OSRFieldName, OSROperator, OSRValue));    
        //test is that this doesn't gack:
        insert osrs;
        
    }//verifyLongRuleNameDoesntBreak 
    
}//OppScoringTests