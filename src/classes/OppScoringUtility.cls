public without sharing class OppScoringUtility {
	public static void OppScoringUtility(List<Opportunity> opps) {
		
    Set<Id> oppIds=new Set<Id>();
    Map<Id, Double> oppScores=new Map<Id,Double>();    

    //Needed as asynch apex does not allow passage of Sobjects, only Set's
    for (Opportunity o: opps){
    	if(!(o.Application_Completed__c)) oppIds.add(o.Id);
    }

    //Send that list of created or updated campaign members to the apex class for processing
    system.debug('Future opp scoring method evaluateOpps already called? '+OppScoring.oppScoringClassAlreadyCalled());
    if (OppScoring.oppScoringClassAlreadyCalled()==False){
        system.debug('# Future Calls until limit hit: '+Limits.getLimitFutureCalls());
        Integer limit1 = Limits.getLimitFutureCalls() - Limits.getFutureCalls();
        system.debug('Future calls remaining before limit: ' + limit1);
        if (limit1>0){//don't call the method if the limit is reached
            OppScoring.evaluateOpps(oppIds);    
        }    
    }  
	}
}