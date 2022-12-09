public with sharing class opportunityPathController
{
    private ApexPages.StandardController controller;
    public String currentStage { get; set; }
    public Opportunity opp {get; set;}
    public String allStages { get; set; }

    public opportunityPathController(ApexPages.StandardController controller)
    {
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
        this.opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :this.opp.Id];
        this.currentStage = this.opp.StageName;

        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();

        allStages = '';

        for (Schema.PicklistEntry plEntry: pList)
        {
            if (plEntry.label == 'Closed Lost') { continue; }
            if (allStages != '') { allStages += ','; }
            allStages += plEntry.label;
        }
    }
}