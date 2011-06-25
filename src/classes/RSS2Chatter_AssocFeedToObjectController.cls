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
public with sharing class RSS2Chatter_AssocFeedToObjectController {
	
	public List<SelectOption> avialableFeeds {get; Set;}
	public List<SelectOption> selectedFeeds {get; Set;} 
	public string selectedAssignedItem {get; set;}
	public string selectedAvailableItem {get; set;}
	private String objId = '';
	private String objType = '';
		 
	public RSS2Chatter_AssocFeedToObjectController(){
		objId = apexpages.currentPage().getParameters().get('objId');
		objType = apexpages.currentPage().getParameters().get('objType');
		listFeeds();
	}
	
	public pagereference assignFeed(){
		system.debug('\n\n' + objId + objType);
		if (selectedAvailableItem != '' && selectedAvailableItem != null){
			RSS_Feed_Related_Object__c o = new RSS_Feed_Related_Object__c (RSS_Feed__c = selectedAvailableItem);
			if(objType =='account'){
				o.Account__c = objId;
			} else if(objType =='campaign'){
				o.Campaign__c = objId;
			} else if(objType =='opportunity'){
				o.Opportunity__c = objId;
			}
			insert (o);
		}

		listFeeds();
		return null;
	}
	
	public pagereference removeFeed(){
		if (selectedAssignedItem != '' && selectedAssignedItem != null){
			RSS_Feed_Related_Object__c o = new RSS_Feed_Related_Object__c (id = selectedAssignedItem);
			delete (o);
		}
		listFeeds();
		return null;
	}
	
	public pagereference returntoObj(){
		return new apexpages.Pagereference('/../' + objId);
	}
	private void listFeeds(){
		List<RSS_Feed_Related_Object__c> selected = [Select r.Related_Object_Id__c, r.RSS_Feed__r.Name, r.RSS_Feed__c, r.Id 
													 From RSS_Feed_Related_Object__c r
													 where Related_Object_Id__c = : objId];
		avialableFeeds = new List<SelectOption>();
		selectedFeeds = new List<SelectOption>();
		Map<String, String> assignedFeedId = new Map<String, String>();
		
		for (RSS_Feed_Related_Object__c o : selected){
			SelectOption so = new SelectOption(o.id, o.RSS_Feed__r.Name);
			selectedFeeds.add(so);
			assignedFeedId.put(o.RSS_Feed__c, o.RSS_Feed__c);
		}
		
		List<RSS_Feed__c> available = [Select r.Name, r.Id 
													  From RSS_Feed__c r 
													  where id not in : assignedFeedId.keySet()];
		for (RSS_Feed__c o : available){
			SelectOption so = new SelectOption(o.id, o.Name);
			avialableFeeds.add(so);
		}
		
	}
	
	
	
}