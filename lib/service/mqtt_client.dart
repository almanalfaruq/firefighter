import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:firefighter/model/sensor_data.dart';
import 'package:firefighter/database/db_helper.dart';

class MqttClientService {

  final String server = 'asia-se.thethings.network';
  MqttClient _client;
  DbHelper dbHelper;

  Function callback;
  MqttClientService(this.dbHelper);

  Future<void> connect() async {
    String now = DateTime.now().toString();
    String clientId = Uuid().v1() + now;
    _client = MqttClient(server, clientId);
    _client.logging(on: false);
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.port = 1883;

    final MqttConnectMessage connMess = MqttConnectMessage();
    final String username = 'app_group03';
    final String password = 'ttn-account-v2.slNIml3ixbmTuOUd-liWmayW9TfWqDlYDGtpg8dKSTM';
    connMess.authenticateAs(username, password);
    connMess.withClientIdentifier(clientId);
    print('Mosquitto client connecting....');
    _client.connectionMessage = connMess;

    try {
      await _client.connect(username, password);
    } on Exception catch (e) {
      print('client exception - $e');
      _client.disconnect();
      return;
    }

    /// Check we are connected
    if (_client.connectionStatus.state == ConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          'ERROR Mosquitto client connection failed - disconnecting, status is ${_client.connectionStatus}');
      _client.disconnect();
      return;
    }

    /// Ok, lets try a subscription
    const String topic = '+/devices/+/up'; // Not a wildcard topic
    _client.subscribe(topic, MqttQos.atLeastOnce);
    print('Listening from server...');
    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String bodyJson = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('From server:');
      print('Topic: ${c[0].topic}');
      print('Payload: ${bodyJson}');
      dbHelper.saveEmployee(SensorData.decodeFromJson(bodyJson));
      callback(SensorData.decodeFromJson(bodyJson));
      print('');
    });
  }

  /// The subscribed callback
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
  }

  void disconnect() {
    _client.disconnect();
  }

  void setCallback(Function callback) {
    this.callback = callback;
  }
}