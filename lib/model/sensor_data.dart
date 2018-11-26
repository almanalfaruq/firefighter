import 'dart:convert';

class SensorData {
  String jsonData;

  int id;
  bool flame = false;
  int ppmCo2 = 0;
  int ppmMethane = 0;
  String time = '';

  SensorData();

  SensorData.withData(this.flame, this.ppmCo2, this.ppmMethane, this.time);

  SensorData.decodeFromJson(this.jsonData) {
    var data = jsonDecode(jsonData);
    print(data.toString());
    flame = data['payload_fields']['flame'].toString() == '0' ? false : true;
    ppmCo2 = int.parse(data['payload_fields']['ppm_co2'].toString());
    ppmMethane = int.parse(data['payload_fields']['ppm_methane'].toString());
    time = data['metadata']['time'].toString();
  }

}