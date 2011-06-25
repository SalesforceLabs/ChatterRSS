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
public class RSS2Chatter_Main {
	public Boolean isTest = false;
	public String testReturnXML = '';
	public String  soql = '';
	public String errorMessage = '';
	public list<RSS_Feed_Posts__c> rssPosts = new list<RSS_Feed_Posts__c>();
	private list<FeedPost> chatterPosts = new list<FeedPost>();
	private DateTime lastsync = DateTime.Now();
	private Decimal NumPostsToRead = 10;
	private Decimal numPostsRead = 0;
	private final Integer maxPostSize = 1000;
	private List<RSS_Feed_Related_Object__c> relatedObjects ;
	
	public RSS2Chatter_Main(){
		
	}
	
    public void main(RSS_Feed__c rss, Boolean commitToDB){   	
		numPostsRead = 0;
		system.debug('\n\n' + rss.name );
		if (rss.Maximum_Posts_to_Read__c != null){
			numPostsToRead = rss.Maximum_Posts_to_Read__c;
		}
		relatedObjects = new List<RSS_Feed_Related_Object__c>();
		getfeed(rss.url__c, rss.Id, numPostsToRead, rss.LastModifiedById, rss.CreatedById, rss.Name);
		
		system.debug('\n\n relatedObjects: ' + relatedObjects.size() );
    	if (commitToDB){
	    	Database.SaveResult[] saveRes = Database.Insert(rssPosts, false);
	    	Map<Id,Id> rssToChatterize = new Map<Id,Id>();
	    	for(Database.SaveResult result : saveres){
	    		if (result.isSuccess()){
	    			rssToChatterize.put(result.getId(), result.getId());
	    		}else{
	    			system.debug('\n\nError Saving');
	    			for (database.error errmsg : result.getErrors()){
	    				system.debug (errmsg.getMessage() + '\n');	
	    			}
	    			
	    		}
	    		
	    	}
	    	String rolledUpPostsText = '\n\n';
	    	FeedPost rolledUpfPost = new FeedPost();
	    	for(RSS_Feed_Posts__c RSSrecord : [select RSS_Feed__c, 
	    											  Comments__c,
												  	  description__c,
												  	  GUID__c,
												  	  link__c,
													  Publish_date__c,
													  title__c 
										 	   from RSS_Feed_Posts__c
										 	   where id in : rssToChatterize.keyset()]){
				if (rss.Roll_Up_Posts__c){
					String temp = '\n\n' + RSSrecord.title__c + ' (' + RSSrecord.link__c +')';
					rolledUpfPost.ParentId = RSSrecord.RSS_Feed__c;
					if (temp.length() + rolledUpPostsText.length() > maxPostSize){
						//rolledUpfPost.ParentId = RSSrecord.RSS_Feed__c;
						rolledUpfPost.title = rss.Name;
						rolledUpfPost.linkurl = rss.url__c;
						rolledUpfPost.Body = rolledUpPostsText;
						chatterPosts.add(rolledUpfPost);
						for (RSS_Feed_Related_Object__c obj : relatedObjects){
							//system.DEBUG('\n\n 1. Adding Related Object Posts: '+ obj.Related_Object_Id__c);
							FeedPost f = new FeedPost();
							f.ParentId = obj.Related_Object_Id__c;
							f.title = rolledUpfPost.title;
							f.linkurl = rolledUpfPost.linkurl;
							f.Body = rolledUpfPost.Body;
							chatterPosts.add(f);
						}
						rolledUpfPost = new FeedPost();
						rolledUpPostsText = '';
					}else{
						rolledUpPostsText = rolledUpPostsText + temp;
					}
				}else{
					FeedPost fpost = new FeedPost();
					fpost.ParentId = RSSrecord.RSS_Feed__c;
					fpost.title = RSSrecord.title__c;
					fpost.linkurl = RSSrecord.link__c;
					String temp = RSSrecord.description__c;
					string pubDate = '\n\n (Published: ' + RSSrecord.Publish_date__c + ')';
					
					if (temp != null){
						temp = removeHTML(RSSrecord.description__c);
					}else{
						temp = '';
					}
					if (temp == '' ){
						temp = RSSrecord.Comments__c;
					}else{
						temp = temp + '\n\n';
						if (temp.length() + pubDate.length() > maxPostSize ){
							fpost.Body = temp.substring(0,(maxPostSize - (pubDate.length() + 5))) + ' ...' + pubdate;	
						} else{
							fpost.Body = temp + pubDate;
						}
					}
					chatterPosts.add(fpost);
					for (RSS_Feed_Related_Object__c obj : relatedObjects){
						system.DEBUG('\n\n 2. Adding Related Object Posts: '+ obj.Related_Object_Id__c);
						FeedPost f = new FeedPost();
						f.ParentId = obj.Related_Object_Id__c;
						f.title = fpost.title;
						f.linkurl = fpost.linkurl;
						f.Body = fpost.Body;
						chatterPosts.add(f);
					}	
				}
												 
			}
			if (rss.Roll_Up_Posts__c){
				rolledUpfPost.title = rss.Name;
				rolledUpfPost.linkurl = rss.url__c;
				rolledUpfPost.Body = rolledUpPostsText;
				chatterPosts.add(rolledUpfPost);
				for (RSS_Feed_Related_Object__c obj : relatedObjects){
					system.DEBUG('\n\n 3. Adding Related Object Posts: '+ obj.Related_Object_Id__c);
					FeedPost f = new FeedPost();
					f.ParentId = obj.Related_Object_Id__c;
					f.title = rolledUpfPost.title;
					f.linkurl = rolledUpfPost.linkurl;
					f.Body = rolledUpfPost.Body;
					chatterPosts.add(f);
				}	
			}
			
			saveRes = Database.Insert(chatterPosts, false);	
			for(Database.SaveResult result : saveres){
				if(!result.isSuccess()){
					system.debug('\n\n Failed to post to chatter: ' + result.getErrors());
				}
			}
    	}		
    } 
        
