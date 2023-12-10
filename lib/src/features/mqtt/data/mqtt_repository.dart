import 'dart:developer';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttCurrentConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  errorWhenConnecting,
}

enum MqttSubscriptionState {
  idle,
  subscribed,
}

class MqttRepository {
  late MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.idle;
  late MqttSubscriptionState subscriptionState = MqttSubscriptionState.idle;
  late MqttServerClient _client;

  MqttServerClient initializeMqttClient(String host, int port, String identifier) {
    final MqttConnectMessage connectMessage =
        MqttConnectMessage().withClientIdentifier(identifier);

    _client = MqttServerClient.withPort(host, identifier, port);
    _client.logging(on: true);
    _client.keepAlivePeriod = 20;
    _client.secure = true;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
    _client.connectionMessage = connectMessage;

    return _client;
  }

  Future<void> connectClient(MqttServerClient client, String username, String password) async {
    try {
      log('connecting...');
      await _client.connect(username, password);
      log('Client connected!');
    } catch (e) {
      log('oups ... disconnecting');
      _client.disconnect();
    }
  }

  void subscribeToTopic(MqttClient client, String topicName) {
    _client.subscribe(topicName, MqttQos.atMostOnce);
  }

  void publishMessage(String topic, MqttQos qos, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    if (message.isNotEmpty) {
      builder.addString(message);
      final payload = builder.payload;
      _client.publishMessage(topic, qos, payload!, retain: true);
    }
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.connected;
    log('onConnected:: client connected');
    // onConnectedCallback();
  }

  void _onDisconnected() {
    connectionState = MqttCurrentConnectionState.disconnected;
    log('onDisconnected:: client disconnected');
  }

  void _onSubscribed(String topic) {
    subscriptionState = MqttSubscriptionState.subscribed;
  }
}
