trigger limitNumOSRRules on OppScoringRule__c (before Insert, before Update) {
    Integer oppRuleLimit=200;
    Integer cmRuleLimit=450;
    List<OppScoringRule__c> activeOppRules=[SELECT Id, Active__C FROM OppScoringRule__c WHERE Type__c='Opp' AND Active__c=True];
    List<OppScoringRule__c> activeCMRules=[SELECT Id, Active__C FROM OppScoringRule__c WHERE Type__c='Campaign Member' AND Active__c=True];
    Integer numOppRules=activeOppRules.size();
    Integer numCMRules=activeCMRules.size();
    Boolean overOppRuleLimit=(numOppRules>oppRuleLimit);
    Boolean overCMRuleLimit=(numCMRules>cmRuleLimit);
    OppScoringRule__c osr = new OppScoringRule__c();
    
    for (Integer i=0;i<trigger.new.size();i++){//for
        osr=trigger.new[i];
        if(Trigger.isInsert){//if 1
            if(osr.Type__c=='Opportunity'&&osr.Active__c==True){//if 2
                numOppRules++;
                overOppRuleLimit=(numOppRules>oppRuleLimit);
                if(overOppRuleLimit==True){//if 3
                    osr.adderror('Error: Opportunity active rule limit exceeded.  Limit: '+oppRuleLimit+' active opp rules.  To create a new opp rule, first deactivate or delete another active opp rule.');
                }//if 3   
            } else if (osr.Type__c=='Campaign Member'&&osr.Active__c==True){
                numCMRules++;    
                overCMRuleLimit=(numCMRules>cmRuleLimit);
                if(overCMRuleLimit==True){
                    osr.adderror('Error: Campaign member active rule limit exceeded.  Limit: '+cmRuleLimit+' active campaign member rules. To create a new campaign member rule, first deactivate or delete another campaign member rule.');
                }//if 3
            }//if 2    
        }//if 1
        if(Trigger.isUpdate){//if 1
            OppScoringRule__c osrOld=trigger.old[i];
            if(osrOld.Active__c==True){//if 2
                if(osrOld.Type__c=='Opportunity'&&overOppRuleLimit==True&&osr.Active__c==True){//if 3
                        osr.adderror('Error: Opportunity active rule limit exceeded.  Limit: '+oppRuleLimit+' active opp rules.  To edit any active opp rules, first deactivate or delete another active opp rule.');
                }else if (osrOld.Type__c=='Campaign Member'&overCMRuleLimit==True&&osr.Active__c==True){
                    osr.adderror('Error: Campaign member active rule limit exceeded.  Limit: '+cmRuleLimit+' active campaign member rules.  To edit any active campaign member rules, first deactivate or delete another active campaign member rule.');                    
                }//if 3        
            }else if(osrOld.Active__c==False){
                if(osr.Active__c==True){//if 3
                    if (osrOld.Type__c=='Opportunity'){//if 4
                        numOppRules++;
                        overOppRuleLimit=(numOppRules>oppRuleLimit);
                        if(overOppRuleLimit==True){//if 5
                            osr.adderror('Error: Opportunity active rule limit exceeded.  Limit: '+oppRuleLimit+' active opp rules.  To activate inactive opp rules, first deactivate or delete another active opp rule.');
                        }//if 5    
                    }else if(osrOld.Type__c=='Campaign Member'){
                        numCMRules++;
                        overCMRuleLimit=(numCMRules>cmRuleLimit);
                        if(overOppRuleLimit==True){//if 5
                            osr.adderror('Error: Campaign member active rule limit exceeded.  Limit: '+cmRuleLimit+' active campaign member rules.  To activate inactive campaign member rules, first deactivate or delete another active campaign member rule.');
                        }//if 5    
                    } //if 4    
                }//if 3        
            }//if 2
        }//if 1      
    }//for   
}