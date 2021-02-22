trigger SurveyTrigger on Survey_Request__c (after insert,after update) {
	List<Survey_Request__c> survey_list = new List<Survey_Request__c>();
    
    Boolean is_there_a_record = true;
    for(Survey_Request__c st: trigger.new){
        is_there_a_record = true;
        if(trigger.oldMap == null){
            // oldMap is absent
            is_there_a_record = false;
        } else if(!trigger.oldMap.keySet().contains(st.id)){
            //oldmap not empty but record not present
            is_there_a_record = false;
        }
    	//If is_there_a_record is true that means record in not there in oldmap. that means I m inserting new one
    	
        if(!is_there_a_record){                                 //false
            if(st.status__c=='Stop'){
                system.debug('OPPPsss...');
                st.adderror('Dont Stop while creation !!');
            }
        }else{
            //But if its false that means we need are updating and use old map values for same.
            Survey_Request__c existing = trigger.oldMap.get(st.id);
            system.debug(existing);
            if(existing.Status__c == 'Close' && st.Status__c!='Close'){
                system.debug('Oppss1..');
                st.adderror('Cannot change once closed');
            }else 
            {
                if(st.Status__c=='Stop'){
                    if(st.Stop_Started_Date__c!=null){
                        if(existing.Stop_Started_Date__c != st.Stop_Started_Date__c)
                        {
                            Survey_Request__c toavoiderror = st.clone(true, true, false, false);
                            toavoiderror.Total_Stop_Duration_in_Days__c = toavoiderror.Stop_Started_Date__c.daysBetween(System.today());
                            Survey_list.add(toavoiderror);
                        } 
                    }else
                    {
                        if(st.Stop_Started_date__c == null){
                           st.adderror('provide date. It should not be a future date'); 
                        }   
                    }
                }else
                {	
                    //if it is not stop for both types of records
                    if(existing.Stop_Started_date__c!=st.Stop_Started_date__c && st.Status__c!='Stop'){
                     	Survey_Request__c toavoidUpdateerror =  st.clone(true, true, false, false);
                         toavoidUpdateerror.Total_Stop_Duration_in_Days__c = null;
                         Survey_list.add(toavoidUpdateerror);
                    }
                }   
            }
        }
     if(!survey_list.isEmpty()){
        update survey_list;
    } 
}
}