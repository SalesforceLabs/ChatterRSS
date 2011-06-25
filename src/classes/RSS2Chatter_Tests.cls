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
@isTest
private class RSS2Chatter_Tests {
	static testmethod void RSS2Chatter_FeedRelatedObjectExtenson(){
		
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		Account a = new Account(name = 'rsstestaccount');
		Campaign c = new Campaign(name = 'rsstestcampaign');
		Opportunity o = new Opportunity(name = 'rsstestopportunity', StageName = 'Prospecting', CloseDate = date.today());
		insert (a);
		system.assertNotEquals(null,a.id);
		insert (c);
		system.assertNotEquals(null,c.id);
		insert (o);
		system.assertNotEquals(null,o.id);
		system.assertNotEquals(null,rf.Id);
		
		RSS_Feed_Related_Object__c rfro = new RSS_Feed_Related_Object__c(RSS_Feed__c = rf.id);
		rfro.Account__c = a.id;
		rfro.campaign__c = c.id;
		rfro.opportunity__c = o.id;
		insert (rfro);
		system.assertNotEquals(null,rfro.Id);
		
		test.startTest();
		test.setCurrentPage(page.RSS2Chatter_OverrideNewRelObject);
		apexpages.currentPage().getParameters().put('id', rfro.id);
		apexpages.standardController obj = new apexpages.standardController (rfro);
		RSS2Chatter_FeedRelatedObjectExtenson con = new RSS2Chatter_FeedRelatedObjectExtenson(obj);
		pageReference pr = con.rsspage();
			
		con.rssId=rf.id;
		con.ret = '/' + a.id;
		con.isTest=true;
		pr = con.rsspage();
		
		test.stopTest();
		
	}

	static testmethod void testRSS2Chatter_AssociateObjectController(){
		
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		Account a = new Account(name = 'rsstestaccount');
		Campaign c = new Campaign(name = 'rsstestcampaign');
		Opportunity o = new Opportunity(name = 'rsstestopportunity', StageName = 'Prospecting', CloseDate = date.today());
		insert (a);
		system.assertNotEquals(null,a.id);
		insert (c);
		system.assertNotEquals(null,c.id);
		insert (o);
		system.assertNotEquals(null,o.id);
		system.assertNotEquals(null,rf.Id);
		
		test.startTest();
		test.setCurrentPage(page.RSS2Chatter_AssociateFeedToObject)	;
		apexpages.currentPage().getParameters().put('id', rf.id);
		apexpages.standardController obj = new apexpages.standardController (rf);
		RSS2Chatter_AssociateObjectController con = new RSS2Chatter_AssociateObjectController(obj);
		
		con.searchTerm = '';
		con.objectType = 'account';
		pageReference pr = con.searchfor();
		con.searchTerm = 'test';
		con.objectType = 'account';
		pr = con.searchfor();
		
		con.accounts[0].Checked=true;
		pr = con.assignAccounts();
		
		con.searchTerm = 'test';
		con.objectType = 'campaign';
		pr = con.searchfor();
		con.campaigns[0].Checked = true;
		pr=con.assignCampaigns();
		
		con.searchTerm = 'test';
		con.objectType = 'opportunity';
		pr = con.searchfor();
		con.opportunities[0].Checked = true;
		pr=con.assignOpportunities();
		
		test.stopTest();	
		
	}

	static testmethod void testRSS2Chatter_AssocFeedToObjectController(){
		
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		Account a = new Account(name = 'rsstestaccount');
		Campaign c = new Campaign(name = 'rsstestcampaign');
		Opportunity o = new Opportunity(name = 'rsstestopportunity', StageName = 'Prospecting', CloseDate = date.today());
		insert (a);
		system.assertNotEquals(null,a.id);
		insert (c);
		system.assertNotEquals(null,c.id);
		insert (o);
		system.assertNotEquals(null,o.id);
		system.assertNotEquals(null,rf.Id);
		
		test.startTest();
		test.setCurrentPage(page.RSS2Chatter_AssociateFeedToObject)	;
		apexpages.currentPage().getParameters().put('objId',a.id);
		apexpages.currentPage().getParameters().put('objType','account');
		RSS2Chatter_AssocFeedToObjectController con = new RSS2Chatter_AssocFeedToObjectController();
		
		con.selectedAvailableItem = rf.id;
		
		con.assignFeed();
		List<RSS_Feed_Related_Object__c> newobj = [select id from RSS_Feed_Related_Object__c ];
		system.assertNotEquals(0, newObj.size());
		con.selectedAssignedItem = newobj[0].id;
		con.removeFeed();
		test.stopTest();	
		
	}

