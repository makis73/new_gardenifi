import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/data/mqtt_repository.dart';

class MqttController extends StateNotifier<String> {
  MqttController() : super('WTF');

  final mqttRepository = MqttRepository();
  MqttServerClient? client;
  late String hwId;

  Future<void> setupAndConnectClient() async {
    print('########## setupAndConnect called!!!!!!');

    final prefs = await SharedPreferences.getInstance();
    final String user = prefs.getString('mqtt_user') ?? '';
    final String password = prefs.getString('mqtt_pass') ?? '';
    final String host = prefs.getString('mqtt_host') ?? '';
    final int port = prefs.getInt('mqtt_port') ?? 0;

    client = mqttRepository.initializeMqttClient(host, port, indentifier);

    // ref.watch(clientProvider.notifier).state = client;

    await mqttRepository.connectClient(client!, user, password);

    print('########## Connected!!!!!!');
    // TODO: Show a snackbar that connected to broker [onConnected]

    // state = const AsyncValue.loading();
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
    print('APP:: [subscribeToTopics] called.');
    await loadHardwareId();
    mqttRepository.subscribeToTopic(client!, createTopicName(statusTopic));
    mqttRepository.subscribeToTopic(client!, createTopicName(configTopic));
    mqttRepository.subscribeToTopic(client!, createTopicName(systemTopic));
    mqttRepository.subscribeToTopic(client!, createTopicName(valvesTopic));
    var topic = createTopicName(statusTopic);
    log('statusTopic: $topic');

    client!.updates!.listen((event) {
      final MqttPublishMessage receivedMessage = event[0].payload as MqttPublishMessage;
      final topic = event[0].topic;

      final String tempMessage =
          MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
      // String message = Utf8Decoder().convert(tempMessage!.codeUnits);

      if (tempMessage.isNotEmpty && tempMessage != '{}') {
        state = tempMessage;
        log('APP:: MqttController:: state: $state');
        print('APP:: MqttController:: received message in topic: $topic - $tempMessage ');
      }
    });
  }

  watchBroker(MqttServerClient client) {
    client.updates;
  }
}

// ------------> Providers <--------------
final mqttControllerProvider = StateNotifierProvider<MqttController, String>((ref) {
  return MqttController();
});

// final messageReceivedProvider =
//     StateNotifierProvider<MqttController, AsyncValue<String?>>((ref)  {
//       print('########## Provider called!!!!!!');
//   ref.read(mqttControllerProvider).setupAndConnectClient;
  
// });

// final clientProvider = StateProvider<MqttServerClient?>((ref) {
//   final controller = ref.watch(mqttControllerProvider);
//   return null;
// });

// final brokerStreamProvider =
//     StreamProvider<List<MqttReceivedMessage<MqttMessage?>>>((ref) {
//   final controller = ref.watch(mqttControllerProvider);
//   final client = ref.watch(clientProvider);
//   return controller.watchBroker(client!);
// });
