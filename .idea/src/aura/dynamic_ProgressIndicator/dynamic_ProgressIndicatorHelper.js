({
   parseDynamic : function(cmp, e, h) {
       let allStages = cmp.get("v.allStages");
       if (allStages === undefined) { return; }
       if (allStages === null) { return; }
       if (allStages === '') { return; }
       let stageSplit = allStages.split(",");
       cmp.set("v.stages", stageSplit);
       cmp.set("v.parsedDynamic", true);
   },

   submitStatusChangeToServer : function(cmp, e, h) {
       console.log("Something was clicked!");
       let clickedValue = e.getSource().get('value');
       console.log("Clicked value => "+clickedValue);
   }
});