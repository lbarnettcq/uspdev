({
   init : function(cmp, e, h) {
       h.parseDynamic(cmp, e, h)
       cmp.set("v.ready", true);
   },

   selectProgress : function(cmp, e, h) {
       h.submitStatusChangeToServer(cmp, e, h);
   }
})