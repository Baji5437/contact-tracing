({
	fetchStatusCount : function(component) {
		const scope = component.get("v.scope");
		
		let action = scope === "person" ? component.get("c.getPeopleHealthStatusCount") : component.get("c.getLocationHealthStatusCount");

		action.setCallback(this,function(response){
			const state = response.getState();

			if (state === "SUCCESS") {
                component.set("v.count", response.getReturnValue());
            }
		});
		
		$A.enqueueAction(action);
	}
})