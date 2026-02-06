({
    fetchUserInformation : function(component) {
        const recordId = component.get("v.recordId");
        let action = component.get("c.getPersonDetails");

        action.setParams({
            personId : recordId
        })

        action.setCallback(this, function(response){
            const state = response.getState();

            if(state === "SUCCESS"){
                const resp = response.getReturnValue();
                //check if user is found
                if(!resp || !resp.name){
                    component.set("v.userFound", false);
                    this.showToast("ERROR","Please enter valid record id","error");
                }
                else{
                    // user found
                    component.set("v.userFound", true);
                    component.set("v.userInfo", resp);
                }
            }
            else {
                component.set("v.userFound", false);
                this.showToast("ERROR", "Please enter valid record id", "error");
            }
        });

        $A.enqueueAction(action);

    },

    showToast: function (title, message, type) {
        
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title,
            message,
            type
        });
        toastEvent.fire();
    }
})