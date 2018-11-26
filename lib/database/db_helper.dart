import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firefighter/model/sensor_data.dart';

class DbHelper {
  static String SENSOR_TABLE = 'sensors';
  static String SENSOR_ID = 'id';
  static String SENSOR_FLAME = 'flame';
  static String SENSOR_CO2 = 'ppm_co2';
  static String SENSOR_METHANE = 'ppm_methane';
  static String SENSOR_TIME = 'time';
  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  //Creating a database with name test.dn in your directory
  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "firefighter.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // Creating a table name Employee with fields
  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE IF NOT EXISTS ${SENSOR_TABLE}(${SENSOR_ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
            "${SENSOR_FLAME} INTEGER, ${SENSOR_CO2} INTEGER, ${SENSOR_METHANE} INTEGER,"
            "${SENSOR_TIME} TEXT);");
    print("Tables created");
  }

  // Retrieving employees from Employee Tables
  Future<List<SensorData>> getSensorData() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM ${SENSOR_TABLE}');
    List<SensorData> sensorData = new List();
    for (int i = 0; i < list.length; i++) {
      sensorData.add(new SensorData.withData(list[i][SENSOR_FLAME] == 1 ? true : false,
          list[i][SENSOR_CO2], list[i][SENSOR_METHANE], list[i][SENSOR_TIME]));
    }
    print(sensorData.length);
    return sensorData;
  }

  Future<int> saveEmployee(SensorData sensorData) async {
    var dbClient = await db;
    sensorData.id = await dbClient.insert(SENSOR_TABLE, sensorToMap(sensorData));
    return sensorData.id;
  }

  Future<void> close() async {
    var dbClient = await db;
    dbClient.close();
  }

  Map<String, dynamic> sensorToMap(SensorData sensorData) {
    var map = <String, dynamic>{
      SENSOR_FLAME: sensorData.flame,
      SENSOR_CO2: sensorData.ppmCo2,
      SENSOR_METHANE: sensorData.ppmMethane,
      SENSOR_TIME: sensorData.time
    };
    return map;
  }
}