    public void getFeed(string url, string parentId, Decimal numPostsToRead , string LastModifiedById, string CreatedById, string Name){
    	string xml = '';
    	
		Http h = new Http();    
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(url);
	    req.setMethod('GET');
		system.debug('\n\n numPostsToRead=' + numPostsToRead);
		if(!isTest){
			try{
				HttpResponse res = h.send(req);
				xml = res.getBody();
				relatedObjects = [Select r.Related_Object_Id__c From RSS_Feed_Related_Object__c r where r.RSS_Feed__c = : parentId];	
			}catch(exception e){
				errorMessage = 'A problem was encountered while reading the feed "' + Name + '" \n\nThe Message Reads:\n' + e.getMessage();
				FeedPost fpost = new FeedPost();
				fpost.ParentId = CreatedById;
				fpost.title = Name;
				fpost.body = errorMessage;
				chatterPosts.add(fpost);
				
				if (LastModifiedById != CreatedById){
					fpost = new FeedPost();
					fpost.ParentId = LastModifiedById;
					fpost.title = Name;
					fpost.body = errorMessage;
					chatterPosts.add(fpost);	
				}

				fpost = new FeedPost();
				fpost.ParentId = parentId;
				fpost.title = Name;
				fpost.body = errorMessage;
				chatterPosts.add(fpost);
				return;					
			}
		    
    	}else{
    		xml = testReturnXML;
    	}
			
		//system.debug(xml);
		XmlStreamReader xsr = new XmlStreamReader(xml);
		
		while (xsr.hasNext() && !maxPosts()){
			if (xsr.getEventType() ==XmlTag.START_ELEMENT){
				if(xsr.getLocalName() == 'item'){
					parseItem(xsr, parentId);
				}else if(xsr.getLocalName() == 'entry'){
					parseItem_ATOM(xsr, parentId);
				}
			}
			xsr.next();
		}
	}
	