	static testmethod void testGetRSS(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_GetRSS testObject = new RSS2Chatter_GetRSS();
		testObject.isTest = true;
		testObject.testReturnXML = xmlDoc1();
		testObject.soql = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		Database.executeBatch(testObject);
		test.stopTest();
	}
	
	static testmethod void testGetRSS_Main01(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_Main testObject = new RSS2Chatter_Main();
		
		testObject.isTest = true;
		testObject.testReturnXML = xmlDoc1();
		testObject.soql = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		testObject.main(rf, true);
		test.stopTest();
	}
	
	static testmethod void testGetRSS_Main02(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = true);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_Main testObject = new RSS2Chatter_Main();
		
		testObject.isTest = true;
		testObject.testReturnXML = xmlDoc2();
		testObject.soql = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		testObject.main(rf, true);
		test.stopTest();
	}
	
	static testmethod void testGetRSS_Main03(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = true);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_Main testObject = new RSS2Chatter_Main();
		
		testObject.isTest = true;
		testObject.testReturnXML = xmlDoc1();
		testObject.soql = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		testObject.main(rf, true);
		test.stopTest();
	}	

	static testmethod void testGetRSSWithRollup(){		
		test.startTest();
		RSS_Feed__c rf2 = new RSS_Feed__c(Name='UnitTest 2', URL__c = 'http://myurl2.com/' , Maximum_Posts_to_Read__c = 2, Roll_Up_Posts__c = true);
		insert rf2;
		system.assertNotEquals(null,rf2.Id);

		RSS2Chatter_GetRSS testObject = new RSS2Chatter_GetRSS();
		testObject.isTest = true;
		testObject.testReturnXML = xmlDoc1();
		testObject.soql = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		Database.executeBatch(testObject);
		test.stopTest();
		
	}
	

	
	static testmethod void testRSS2Chatter_ScheduleCleanup(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_ScheduleCleanup batch = new RSS2Chatter_ScheduleCleanup();
		
		batch.execute(null);
		test.stopTest();
	}
	
	static testmethod void testRSS2Chatter_PreviewController(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		test.setCurrentPage(page.RSS2Chatter_Preview);
		apexpages.currentPage().getParameters().put('Id',rf.Id);
		
		RSS2Chatter_PreviewController con = new RSS2Chatter_PreviewController();
		
		test.stopTest();
	}
		/*static testmethod void testRSS2Chatter_ScheduleGetRSS(){
		test.startTest();
		RSS_Feed__c rf = new RSS_Feed__c(Name='UnitTest 1', URL__c = 'http://myurl.com/' , Maximum_Posts_to_Read__c = 0, Roll_Up_Posts__c = false);
		insert rf;
		system.assertNotEquals(null,rf.Id);

		RSS2Chatter_ScheduleGetRSS batch = new RSS2Chatter_ScheduleGetRSS();
		batch.getRSSQuery = 'select Id, Name, Maximum_Posts_to_Read__c, url__c, Roll_Up_Posts__c from RSS_Feed__c where name like \'UnitTest%\' limit 1';
		
		batch.execute(null);
		test.stopTest();
	}*/
	
	private static string xmlDoc1(){
		string temp = '<?xml-stylesheet type="text/xsl" href="http://blogs.msdn.com/utility/FeedStylesheets/rss.xsl" media="screen"?>';
		temp = temp + '<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/" xmlns:wfw="http://wellformedweb.org/CommentAPI/">';
		temp = temp + '<channel>';
		temp = temp + '<title>Microsoft Ireland Blog</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/</link>';
		temp = temp + '<description />';
		temp = temp + '<dc:language>en-US</dc:language>';
		temp = temp + '<generator>Telligent Community (Build: 5.5.134.11459)</generator>';
		temp = temp + '<item>';
		temp = temp + '<title>Where’s the DPE Team?</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2010/07/02/where-s-the-dpe-team.aspx</link>';
		temp = temp + '<pubDate>Fri, 02 Jul 2010 11:38:50 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">191d46819-8472-40ad-a661-2c78acb4018c:10033835</guid>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2010/07/02/where-s-the-dpe-team.aspx#comments</comments>';
		temp = temp + '<description>Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1 Description 1</description>';
		temp = temp + '</item>';
		temp = temp + '<item>';
		temp = temp + '<title>Windows Phone 7 Developer Hub Comes to Dublin</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2010/05/25/windows-phone-7-developer-hub-comes-to-dublin.aspx</link>';
		temp = temp + '<pubDate>Tue, 25 May 2010 14:06:45 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">91d46819-8472-40ad-a661-2c78acb4018c:10014685</guid>';
		temp = temp + '<comments>Comments</comments>';
		temp = temp + '<description>';
		temp = temp + 'Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text Descripion Text ';
		temp = temp + '</description>';		
		temp = temp + '</item>';
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">291d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">391d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';		
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">491d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">591d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">691d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">791d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">891d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">991d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>'; 
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">1191d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">2291d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">3391d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">4491d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">5591d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">6691d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description>';
		temp = temp + '&lt;p&gt;About a year ago, &lt;a href="http://www.onten.net/blogs/tina/Life-At-Microsoft/" target="_blank"&gt;this video&lt;/a&gt; was posted which revealed that Microsoft geeks are incredibly competitive and that we love having code-offs.&amp;#160; I love this video &amp;amp; use it all the time in my talks and presentations.&lt;/p&gt; &lt;p&gt;I was thrilled to find out the same team recently did a &lt;a href="http://channel9.msdn.com/posts/Tina/Life-at-Microsoft-The-truth-revealedagain/" target="_blank"&gt;follow-up video&lt;/a&gt; which is equally hilarious.&amp;#160; Although the weather this week in Ireland has been crazy, the scuba employees are not actually from Cork.&amp;#160; Enjoy!&lt;/p&gt; &lt;object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="512" height="384"&gt; &lt;param name="source" value="http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap" /&gt; &lt;param name="initParams" value="deferredLoad=true,duration=0,m=http://ecn.channel9.msdn.com/o9/ch9/3/6/8/0/0/5/LIfeMSB3_ch9.wmv,autostart=false,autohide=true,showembed=true, thumbnail=http://channel9.msdn.com/App_Themes/default/vp09_10_20.xap, postid=500863" /&gt; &lt;param name="background" value="#00FFFFFF" /&gt; &lt;a href="http://go.microsoft.com/fwlink/?LinkID=124807" style="text-decoration: none;"&gt; &lt;img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style: none" /&gt; &lt;/a&gt; &lt;/object&gt; &lt;p&gt;Caution: iPhone scene may be a bit graphic for some viewers. ;-)&lt;/p&gt;';
		temp = temp + '&lt;i&gt;Cross posted from &lt;a href="http://blogs.msdn.com/martharotter/default.aspx"&gt;Marthas Blog&lt;/a&gt;.&lt;/i&gt;&lt;img src="http://blogs.msdn.com/aggbug.aspx?PostID=9927202" width="1" height="1"&gt;';
		temp = temp + '</description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';	
		temp = temp + '<item>';
		temp = temp + '<title>Life At Microsoft Part II</title>';
		temp = temp + '<link>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx</link>';
		temp = temp + '<pubDate>Mon, 23 Nov 2009 10:57:31 GMT</pubDate>';
		temp = temp + '<guid isPermaLink="false">7791d46819-8472-40ad-a661-2c78acb4018c:9927202</guid>';
		temp = temp + '<dc:creator>Martha Rotter</dc:creator>';
		temp = temp + '<slash:comments>0</slash:comments>';
		temp = temp + '<wfw:commentRss xmlns:wfw="http://wellformedweb.org/CommentAPI/">http://blogs.msdn.com/b/ireland/rsscomments.aspx?WeblogPostID=9927202</wfw:commentRss>';
		temp = temp + '<comments>http://blogs.msdn.com/b/ireland/archive/2009/11/23/life-at-microsoft-part-ii.aspx#comments</comments>';
		temp = temp + '<description></description>';
		temp = temp + '<category domain="http://blogs.msdn.com/b/ireland/archive/tags/Microsoft/">Microsoft</category>';
		temp = temp + '</item>	';									
		temp = temp + '</channel>';
		temp = temp + '</rss>';
		return temp;
	}
	private static string xmlDoc2(){
		string temp = '<feed xmlns="http://www.w3.org/2005/Atom">';
		temp = temp + '<title>App &amp; Service Listings on AppExchange</title>';
		temp = temp + '<id>http://sites.force.com/services/xml/NewListings</id>';
		temp = temp + '<updated>2010-10-22T13:14:02.603Z</updated>';
		temp = temp + '<author>';
		temp = temp + '<name>AppExchange</name>';
		temp = temp + '</author>';
		temp = temp + '<link rel="self" href="http://sites.force.com/services/xml/NewListings" />';
		temp = temp + '<entry>';
		temp = temp + '<title>isayso Net Promoter Surveys</title>';
		temp = temp + '<author>';
		temp = temp + '<name>isayso</name>';
		temp = temp + '</author>';
		temp = temp + '<updated>2010-10-21T00:00:00.000Z</updated>';
		temp = temp + '<link href="http://sites.force.com/appexchange/listingDetail?listingId=a0N30000001sbMrEAI" />';
		temp = temp + '<id>https://www.salesforce.com/a0N30000001sbMrEAI</id>';
		temp = temp + '<content type="text">A powerful survey tool that allows you to measure customer loyalty through your Net Promoter Score (NPS), using the simple question: “How likely are you to recommend us to others?”. Gather feedback in real time. No sensitive data leaves Salesforce!</content>';
		temp = temp + '</entry>';
		temp = temp + '<entry>';
		temp = temp + '<title>Contacts and Organizations for the Nonprofit Starter Pack</title>';
		temp = temp + '<author>';
		temp = temp + '<name>Salesforce.com Foundation</name>';
		temp = temp + '</author>';
		temp = temp + '<updated>2010-10-21T00:00:00.000Z</updated>';
		temp = temp + '<link href="http://sites.force.com/appexchange/listingDetail?listingId=a0N30000003GLGAEA4" />';
		temp = temp + '<id>https://www.salesforce.com/a0N30000003GLGAEA4</id>';
		temp = temp + '<content type="text">The Nonprofit Starter Pack is a set of customizations to Salesforce.com CRM that supports some common nonprofit business processes. This package supports the concept of Individuals, and allows for easy donation tracking.</content>';
		temp = temp + '</entry>';
		temp = temp + '<entry>';
		temp = temp + '<title>RapidiOnline for MS Dynamics AX</title>';
		temp = temp + '<author>';
		temp = temp + '<name>Rapidi S.A.R.L</name>';
		temp = temp + '</author>';
		temp = temp + '<updated>2010-10-20T00:00:00.000Z</updated>';
		temp = temp + '<link href="http://sites.force.com/appexchange/listingDetail?listingId=a0N30000003HlOeEAK" />';
		temp = temp + '<id>https://www.salesforce.com/a0N30000003HlOeEAK</id>';
		temp = temp + '<content type="text">RapidiOnline is an on-demand integration service that enables you to seamlessly integrate Salesforce and MS Dynamics AX (Axapta) in a cost-effective and straightforward manner. With our pre-configured service you will be up-and-running in no time.</content>';
		temp = temp + '</entry>';
		temp = temp + '</feed>';
		return temp;
	}	
}