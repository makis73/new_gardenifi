import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/data/mqtt_repository.dart';

class MqttController extends StateNotifier<MqttReceivedMessage?> {
  MqttController(this.ref) : super(null);

  final mqttRepository = MqttRepository();
  MqttServerClient? client;
  late String hwId;
  final Ref ref;

  Future<void> setupAndConnectClient() async {
    final prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('mqtt_user') ?? '';
    final String password = prefs.getString('mqtt_pass') ?? '';
    final String host = prefs.getString('mqtt_host') ?? '';
    final int port = prefs.getInt('mqtt_port') ?? 0;

    client = mqttRepository.initializeMqttClient(host, port, indentifier);

    await mqttRepository.connectClient(client!, user, password);

    // TODO: Show a snackbar that connected to broker [onConnected]

    subscribeToTopics();
  }

  Future<void> loadHardwareId() async {
    final prefs = await SharedPreferences.getInstance();
    hwId = prefs.getString('hwId') ?? '';
  }

  String createTopicName(topic) {
    return '$baseTopic/$hwId/$topic';
  }

  void subscribeToTopics() async {
    await loadHardwareId();
    final status = createTopicName(statusTopic);
    final config = createTopicName(configTopic);
    final system = createTopicName(systemTopic);
    final valves = createTopicName(valvesTopic);

    mqttRepository.subscribeToTopic(client!, status);
    mqttRepository.subscribeToTopic(client!, config);
    mqttRepository.subscribeToTopic(client!, system);
    mqttRepository.subscribeToTopic(client!, valves);

    client!.updates!.listen((event) {
      state = event[0];
      final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
      final topic = event[0].topic;

      if (topic == valves) {
        final String tempMessage =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        final String replacedString = tempMessage.replaceAll('\'', '"');

        final List<String> mes = replacedString
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map<String>((e) {
          return e;
        }).toList();
        ref.read(valvesTopicProvider.notifier).state = mes;
      }

      if (topic == status) {
        final String tempMessage =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        final String replacedString = tempMessage.replaceAll('\'', '"');

        final Map<String, dynamic> mes = jsonDecode(replacedString);
        ref.read(statusTopicProvider.notifier).state = mes;
      }
    });
  }

  watchBroker(MqttServerClient client) {
    client.updates;
  }
}

// ------------> Providers <--------------
final mqttControllerProvider =
    StateNotifierProvider<MqttController, MqttReceivedMessage?>((ref) {
  return MqttController(ref);
});

final valvesTopicProvider = StateProvider<List<String>>((ref) => []);

final statusTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});
