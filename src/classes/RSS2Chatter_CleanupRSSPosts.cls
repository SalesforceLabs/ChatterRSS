/*
Copyright (c) 2011, salesforce.com, inc.
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
global class RSS2Chatter_CleanupRSSPosts implements Database.Batchable<sObject>{
	
	public String  soql = '';
	
	global  database.querylocator start(Database.BatchableContext bc){
		Integer cutoffDays = 0 - integer.valueof(chatterRSS__c.getInstance('RemoveAfter').Value__c);
		DateTime cutOff = DateTime.newInstance(Date.Today().addDays(cutoffDays), Time.newInstance(0,0,0,0));   
		
        if (soql == ''){
        	soql = 'select Id from RSS_Feed_Posts__c where LastModifiedDate < ' + cutOff.format('yyyy-MM-dd') + 'T00:00:00Z';
        } 
        return Database.getQueryLocator(soql);
    }
    
    global void execute(Database.BatchableContext bc, sObject[] objects){
    	
    	delete(Objects);
    	
    }
    
    global void finish(Database.BatchableContext bc){
    	
    }
}