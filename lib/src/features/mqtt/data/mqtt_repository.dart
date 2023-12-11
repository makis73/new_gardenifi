import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';

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
  MqttRepository(this.ref);
  final Ref ref;
  late MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.idle;
  late MqttSubscriptionState subscriptionState = MqttSubscriptionState.idle;
  late MqttServerClient _client;

  MqttServerClient initializeMqttClient(String host, int port, String identifier) {
    final MqttConnectMessage connectMessage =
        MqttConnectMessage().withClientIdentifier(identifier);

    _client = MqttServerClient.withPort(host, identifier, port);
    _client.logging(on: true);
    _client.keepAlivePeriod = 5;
    _client.secure = true;
    _client.onDisconnected = onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = _onSubscribed;
    _client.connectionMessage = connectMessage;
    _client.autoReconnect = false;

    return _client;
  }

  Future<void> connectClient(
      MqttServerClient client, String username, String password) async {
    try {
      await _client.connect(username, password);
    } on NoConnectionException catch (_) {
      // Raised by the client when connection fails.
      rethrow;
    } on SocketException catch (_) {
      // Raised by the socket layer
      rethrow;
    }
  }

  void disconnect(MqttServerClient client) {
    client.disconnect();
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
    print('APP:: onConnected:: client connected');
    // onConnectedCallback();
  }

  void onDisconnected() {
    connectionState = MqttCurrentConnectionState.disconnected;
    print('APP:: disconnected');
    ref.read(disconnectedProvider.notifier).state = true;
  }

  void _onAutoReconnect() {}

  void _onSubscribed(String topic) {
    subscriptionState = MqttSubscriptionState.subscribed;
  }
}

final repositoryProvider = Provider<MqttRepository>((ref) {
  return MqttRepository(ref);
});
