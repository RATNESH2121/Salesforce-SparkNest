public with sharing class LeadHelper {
    public static void LeadDuplicatePrevent(List<Lead> newlead){
        Set<String> emails = new Set<String>();

        for(Lead eachlead: newlead){
            emails.add(eachlead.Email);
        }

        List<Lead> ll = [Select id,email from lead where Email IN: emails];
        Set<String> existingmail=new Set<String>();

        for(Lead eachlead: ll){
            if(eachlead.Email != null){
            existingmail.add(eachlead.Email.toLowerCase());
            }
        }

        for(Lead eachlead: newlead){
            if(eachlead.Email != null && existingmail.contains(eachlead.Email.toLowerCase())){
                eachlead.addError('DUplicate email exist');
            }
        }
    }
}