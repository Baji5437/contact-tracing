({
    fetchRecentHealthChanges : function(component) {
        const scope = component.get("v.scope");
        let action = scope === "person" ? component.get("c.getPersonRecentHealthChanges") : component.get("c.getLocationRecentHealthChanges");

        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === "SUCCESS"){
                const data = response.getReturnValue();
                component.set("v.data",data);
                component.set("v.initialResponse",data);
            }
        });

        $A.enqueueAction(action);
    },

    searchRecord : function(component,queryTerm){
        const scope = component.get("v.scope");
        let action = scope === "person" ? component.get("c.searchPeople") : component.get("c.searchLocations");
        action.setParams({
              searchTerm : queryTerm
        });

        action.setCallback(this,function(response){
            const state = response.getState();
            if(state === "SUCCESS"){
                const data = response.getReturnValue();
                if(data && data.length >0){
                    component.set("v.data", data);
                }
                component.set("v.issearching", false);
            }
        });

        $A.enqueueAction(action);
    }
})