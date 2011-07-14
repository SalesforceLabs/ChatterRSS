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
public with sharing class RSS2Chatter_AssociateObjectController {
    
    public String objectType {get; set;}
    public String searchTerm {get; set;}
    public List<SelectOption> selectObjects {get;set;}
    public String selectedItem {get;set;}
    public List<sObjectWrapper> sObjectsList {get;set;}
    public String removedItem {get;set;}
    public Integer recordCount {get; set;}
    private string rssId = '';
    public Boolean showResults {get{return recordCount>0;} set;}
    
    public RSS2Chatter_AssociateObjectController(apexpages.standardController con){
        apexpages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'This screen allows you to search for the objects you wish to associate the rss feed to. Use the search area of the screen to find the objects you want to associate the feed with.');
        apexpages.addMessage(msg);
        recordCount = -1;
        RSS_Feed__c r = (RSS_Feed__c) con.getRecord();
        rssId = r.Id;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        if (selectObjects == null) {
            selectObjects = new List<SelectOption>();
        }
        for (Schema.SObjectType sObjType: gd.values()) {
            Schema.DescribeSObjectResult result = sObjType.getDescribe();
            if (result.isFeedEnabled()) {
                selectObjects.add(new SelectOption(result.getName(),result.getLabel()));
            }
        }
    }
    
    public pageReference searchfor(){
        if(searchTerm == ''){
            apexpages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter some search criteria');
            apexpages.addMessage(msg);
            return null;
        }
        if(selectedItem == null){
            apexpages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'You need to select object first');
            apexpages.addMessage(msg);
            return null;
        }
        sObjectsList = new List<sObjectWrapper>();
        searchTerm = '%' + searchTerm + '%';
        String query = ''; 
        System.debug('!!!' + selectedItem);
        if (selectedItem == 'Case') {
            query = 'SELECT id,CaseNumber FROM ' + selectedItem + ' WHERE CaseNumber like : searchTerm';
        } else if (selectedItem == 'ContentDocument') {
            query = 'SELECT id,Title FROM ' + selectedItem + ' WHERE Title like : searchTerm';
        } else {
            query = 'SELECT id,Name FROM ' + selectedItem + ' WHERE Name like : searchTerm';
        }
        List<sObject> listObjects = Database.Query(query);
        
        for (sObject sObj: listObjects) {
            String objName = '';
            if (sObj.getsObjectType().getDescribe().getLabel() != 'Case') {
                objName = (String)sObj.get('Name');
            } else {
                objName = (String)sObj.get('CaseNumber');
            }
            sObjectWrapper sObjWrapper = new sObjectWrapper(sObj,objName);
            sObjectsList.add(sObjWrapper);
            objectType = sObj.getsObjectType().getDescribe().getLabel();
        }
        recordCount = sObjectsList.size();
        apexpages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Found ' + recordCount + ' matching records. Check the ' + objectType + ' records you would like to associate with the rss feed and then click "Add To Related Objects".');
        apexpages.addMessage(msg);
        
        searchTerm = '';
        return null;
    }
    public PageReference assignObjects() {
        List<RSS_Feed_Related_Object__c> newObjects = new List<RSS_Feed_Related_Object__c>();
        for(sObjectWrapper sObjWrapper : sObjectsList){
            if (sObjWrapper.Checked){
                RSS_Feed_Related_Object__c ro = new RSS_Feed_Related_Object__c();
                objectType = sObjWrapper.theobject.getSObjectType().getDescribe().getLabel();
                ro.RelatedObjectType__c = objectType;
                ro.RelatedObjectName__c = sObjWrapper.Name;
                String objectId = sObjWrapper.theobject.Id;
                ro.RelatedObjectId__c = objectId.substring(0,objectId.length() -3 );
                ro.RSS_Feed__c = rssId;
                if(objectType =='account'){
                    ro.Account__c = sObjWrapper.theobject.Id;
                } else if(objectType =='campaign'){
                    ro.Campaign__c = sObjWrapper.theobject.Id;
                } else if(objectType =='opportunity'){
                    ro.Opportunity__c = sObjWrapper.theobject.Id; 
                }
                newObjects.add(ro);
            }
        }
        if (newObjects.size() > 0 ){
            insert(newObjects);
        }
        recordCount = -1;
        sObjectsList = new List<sObjectWrapper>();
        return null; 
    }
    
    public List<RSS_Feed_Related_Object__c> relatedObjects
    {
        get
        {
            relatedObjects = new List<RSS_Feed_Related_Object__c>();
            
            relatedObjects = [SELECT Id,Name,RelatedObjectType__c,RelatedObjectName__c,RelatedObjectId__c  FROM RSS_Feed_Related_Object__c WHERE RSS_Feed__c=:rssId];
            return relatedObjects;
        }
        set;
    }
    
    public PageReference removeItem() {
        RSS_Feed_Related_Object__c removedRelObj = [Select Id,Name FROM RSS_Feed_Related_Object__c WHERE id=: removedItem];
        delete removedRelObj;
        return null;
    }
    public class sObjectWrapper{
        public sObject theObject {get;set;}
        public Boolean checked {get;set;}
        public String Name {get;set;}
        public sObjectWrapper(sObject o,String Name) {
            theObject = o;
            checked = false;
            this.Name = Name;
        }
    }
}