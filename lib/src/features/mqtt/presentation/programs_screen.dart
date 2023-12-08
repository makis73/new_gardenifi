import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/valve_card.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(mqttControllerProvider.notifier).setupAndConnectClient();
  }

  @override
  Widget build(BuildContext context) {
    final mqttControllerValue = ref.watch(mqttControllerProvider);
    final valvesTopicMessage = ref.watch(valvesTopicProvider);
    final statusTopicMessage = ref.watch(statusTopicProvider);
    final commandTopicMessage = ref.watch(commandTopicProvider);
    final configTopicMessage = ref.watch(configTopicProvider);

    return Scaffold(
        body: (statusTopicMessage.containsKey('err') &&
                statusTopicMessage['err'] == 'LOST_CONNECTION')
            ? const Center(child: Text('RPi is not connected to internet'))
            : mqttControllerValue.when(
                data: (data) {
                  return ValveCard();
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Center(
                  //       child: Text(
                  //           'Valves topic: Received message: ${valvesTopicMessage.toString()}'),
                  //     ),
                  //     const Divider(),
                  //     Center(
                  //       child: Text(
                  //           'Status topic: Received message: ${statusTopicMessage.toString()}'),
                  //     ),
                  //     const Divider(),
                  //     Center(
                  //       child: Text(
                  //           'Command topic: Received message: ${commandTopicMessage.toString()}'),
                  //     ),
                  //     const Divider(),
                  //     Center(
                  //       child: Text(
                  //           'Config topic: Received message: ${configTopicMessage.toString()}'),
                  //     ),
                  //   ],
                  // );
                },
                error: (error, stackTrace) => Center(child: Text(error.toString())),
                loading: () => const Center(child: CircularProgressIndicator()),
              ));
  }
}
