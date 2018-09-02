({
    
	doInit : function(cmp, evt, helper) {
        //moved logic to helper to ensure order of execution
		var quoteId = cmp.get('v.quoteId');
        helper.getIsBin(cmp, evt, quoteId);
	},

    sendEmail: function(cmp,evt,helper){
        var apexMethod = cmp.get('c.emailPDF');
        var quoteId = cmp.get('v.quoteId');
        var emailId = cmp.get('v.emailId');
        var pdfData = cmp.get('v.pdfData');
        
       
        
        //added email body
        var emailBody = cmp.get('v.emailBody');
        apexMethod.setParam('quoteId',quoteId);
        apexMethod.setParam('emailId',emailId);
        apexMethod.setParam('pdfData',pdfData);
        //added email body
        apexMethod.setParam('emailBody', emailBody);
        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                if(ret.success){
                    //helper.fireEmailSuccessToast();
                    alert(ret.message);
                }else{
                    alert(ret.message);
                    console.log('Error' , ret.message)
                }
            } else {
                console.log('Error', response.getError());
                throw new Error('Error: ', response.getError());
            }
        });
        $A.enqueueAction(apexMethod);
    },

    saveQuote:function(cmp,evt,helper){

        var apexMethod = cmp.get('c.savePDF');
        var quoteId = cmp.get('v.quoteId');
        var pdfData = cmp.get('v.pdfData');
        apexMethod.setParam('quoteId',quoteId);
        apexMethod.setParam('pdfData',pdfData);
        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                if(ret.success){
                    //Navigate to Quote
                    // Change made on June something
                    var url = '/' + quoteId;
                    //var url = '/lightning/r/Quote/' + quoteId;
                    if((typeof sforce!='undefined')&&(sforce!=null)){
                        sforce.one.navigateToURL(url);
                    }else{
                        try{
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                    "url": url
                            });
                            urlEvent.fire();
                        }catch(e){
                            window.location.href=url;
                        }
                    }
                }else{
                    console.log('Error' , ret.message)
                    throw new Error('Error: ', ret.message);
                }
            } else {
                console.log('Error', response.getError());
                throw new Error('Error: ', response.getError());
            }
        });
        $A.enqueueAction(apexMethod);

    }
})