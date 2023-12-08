import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/data/mqtt_repository.dart';

class MqttController extends StateNotifier<AsyncValue<void>> {
  MqttController(this.ref) : super(const AsyncLoading());

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
    final command = createTopicName(commandTopic);

    mqttRepository.subscribeToTopic(client!, status);
    mqttRepository.subscribeToTopic(client!, config);
    mqttRepository.subscribeToTopic(client!, system);
    mqttRepository.subscribeToTopic(client!, valves);

    client!.updates!.listen((event) {
      state = const AsyncData(null);
      final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
      final topic = event[0].topic;

      if (topic == valves) {
        final String message =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        // final String replacedString = tempMessage.replaceAll('\'', '"');

        final correctedMessage = message.replaceAll("'", "\"");

        List<String> listOfValvesFromBroker =
            (jsonDecode(correctedMessage) as List<dynamic>).cast<String>();
        ref.read(valvesTopicProvider.notifier).state = listOfValvesFromBroker;
      }

      if (topic == status) {
        final String tempMessage =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        final String replacedString = tempMessage.replaceAll('\'', '"');

        final Map<String, dynamic> mes = jsonDecode(replacedString);
        ref.read(statusTopicProvider.notifier).state = mes;
      }
      if (topic == command) {
        final String tempMessage =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        final String replacedString = tempMessage.replaceAll('\'', '"');

        final Map<String, dynamic> mes = jsonDecode(replacedString);
        ref.read(commandTopicProvider.notifier).state = mes;
      }
    });
  }

  void sendMessage(String topic, MqttQos qos, String message) {
    final topicToSend = createTopicName(topic);
    mqttRepository.publishMessage(topicToSend, qos, message);
  }
}

// ------------> Providers <--------------
final mqttControllerProvider = StateNotifierProvider<MqttController, AsyncValue>((ref) {
  return MqttController(ref);
});

//TODO: Providers must receive the initial value from broker
final valvesTopicProvider = StateProvider<List<String>>((ref) => []);

final statusTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final commandTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final configTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});
