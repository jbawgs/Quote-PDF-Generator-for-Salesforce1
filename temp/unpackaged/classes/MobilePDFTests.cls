@isTest(SeeAllData=true)
public class MobilePDFTests {
    
    /*
     * These tests depend on the org already containing at least one quote, and one quote document.
     * 
    */
    
    //test S1QuotePDFController.apxc
    @isTest public static void S1QuotePDFControllerTest(){
		//Setup some data
		Opportunity testOpp = new Opportunity();
		testOpp.name = 'Test';
		testOpp.CloseDate = Date.today() + 10;
        testOpp.StageName = 'Prospecting';
        insert testOpp;
        Quote theQuote = new Quote();
        theQuote.OpportunityId = testOpp.Id;
        theQuote.Name = 'Test';
        insert theQuote;
        QuoteDocument theDocument = new QuoteDocument();
        theDocument.QuoteId = theQuote.Id;
        theDocument.Document = Blob.toPdf('test 123');
        String aPDF = somePDFData(theDocument);
        
        
        //run methods
        String pdfData = S1QuotePDFController.getPDFData(theQuote.Id);
        returnMessage pdfDataRM = (returnMessage)JSON.deserialize(pdfData, returnMessage.class);
        System.Debug(pdfDataRM);
        String pdfBin = S1QuotePDFController.getStaticPDFData(theDocument.Id);
        returnMessage pdfBinRM = (returnMessage)JSON.deserialize(pdfBin, returnMessage.class);
        System.debug(pdfBinRM);
        String pdfEmail = S1QuotePDFController.emailPDF(theQuote.Id, 'test@things.com', aPDF, 'test123');
        returnMessage pdfEmailRM = (returnMessage)JSON.deserialize(pdfEmail, returnMessage.class);
        System.debug(pdfEmailRM);
        String pdfSave = S1QuotePDFController.savePDF(theQuote.Id, aPDF);
        returnMessage pdfSaveRM = (returnMessage)JSON.deserialize(pdfSave, returnMessage.class);
        System.debug(pdfSaveRM);
        String emailAddress = S1QuotePDFController.getEmailAddress(theQuote.Id);
        System.debug(emailAddress);
        
        //testing page reference stuff...doesn't work right now
        PageReference pageRef = Page.S1QuotePDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',theQuote.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(theQuote);
        S1QuotePDFController sqp = new S1QuotePDFController(sc);

        
        
        
        
        //Assertions
        System.assertEquals(true, pdfDataRM.success);
        System.assertEquals(true, pdfBinRM.success);
        System.assertEquals(true, pdfEmailRM.success);
        System.assertEquals(true, pdfSaveRM.success);
    }
    
    //Test QuoteListComponentController.apdc
    @isTest public static void QuoteListComponentControllerTest(){
        Quote theQuote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('Id', theQuote.Id);
        ApexPages.StandardController stdQuote = new ApexPages.StandardController(theQuote);
        QuoteListComponentController listQuoteDoc = new QuoteListComponentController(stdQuote);
    }
    
    
    //Helper to pass PDF data to test
    public static String somePDFData(QuoteDocument qd){
        return EncodingUtil.base64Encode(qd.Document);
    }
    
    //Struct for deserializing return data
    private class returnMessage{
        public Boolean success{get;set;}
        public String message{get;set;}
        public String email{get;set;}
    }
    
    
}