	private void parseItem(XmlStreamReader xsr, string parentId){
		string currentElement = '';
		string currentTitle = '';
		string currentLinkUrl = '';
		string currentComments = '';
		string currentDescription = '';
		string currentguid  = '';
		string currentpubDate = '';
		while (xsr.hasNext()){
			if (xsr.getLocalName() == 'item' && xsr.getEventType() == XmlTag.END_ELEMENT){
				System.debug('\n\n currentElement: ' + currentElement);
				System.debug(' currentTitle: ' + currentTitle);
				System.debug(' currentComments: ' + currentComments);
				System.debug(' currentLinkUrl: ' + currentLinkUrl);
				System.debug(' currentDescription: ' + currentDescription);
				if (currentGUID == '' || currentGUID == null){
					currentGUID = currentLinkUrl;
				}
				RSS_Feed_Posts__c rssPost = new RSS_Feed_Posts__c(comments__c = currentComments,
																  description__c = currentDescription,
																  GUID__c = currentGUID,
																  link__c = currentLinkUrl,
																  Publish_date__c = currentpubDate,
																  rss_feed__c = parentId,
																  title__c = currentTitle);
				rssPosts.add(rssPost);
				numPostsRead ++;
				
				currentElement = '';
				currentTitle = ' ';
				currentLinkUrl = '';  
				currentComments = '';
				currentDescription = '';
				currentguid  = '';
				currentpubDate = '';
				break;
			} else if (xsr.getEventType() == XmlTag.START_ELEMENT){
				currentElement = xsr.getLocalName();
				//system.debug('ELEMENT: ' +  currentElement);
			} else if (xsr.getEventType() == XmlTag.CHARACTERS ) {
				string temp = xsr.getText();
          		//System.debug(' VALUE: ' + temp);
          		if (currentElement == 'title'){
          			currentTitle  = currentTitle + temp;
          		}else if(currentElement == 'link'){
					currentLinkUrl  = currentLinkUrl + temp;
          		}else if(currentElement == 'comments'){
					currentComments  = currentComments + temp;
          		}else if(currentElement == 'description'){
          			currentDescription = currentDescription + temp;
          		}else if(currentElement == 'guid'){
          			currentGUID = currentGUID + temp;
          		}else if(currentElement.toLowerCase() == 'pubdate'){
          			currentpubdate = currentpubdate + temp;
          		}
        	}
			xsr.next();
		}
	}
		
		
	private void parseItem_ATOM(XmlStreamReader xsr, string parentId){
		string currentElement = '';
		string currentTitle = '';
		string currentLinkUrl = ''; 
		string currentComments = '';
		string currentDescription = '';
		string currentguid  = '';
		string currentpubDate = '';
		while (xsr.hasNext()){
			if (xsr.getLocalName() == 'entry' && xsr.getEventType() == XmlTag.END_ELEMENT){
				//System.debug('\n\n currentElement: ' + currentElement);
				//System.debug(' currentTitle: ' + currentTitle);
				//System.debug(' currentComments: ' + currentComments);
				//System.debug(' currentLinkUrl: ' + currentLinkUrl);
				//System.debug(' currentDescription: ' + currentDescription);
				if (currentGUID == '' || currentGUID == null){
					currentGUID = currentLinkUrl;
				}
				RSS_Feed_Posts__c rssPost = new RSS_Feed_Posts__c(comments__c = currentComments,
																  description__c = currentDescription,
																  GUID__c = currentGUID,
																  link__c = currentLinkUrl,
																  Publish_date__c = currentpubDate,
																  rss_feed__c = parentId,
																  title__c = currentTitle);
				rssPosts.add(rssPost);
				numPostsRead ++;
				
				currentElement = '';
				currentTitle = ' ';
				currentLinkUrl = '';  
				currentComments = '';
				currentDescription = '';
				currentguid  = '';
				currentpubDate = '';
				break;
			} else if (xsr.getEventType() == XmlTag.START_ELEMENT){
				currentElement = xsr.getLocalName();
				//system.debug('ELEMENT: ' +  currentElement);
				if(currentElement == 'link'){
					//currentLinkUrl  = xsr.getAttributeLocalName(0);
					currentLinkUrl = xsr.getAttributeValueAt(0);
					//system.debug('\n\ncurrentLinkUrl: ' +  currentLinkUrl);
          		}
			} else if (xsr.getEventType() == XmlTag.CHARACTERS ) {
				string temp = xsr.getText();
          		//System.debug(' VALUE: ' + temp);
          		if (currentElement == 'title'){
          			currentTitle  = currentTitle + temp;
          		}else if(currentElement == 'comments'){
					currentComments  = currentComments + temp;
          		}else if(currentElement == 'content'){
          			currentDescription = currentDescription + temp;
          		}else if(currentElement == 'id'){
          			currentGUID = currentGUID + temp;
          		}else if(currentElement.toLowerCase() == 'updated'){
          			currentpubdate = currentpubdate + temp;
          		}
        	}
			xsr.next();
		}
	}
		
	private Boolean maxPosts(){
		if(numPostsToRead == 0){
			return false;
		}else{
			return numPostsRead >= numPostsToRead;
		}
	}
		
	private String removeHTML(String htmlString){ 
		// thanks to community user Sureka (http://community.salesforce.com/t5/user/viewprofilepage/user-id/34293) for this snippet!
		try{
			system.debug('\n\n HTML=' + htmlString);
			String noHTMLString = htmlString;
			noHTMLString = noHTMLString.replaceAll('\\<.*?\\>', ''); 
			noHTMLString = noHTMLString.replaceAll('<br/>', '\n' ); 
			noHTMLString = noHTMLString.replaceAll('&#39;', '\'');
			noHTMLString = noHTMLString.replaceAll('&#160;', '\'');
			noHTMLString = noHTMLString.replaceAll('&quot;','\"');
			return noHTMLString;
		}catch(Exception e){
			return htmlString;
		}
	}
        

}