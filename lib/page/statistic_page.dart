import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:firefighter/database/db_helper.dart';
import 'package:firefighter/model/sensor_data.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  DbHelper dbHelper;
  StatisticPage(this.dbHelper);

  @override
  _StatisticPageState createState() => _StatisticPageState();

}

class _StatisticPageState extends State<StatisticPage> {
  DbHelper dbHelper;
  List<Series> series;

  static var formatter = new DateFormat('yyyy-MM-dd\njj:mm:ss');

  String splitToDateFormat(String dateTimeToSplit) {
    List<String> stringDateTime = dateTimeToSplit.split('T');
    List<String> stringTime = stringDateTime[1].split('.');
    return '${stringDateTime[0]} ${stringTime[0]}';
  }

  DateTime parseStringToDateTime(String stringDateTime) {
    String dateTime = splitToDateFormat(stringDateTime);
    return DateTime.parse(dateTime).add(Duration(hours: 7));
  }

  /// Create one series with sample hard coded data.
  List<Series<SensorData, DateTime>> _createSampleData(List<SensorData> data) {
    return [
      new Series<SensorData, DateTime>(
        id: 'CO2',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (SensorData sensorData, _) => parseStringToDateTime(sensorData.time),
        measureFn: (SensorData sensorData, _) => sensorData.ppmCo2,
        data: data
      ),
      new Series<SensorData, DateTime>(
          id: 'Methana',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (SensorData sensorData, _) => parseStringToDateTime(sensorData.time),
          measureFn: (SensorData sensorData, _) => sensorData.ppmMethane,
          data: data
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    dbHelper = widget.dbHelper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistic'),
      ),
      body: FutureBuilder(
        future: dbHelper.getSensorData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              } else {
                return Container(
                    child: _createChart(snapshot),
                );
              }
          }
        },
      ),
    );
  }

  Widget _createChart(AsyncSnapshot snapshot) {
    series = _createSampleData(snapshot.data);
    return TimeSeriesChart(
      series,
      animate:
      true,
      dateTimeFactory: LocalDateTimeFactory(),
      behaviors: [SeriesLegend()],
    );
  }

}