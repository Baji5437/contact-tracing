({
    fetchLocationInformation : function(component) {

        const recordId = component.get("v.recordId");

        let action = component.get("c.getLocationDetails");
        action.setParams({
            recordId : recordId
        })
        action.setCallback(this, function(response){
            const state = response.getState();

            if(state === "SUCCESS"){
                const resp = response.getReturnValue();

                if(!resp || !resp.name){
                    component.set("v.locationFound",false);
                    this.showToast("ERROR","Please enter valid record id","error");
                }
                else{
                    component.set("v.locationFound",true);
                    component.set("v.locationInfo",resp);
                    console.log('response',resp);
                    console.log('locationInfo',component.get("v.locationInfo"));
                }
            }
            else{
                component.set("v.locationFound",false);
                this.showToast("ERROR","Please enter valid record id","error");
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(title,message,type){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})