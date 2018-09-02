({
	doInit : function(component, event, helper) {
		var apexMethod = component.get("c.getMyQuote");
        apexMethod.setParams({
            "quoteId" : component.get("v.recordId"), 
        });
        apexMethod.setCallback(this, function(response){
           var state = response.getState();
           if (state === "SUCCESS") {
	          component.set("v.myQuote", response.getReturnValue());
	       }
        });
        $A.enqueueAction(apexMethod);
	}
})