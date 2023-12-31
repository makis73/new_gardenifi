import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/snackbar.dart';
import 'package:new_gardenifi_app/src/constants/colors.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/can_not_connect_to_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/device_disconnected.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/disconnected_from_broker_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/no_valves_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/valves_widget.dart';
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
    // Refresh screen when app resumes from background
    if (state == AppLifecycleState.resumed) {
      refreshMainScreen(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    final mqttControllerValue = ref.watch(mqttControllerProvider);
    final listOfValves = ref.watch(valvesTopicProvider);
    final statusTopicMessage = ref.watch(statusTopicProvider);

    final bool cantConnectToBroker = ref.watch(cantConnectProvider);
    final bool disconnectedFromBroker = ref.watch(disconnectedProvider);

    // When connection to broker is successful show snackbar
    ref.listen(connectedProvider, (previous, next) {
      if (next) {
        showSnackbar(context, 'Connected to broker.', icon: Icons.done, color: Colors.greenAccent);
      }
    });

    return Scaffold(
        backgroundColor: screenBackgroundColor,
        body: Column(
          children: [
            BluetoothScreenUpper(
                radius: radius,
                showMenuButton: true,
                showAddRemoveMenu: true,
                showInitializeMenu: true,
                showLogo: true),
            mqttControllerValue.when(
              data: (data) {
                return cantConnectToBroker
                    ? const CanNotConnectToBrokerWidget()
                    : (statusTopicMessage.containsKey('err') &&
                            statusTopicMessage['err'] == 'LOST_CONNECTION')
                        ? const DeviceDisconnectedWidget()
                        : (listOfValves.isEmpty)
                            ? const NoValvesWidget()
                            : (disconnectedFromBroker)
                                ? const DisconnectedFromBrokerWidget()
                                : ValvesWidget(listOfValves: listOfValves);
              },
              error: (error, stackTrace) => Center(child: Text(error.toString())),
              loading: () =>
                  const Expanded(child: Center(child: CircularProgressIndicator())),
            ),
          ],
        ));
  }
}
