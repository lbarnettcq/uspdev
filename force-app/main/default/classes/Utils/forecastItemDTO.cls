global with sharing class forecastItemDTO {
    @AuraEnabled global Id id { get; set; }
    @AuraEnabled global String name { get; set; }
    @AuraEnabled global Decimal progress { get; set; }

    global forecastItemDTO(ForecastingFact record) {
        this.id = record.Id;
        this.name = 'Forecasted Sale';
        this.progress = record.ForecastingItem.ForecastAmount;
    }

    global forecastItemDTO() {
        this.id = null;
        this.name = 'Forecasted Sale';
        this.progress = 0;
    }
}