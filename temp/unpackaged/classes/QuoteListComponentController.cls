public with sharing class QuoteListComponentController {
    public QuoteDocument[] quoteDocuments {get; set;}
    Quote theQuote;
    
    public QuoteListComponentController(ApexPages.StandardController stdController) {
        this.theQuote = (Quote)stdController.getRecord();
        this.quoteDocuments = [SELECT Id, Name, CreatedDate FROM QuoteDocument WHERE QuoteId = :theQuote.Id ORDER BY CreatedDate DESC];
    }
    

}