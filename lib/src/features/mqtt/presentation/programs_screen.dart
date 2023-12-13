import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/constants/colors.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/can_not_connect_to_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/device_disconnected.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/disconnected_from_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/no_valves_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/valve_card.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Setup a client and connect it to broker
    ref.read(mqttControllerProvider.notifier).setupAndConnectClient();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var disstate = ref.read(disconnectedProvider);
    log('didChange..: $disstate');
    if (state == AppLifecycleState.resumed) {
      refreshMainScreen(ref);
    }
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

    ref.listen(
      connectedProvider,
      (previous, next) {
        if (next) {
          showSnackbar();
        }
      },
    );

    return Scaffold(
        backgroundColor: screenBackgroundColor,
        body: Column(
          children: [
            BluetoothScreenUpper(radius: radius, showMenuButton: true, showLogo: true),
            mqttControllerValue.when(
              data: (data) {
                return cantConnectToBroker
                    ? const CanNotConnectToBrokerWidget()
                    : (statusTopicMessage.containsKey('err') &&
                            statusTopicMessage['err'] == 'LOST_CONNECTION')
                        ? const DeviceDisconnectedWidget()
                        : (valvesTopicMessage.isEmpty)
                            ? const NoValvesWidget()
                            : (disconnectedFromBroker)
                                ? const DisconnectedFromBrokerWidget()
                                : const ValveCards();
              },
              error: (error, stackTrace) => Center(child: Text(error.toString())),
              loading: () =>
                  const Expanded(child: Center(child: CircularProgressIndicator())),
            ),
          ],
        ));
  }

  void showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text('Connected to broker'.hardcoded),
        const Icon(
          Icons.done,
          color: Colors.greenAccent,
        )
      ]),
      duration: const Duration(seconds: 3),
      width: MediaQuery.of(context).size.width * 0.8,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
