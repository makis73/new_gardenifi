import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/big_green_button.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/gardenifi_logo.dart';
import 'package:new_gardenifi_app/src/common_widgets/more_menu_button.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/localization/app_localizations_provider.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectingScreen extends ConsumerStatefulWidget {
  const BluetoothConnectingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectingScreen> {
  @override
  void initState() {
    log('INIT called');
    super.initState();
    // ref.read(bluetoothRepositoryProvider).setupScanStream();
    // ref.read(bluetoothRepositoryProvider).startScan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    /// Variable that watch the state of the bluetooth adapter
    final bluetoothAdapterProvider = ref.watch(bluetoothAdapterStateStreamProvider);

    final bool isBluetoothOn =
        bluetoothAdapterProvider.value == BluetoothAdapterState.on ? true : false;

    final state = ref.watch(bluetoothConnectionController);
    final results = ref.watch(scanResultProvider);

    log(results.toString());

    // When the user leaves the screen stop scaning and listening to the scan result stream
    // Future<bool> stopStreamAndScan() async {
    //   ref.read(bluetoothRepositoryProvider)
    //     ..dispose()
    //     ..stopScan();
    //   return true;
    // }

    return state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : WillPopScope(
            onWillPop: null, //stopStreamAndScan,
            child: Scaffold(
              backgroundColor: const Color.fromARGB(229, 255, 255, 255),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  BluetoothScreenUpper(
                    radius: radius,
                    showMenuButton: false,
                    logoInTheRight: true,
                  ),
                  if (!isBluetoothOn) NoBluetoothWidget(ref: ref),
                  // scanResultState.when(
                  //   data: (data) {
                  //     log('From widget: $data');
                  //     if (data) {
                  //       return const Center(
                  //         child: Text('OK'),
                  //       );
                  //     } else {
                  //       return const Center(
                  //         child: Text('False'),
                  //       );
                  //     }
                  //   },
                  //   error: (error, stackTrace) {
                  //     return const Text('Errorr');
                  //   },
                  //   loading: () => const Center(child: CircularProgressIndicator()),
                  // )
                  ElevatedButton(
                      onPressed: () {
                        ref.read(bluetoothConnectionController.notifier).startScan();
                      },
                      child: const Text('press'))
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  bool isScanningNow =
                      ref.read(bluetoothRepositoryProvider).isScanningNow();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: isScanningNow
                          ? const Text('IsScanning')
                          : const Text('Not Scanning')));
                },
              ),
            ),
          );
  }
}
