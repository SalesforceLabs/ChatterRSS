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
public with sharing class RSS2Chatter_PreviewController {
	public list <RSS_Feed_Posts__c> feedData {get;set;}
	public string feedId{get; set;}
	
	public RSS2Chatter_PreviewController(){
		feedId = apexpages.currentPage().getParameters().get('Id');
		RSS_Feed__c feed = [select Id, LastModifiedById, CreatedById, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where id = : feedId];
		RSS2Chatter_Main preview = new RSS2Chatter_Main();
		preview.main(feed,false);
		feedData = preview.rssPosts;
		if (preview.errorMessage !=''){
			apexPages.Message m = new ApexPages.Message(ApexPages.Severity.INFO, preview.errorMessage);
			apexpages.addMessage(m);
		}else{
			string msg = 'If there are post records on display then your feed is configured correctly. If there are no posts shown, then it may be an incompatible format, we currently only support ATOM and RSS 2 feeds.';
			apexPages.Message m = new ApexPages.Message(ApexPages.Severity.INFO, msg);
			apexpages.addMessage(m);
		}
	}
}