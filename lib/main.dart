import 'package:firefighter/model/sensor_data.dart';
import 'package:flutter/material.dart';
import 'package:firefighter/service/mqtt_client.dart';
import 'package:firefighter/page/home_page.dart';
import 'package:firefighter/page/statistic_page.dart';
import 'package:firefighter/database/db_helper.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  MyHomePageState createState() => new MyHomePageState();

}

class MyHomePageState extends State<MyHomePage> {
  DbHelper dbHelper = DbHelper();
  int _curIndex = 0;
  MqttClientService service;
  HomePage homePage;

  @override
  void initState() {
    super.initState();
    dbHelper.initDb();
    service = MqttClientService(dbHelper);
    service.connect();
    homePage = HomePage(service, dbHelper);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
          onTap: (index) {
            setState(() {
              _curIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.black54,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                    color: Colors.black54
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.show_chart,
                color: Colors.black54,
              ),
              title: Text(
                'History',
                style: TextStyle(
                    color: Colors.black54
                ),
              ),
            ),
            
          ]),
      body: _getWidget()
    );
  }

  Widget _getWidget() {
    switch (_curIndex) {
      case 0:
        return Container(
          child: homePage,
        );
        break;
      default:
        return Container(
          child: StatisticPage(dbHelper),
        );
        break;
    }
  }

  @override
  void dispose() {
    service.disconnect();
    super.dispose();
  }
}
