import 'package:firefighter/database/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:firefighter/fonts/my_flutter_app_icons.dart';
import 'package:firefighter/model/sensor_data.dart';
import 'package:firefighter/service/mqtt_client.dart';

class HomePage extends StatefulWidget {
  MqttClientService service;
  DbHelper dbHelper;

  HomePage(this.service, this.dbHelper);

  @override
  _HomePageState createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {

  SensorData _sensorData = SensorData();

  void callback(SensorData sensorData) {
    if (mounted) {
      setState(() {
        _sensorData = sensorData;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.service.setCallback(callback);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Status'),
      ),
      body: _sensorData.ppmCo2 == 0 ? _futureBuilder() : _createWidget(),
    );
  }

  Widget _createWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Column(
              children: createFireStatusWidget(_sensorData)
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Flame: ${_sensorData.flame}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Text(
                'CO2: ${_sensorData.ppmCo2}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Text(
                'Methana: ${_sensorData.ppmMethane}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              )
            ],
          )
        ],
      ),
    );
  }

  FutureBuilder _futureBuilder() {
    return FutureBuilder(
      future: widget.dbHelper.getSensorData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Text('Loading');
          default:
            return _createWidgetFuture(snapshot);
        }
      },
    );
  }

  Widget _createWidgetFuture(AsyncSnapshot snapshot) {
    List<SensorData> sensorDataList = snapshot.data;
    SensorData sensorData = SensorData();
    if (sensorDataList.length > 0) {
      sensorData = sensorDataList.last;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 30.0),
            child: Column(
              children: createFireStatusWidget(sensorData)
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Flame: ${sensorData.flame}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Text(
                'CO2: ${sensorData.ppmCo2}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              ),
              Text(
                'Methana: ${sensorData.ppmMethane}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
              )
            ],
          )
        ],
      ),
    );
  }

  List<Widget> createFireStatusWidget(SensorData sensorData) {
    return [
      Icon(
          MyFlutterApp.fire,
          size: 100.0,
          color: sensorData.ppmCo2 > 5000 ? Colors.red : Colors.black
      ),
      Text(
        sensorData.ppmCo2 > 5000
            ? 'Kebakaran' : 'Tidak Kebakaran',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: sensorData.ppmCo2 > 5000 ? Colors.red : Colors.black
        ),
      ),
    ];
  }
}