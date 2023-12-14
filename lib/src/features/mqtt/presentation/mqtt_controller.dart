import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:new_gardenifi_app/src/features/mqtt/domain/program.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/data/mqtt_repository.dart';

class MqttController extends StateNotifier<AsyncValue<void>> {
  MqttController(this.ref) : super(const AsyncLoading());

  MqttServerClient? client;
  final Ref ref;
  late String hwId;
  // late Timer timer;

  Future<void> setupAndConnectClient() async {
    final mqttRepository = ref.read(repositoryProvider);
    final prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('mqtt_user') ?? '';
    final String password = prefs.getString('mqtt_pass') ?? '';
    final String host = prefs.getString('mqtt_host') ?? '';
    final int port = prefs.getInt('mqtt_port') ?? 0;

    client = mqttRepository.initializeMqttClient(host, port, indentifier);

    try {
      await mqttRepository.connectClient(client!, user, password);
    } on NoConnectionException catch (_) {
      // Raised by the client when connection fails.
      ref.read(cantConnectProvider.notifier).state = true;
      // Stop loading
      state = const AsyncData(null);
      // disconnectFromBroker();
    } on SocketException catch (_) {
      // Raised by the socket layer
      ref.read(cantConnectProvider.notifier).state = true;
      // Stop loading
      state = const AsyncData(null);
      // disconnectFromBroker();
    }

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
    final mqttRepository = ref.read(repositoryProvider);
    await loadHardwareId();
    final status = createTopicName(statusTopic);
    final config = createTopicName(configTopic);
    final system = createTopicName(systemTopic);
    final valves = createTopicName(valvesTopic);
    final command = createTopicName(commandTopic);

    mqttRepository.subscribeToTopic(client!, valves);
    mqttRepository.subscribeToTopic(client!, status);
    mqttRepository.subscribeToTopic(client!, config);
    mqttRepository.subscribeToTopic(client!, system);

    client!.updates!.listen((event) {
      state = const AsyncData(null);
      final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
      final topic = event[0].topic;

      if (topic == valves) {
        final String message =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);

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

      if (topic == config) {
        final String tempMessage =
            MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        final String replacedString = tempMessage.replaceAll('\'', '"');

        List<Program> scheduleUtcFromBroker =
            (json.decode(replacedString) as List).map((e) {
          Program program = Program.fromMap(e);
          // log('MqttController:: ${program.toString()}');
          return program;
        }).toList();

        ref.read(configTopicProvider.notifier).state = scheduleUtcFromBroker;
      }
    });
  }

  void sendMessage(String topic, MqttQos qos, String message) {
    final mqttRepository = ref.read(repositoryProvider);
    final topicToSend = createTopicName(topic);
    mqttRepository.publishMessage(topicToSend, qos, message);
  }

  void disconnectFromBroker() {
    final mqttRepository = ref.read(repositoryProvider);
    mqttRepository.disconnect(client!);
  }
}

// ------------> Providers <--------------

final mqttControllerProvider =
    StateNotifierProvider<MqttController, AsyncValue>((ref) => MqttController(ref));

final valvesTopicProvider = StateProvider<List<String>>((ref) => []);

final statusTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final commandTopicProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final configTopicProvider = StateProvider<List<Program>>((ref) => []);

final disconnectedProvider = StateProvider<bool>((ref) => false);

final cantConnectProvider = StateProvider<bool>((ref) => false);

final connectedProvider = StateProvider<bool>(((ref) => false));
