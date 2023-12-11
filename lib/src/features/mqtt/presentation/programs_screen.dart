import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/constants/colors.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/can_not_connect_to_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/device_disconnected.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/disconnected_from_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/no_valves_widget.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;

    final mqttControllerValue = ref.watch(mqttControllerProvider);
    final valvesTopicMessage = ref.watch(valvesTopicProvider);
    final statusTopicMessage = ref.watch(statusTopicProvider);
    final commandTopicMessage = ref.watch(commandTopicProvider);
    final configTopicMessage = ref.watch(configTopicProvider);

    final bool cantConnectToBroker = ref.watch(cantConnectProvider);
    final bool disconnectedFromBroker = ref.watch(disconnectedProvider);

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: mqttControllerValue.when(
        data: (data) {
          return Column(
            children: [
              BluetoothScreenUpper(radius: radius, showMenuButton: true, showLogo: true),
              cantConnectToBroker
                  ? const CanNotConnectToBrokerWidget()
                  : (statusTopicMessage.containsKey('err') &&
                          statusTopicMessage['err'] == 'LOST_CONNECTION')
                      ? const DeviceDisconnectedWidget()
                      : valvesTopicMessage.isEmpty
                          ? const NoValvesWidget()
                          : disconnectedFromBroker
                              ? const DisconnectedFromBrokerWidget()
                              : const ValveCards()
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
