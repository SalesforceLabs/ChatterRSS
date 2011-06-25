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
public with sharing class RSS2Chatter_FeedRelatedObjectExtenson {
	public String rssId = '';
	public string ret{get;set;}
	public Boolean isTest = false;
	public RSS2Chatter_FeedRelatedObjectExtenson(apexpages.standardController con){
		
		RSS_Feed_Related_Object__c r = (RSS_Feed_Related_Object__c) con.getRecord();
		rssId = r.RSS_Feed__c;
		ret=apexpages.currentPage().getParameters().get('returl');
		
	}
	
	public pagereference rsspage(){
		if (rssId !='' && rssId != null && !isTest ){
			return new apexPages.Pagereference('/apex/RSS2Chatter_Associate_Objects?id=' + rssId);
		}else{
			String objId = ret.substring(1);
			string objType = '';
			if (objId.substring(0,3) == '001'){
				objType='account';
			} else if (objId.substring(0,3) == '701'){
				objType='campaign';
			} else if (objId.substring(0,3) == '006'){
				objType='opportunity';
			}
			return new apexPages.Pagereference('/apex/RSS2Chatter_AssociateFeedToObject?objtype=' + objtype + '&objid=' + objId);
		}
	}
}