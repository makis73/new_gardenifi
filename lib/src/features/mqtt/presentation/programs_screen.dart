import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/bottom_screen_widget.dart';
import 'package:new_gardenifi_app/src/constants/colors.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/device_disconnected.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/valve_card.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

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

    return Scaffold(
        backgroundColor: screenBackgroundColor,
        body: mqttControllerValue.when(
          data: (data) {
            return Column(
              children: [
                BluetoothScreenUpper(
                    radius: radius, showMenuButton: true, showLogo: true),
                (statusTopicMessage.containsKey('err') &&
                        statusTopicMessage['err'] == 'LOST_CONNECTION')
                    // TODO: Make screen for no rpi connected
                    ? const DeviceDisconnectedWidget()
                    : const ValveCard(),
              ],
            );
          },
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
  }
}
