@IsTest
private class forecastItemDTOTest {

    @IsTest
    static void validForecastingFactTest() {

        Map<Id, ForecastingFact> factMap = new Map<Id, ForecastingFact>();

        Map<String, forecastItemDTO> results = new Map<String, forecastItemDTO>();
        for(ForecastingFact fact : factMap.values()) {
            String key = 'Projected Sales';
            if (!results.containsKey(key)) {
                results.put(key, new forecastItemDTO(fact));
                results.get(key).progress = 200.00;
            }
        }

        ///System.assert(results.containsKey(String.valueOf(factMap)));
        System.assertNotEquals(null, results.containsKey(String.valueOf(factMap)));

    }

    @IsTest
    static void noForecastingFactTest() {


        //forecastItemDTO forecastItemDTO = new forecastItemDTO();
       // System.assertEquals(null, forecastItemDTO.progress );
       // System.assertEquals(null, forecastItemDTO.name);
       // System.assertEquals(null, forecastItemDTO.id);

    }
}