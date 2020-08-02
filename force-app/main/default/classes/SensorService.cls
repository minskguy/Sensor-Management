@RestResource(urlMapping = '/Sensors')
global class SensorService {

    private class ImputData {
        String sensorid;
        Integer[] line;
    }

    @HttpPut
    global static void putData() {

        RestRequest request = RestContext.request;
        ImputData sensorData= (ImputData) JSON.deserialize(request.requestBody.toString(),ImputData.class);
        //sensorid = (String) sensorData.get('sensorid');
        //line = (Integer[]) sensorData.get('line');

        List<Sensor__c> foundedSensor = [SELECT Name FROM Sensor__c WHERE Name =: sensorData.sensorId LIMIT 1];
        Sensor__c sensor;

        if(foundedSensor.size() == 0) {
            sensor = new Sensor__c(Name = sensorData.sensorId);
            insert sensor;
        } else {
            sensor = foundedSensor[0];
        }

        List<Sensor_Event__c> events = new List<Sensor_Event__c>();
        Integer lastVectorCoordinatesIndex;
        
        lastVectorCoordinatesIndex = Math.mod(sensorData.line.size(), 3) == 0 ? 
            sensorData.line.size() - 3 : sensorData.line.size()  - Math.mod(sensorData.line.size(), 3) - 3;
        for(Integer i = 0; i <= lastVectorCoordinatesIndex; i += i + 3) {
            Sensor_Event__c newEvent = new Sensor_Event__c();
            newEvent.x__c = sensorData.line[i];
            newEvent.y__c = sensorData.line[i + 1];
            newEvent.z__c = sensorData.line[i + 2];
            newEvent.Sensor__c = sensor.Id;
            events.add(newEvent);
        }
        insert events;

        for(Integer i = 1; i < events.size(); i++) {
            events[i].Previous_Event__c = events[i - 1].Id;
        }
        upsert events;
    }
}