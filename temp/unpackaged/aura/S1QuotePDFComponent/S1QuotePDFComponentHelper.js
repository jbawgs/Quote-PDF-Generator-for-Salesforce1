({
    helperMethod : function() {
    },
    //Determines if the PDF to be displayed is a new quote PDF or an existing
    getIsBin : function(component, event, Id) {
        var apexMethod = component.get("c.getIsBin");
        apexMethod.setParam("Id", Id);
        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var isBin = response.getReturnValue();                
                component.set("v.isBin", isBin);
                //retrieve || create pdf data
                this.doApex(component, Id);                
            }
        });
        $A.enqueueAction(apexMethod);
    },
    doApex : function(cmp, quoteId){
        
        var apexMethod = cmp.get('c.getPDFData');
        var isBin = cmp.get('v.isBin');
        console.log('valueof isBin: ' + isBin);
        //If loading an existing PDF, call the getStaticPDFData method instead
        if(isBin){
            apexMethod = cmp.get('c.getStaticPDFData');
            var saveButton = cmp.find("saveButton");
            $A.util.toggleClass(saveButton, "slds-hide");
            console.log('Apex Method Reassigned');
        }
        apexMethod.setParam('quoteId',quoteId);
        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var ret = JSON.parse(response.getReturnValue());
                if(ret.success){
                    var spinner = cmp.find("_spinner");
                    //assign contact email
                    cmp.set("v.emailId", ret.email);
                    $A.util.toggleClass(spinner, "slds-hide");                   
                    var pdfData = ret.message;
                    cmp.set('v.pdfData',pdfData);
                    //Create the PDF viewer component
                    $A.createComponent(
                        "c:pdfViewer",
                        {
                            "pdfData": pdfData
                        },
                        function(pdfViewer, status, errorMessage){
                            if (status === "SUCCESS") {
                                var pdfContainer = cmp.get("v.pdfContainer");
                                pdfContainer.push(pdfViewer);
                                cmp.set("v.pdfContainer", pdfContainer);
                            }
                            else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                                throw new Error("No response from server or client is offline.");
                            }
                                else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    throw new Error("Error: " + errorMessage);
                                }
                        }
                    );
                }else{
                    console.log(ret.message)
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(apexMethod);
    },
    
    
    
    fireEmailSuccessToast: function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "SUCCESS!",
            message: "PDF successfully mailed.",
            type: "success"
        });
        toastEvent.fire();
    }
})