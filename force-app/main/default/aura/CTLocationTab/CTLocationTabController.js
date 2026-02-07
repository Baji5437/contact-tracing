({
    locationSearchHandler : function(component, event, helper) {
        helper.fetchLocationInformation(component);
    },

    doInit : function(component,event,helper){
        const columns =[
           {label:"Name",fieldName:"personName",type:"text"},
           {label:"Token",fieldName:"personToken",type:"text"},
           {label:"Visitor Health Status",fieldName:"personHealthStatus",type:"text"},
           {label:"Visit Date",fieldName:"visitDate", type:"date"}
        ]
        component.set("v.columns", columns);
    }
})