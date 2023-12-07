import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';

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
    // ref.read(mqttControllerProvider.notifier).subscribeToTopics();
  }

  @override
  Widget build(BuildContext context) {
    final mqttValue = ref.watch(mqttControllerProvider);
    final valvesStatus = ref.watch(valvesTopicProvider);
    final statusStatus = ref.watch(statusTopicProvider);

    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                  child: Text('From valves topic: Received message: ${valvesStatus.toString()}'),
                ),
                Center(
                  child: Text('From status topic: Received message: ${statusStatus.toString()}'),
                ),
                Center(
                  child: Text('Valve 1 : ${statusStatus['out1']}'),
                ),
                Center(
                  child: Text('Valve 2 : ${statusStatus['out2']}'),
                ),
          ],
        ));
  }
}
