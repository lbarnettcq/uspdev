public with sharing class AccuracyAndTargetSOPSchedulable implements Schedulable {
    public void execute(SchedulableContext context) {
        AccuracyAndTargetCalculator.Execute(
                AccuracyAndTargetCalculator.Mode.StartOfPeriod,
                AccuracyAndTargetCalculator.State.Standard
        );
    }
}