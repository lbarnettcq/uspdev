public with sharing class AccuracyAndTargetEOPSchedulable implements Schedulable {
    public void execute(SchedulableContext context) {
        AccuracyAndTargetCalculator.Execute(
                AccuracyAndTargetCalculator.Mode.EndOfPeriod,
                AccuracyAndTargetCalculator.State.Standard
        );
    }
}