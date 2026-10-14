public with sharing class CaseHandler {
    public static void beforeupdate(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap){
        Casehelper.CaseMilestoneBreach(oldCaseMap, newCaseMap);
        Casehelper.UpdateResolutionTime(oldCaseMap, newCaseMap);
    }
}