public with sharing class S1QuotePDFController {
    public S1QuotePDFController(ApexPages.StandardController sc) {	}
    
    //create new PDF with template method
    @AuraEnabled
    public static String getPDFData(String quoteId){
        returnMessage ret = new returnMessage();
        ret.success = false;
        List<S1QuotePDFSettings__mdt> tsList = [SELECT Value__c FROM S1QuotePDFSettings__mdt WHERE 	Label ='Template ID'];
        S1QuotePDFSettings__mdt ts = new S1QuotePDFSettings__mdt();
        if(tsList.size()>0){
            ts = tsList[0];
            System.debug(ts);
        }
        try{
            ret.success=true;

            String pdfURL = '/quote/quoteTemplateDataViewer.apexp?id='+quoteId+'&summlid='+ts.Value__c;
            
            System.debug(pdfURL);
            PageReference pdf = new PageReference(pdfURL);
            System.debug(pdf);
            
            system.debug(pdf.getContent());
            
            String b64 = EncodingUtil.base64Encode(pdf.getContent()); 
            
            System.debug(b64);
            ret.email = getEmailAddress(quoteId);
            ret.message = b64;
        }catch(Exception e){
            ret.message = JSON.serialize(e.getMessage());
        }
        System.debug('Serialized');
        System.debug(ret.message);
        return JSON.serialize(ret);
    }
    
    //Static Viewer Method
    @AuraEnabled
    public static String getStaticPDFData(String quoteId){
        returnMessage ret = new returnMessage();
        ret.success = false;
        try{
            ret.success=true;
            QuoteDocument qd = [SELECT Id, Document FROM QuoteDocument WHERE Id = :quoteId LIMIT 1]; 
            
            System.debug(qd);
            ret.email = getEmailAddress(quoteId);
            System.debug('Quote ID : ' + quoteId);
            ret.message= EncodingUtil.base64Encode(qd.Document);
            System.debug(ret.message);
        } catch(exception e){
            ret.message = JSON.serialize(e.getMessage());
        }
        return JSON.serialize(ret);
    }
    
    @AuraEnabled
    public static String emailPDF(String quoteId, String emailId, String pdfData, String emailBody){
        returnMessage ret = new returnMessage();
        ret.success = false;
                
        // Blob and decode the pdf
        Blob newBlob = Blob.toPdf(pdfData);
        newBlob = EncodingUtil.base64Decode(pdfData);
        
        
        // Create the email file attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('attachment.pdf');
        efa.setBody(newBlob);
        
        //Implement send email logic here..
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        // Create email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        //Create mailing list
        String[] emailList = emailId.split(',');
        for(String address : emailList){
            address.trim();
        }
        mail.setToAddresses(emailList);
        
        // Set who its from
        
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(UserInfo.getName());
        
        // Set email contents
        mail.setSubject('Quote PDF');
        if(getIsBin(quoteId)){
            QuoteDocument qd = [SELECT Id, QuoteId FROM QuoteDocument WHERE Id = :quoteId];
            quoteId = qd.QuoteId;
        } 
        Quote theQuote = [SELECT Id, Name, Opportunity.Name, Opportunity.Account.Name FROM Quote WHERE Id = :quoteId LIMIT 1];
        //Edit the following string to change the email body
        //String body = 'Attached is the PDF regarding the opportunity ' + theQuote.Opportunity.Name + ' for ' + theQuote.Opportunity.Account.Name + '.' ;
        String body = emailBody;
        mail.setHtmlBody(body);
        
        // add email to the master list
        mails.add(mail);
        
        // Send it
        try{
            Messaging.sendEmail(mails);
            ret.message = 'Email Sent Successfully';
            ret.success=true;
        } catch(Exception e){
            ret.message = JSON.serialize(e.getMessage());
            ret.success = false;
        }
        
        
        
        // end email logic
        
        
        return JSON.serialize(ret);
        
    }
    
    @AuraEnabled
    public static String savePDF(String quoteId, String pdfData){
        returnMessage ret = new returnMessage();
        ret.success = false;
        
        try{
            Quote q = [Select Name from Quote where id=:quoteId];
            QuoteDocument qd = new QuoteDocument();
            qd.document = EncodingUtil.base64Decode(pdfData);
            qd.quoteId = quoteId;
            insert qd;	
            ret.success = true;
        }catch(Exception e){
            ret.message = e.getMessage();
        }
        
        return JSON.serialize(ret);
    }
    
    private class returnMessage{
        public Boolean success{get;set;}
        public String message{get;set;}
        public String email{get;set;}
    }
    
    //Determines if we're being passed the ID for a Quote or QuoteDocument
    @AuraEnabled
    public static Boolean getIsBin(String Id){
        QuoteDocument[] docs = [SELECT Id FROM QuoteDocument WHERE Id = :Id];
        if(docs.size() > 0){
            return true;
        } else {
            return false;
        }
    }
    
    //Takes a quote or QuoteDocument ID and returns the primary contact's email address
    public static String getEmailAddress(String theId){
        String quoteId;
        if(getIsBin(theId)){
            QuoteDocument qd = [SELECT Id, QuoteId FROM QuoteDocument WHERE Id = :theId];
            quoteId = qd.QuoteId;
        } else {
            quoteId = theId;
        }
        try{
            Quote theQuote = [SELECT ContactId FROM Quote WHERE Id = :quoteId LIMIT 1];
            Contact theContact = [SELECT Email FROM Contact WHERE Id = :theQuote.ContactId Limit 1];
            return theContact.Email;
        } catch (Exception e){
            System.Debug(e);
            return '';
        }
    }
    
}