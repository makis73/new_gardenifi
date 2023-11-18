import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/error_message_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_connection_controller.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectingScreen extends ConsumerStatefulWidget {
  const BluetoothConnectingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectingScreen> {
  bool deviceFound = false;

  Future<void> watchResult() async {
    ref.read(bluetoothControllerProvider.notifier).setupScanStream();
    await ref.read(bluetoothControllerProvider.notifier).startScan();
  }

  // void watchConnection() async {
  //   await ref.read(bluetoothControllerProvider.notifier).connectDevice();
  //   ref.read(bleConnectionController).setupConnectionStream();
  // }

  @override
  void initState() {
    // Start scan for devices and listening the stream
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => watchResult());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    /// Variable that watch the state of the bluetooth adapter
    final bluetoothAdapterProvider = ref.watch(bluetoothAdapterStateStreamProvider);

    final bool isBluetoothOn =
        bluetoothAdapterProvider.value == BluetoothAdapterState.on ? true : false;

    /// Variable that watch if device found
    AsyncValue<bool> scanResultState = ref.watch(bluetoothControllerProvider);

    return WillPopScope(
      // If user press the back button during scanning stop scan and unsubscribe from stream
      // TODO: unsubscribe from device connection stream
      onWillPop: () async {
        ref.read(bluetoothControllerProvider.notifier).stopScan();
        return true;
      }, //stopStreamAndScan,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(229, 255, 255, 255),
        body: Stack(
          children: [
            BluetoothScreenUpper(
              radius: radius,
              showMenuButton: false,
              logoInTheRight: true,
            ),
            !isBluetoothOn
                ? NoBluetoothWidget(ref: ref)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (!deviceFound) buildScanResultWidget(scanResultState),
                      if (deviceFound) buildConnectionWidget()
                    ],
                  ),
          ],
        ),
        // TODO: For debug only
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            bool isScanningNow = ref.read(bluetoothRepositoryProvider).isScanningNow();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: isScanningNow
                    ? const Text('IsScanning')
                    : const Text('Not Scanning')));
          },
        ),
      ),
    );
  }

  Widget buildScanResultWidget(AsyncValue<bool> scanResultState) {
    return scanResultState.when(
        data: (foundDevice) {
          if (foundDevice) {
            // return buildConnectionWidget();
            setState(() {
              deviceFound = true;
            });
            return Container();

            // return ProgressWidget(
            //   title: 'Connecting with device...'.hardcoded,
            //   subtitle: 'Please hold your phone near device'.hardcoded,
            // );
          } else {
            return deviceNotFoundWidget();
          }
        },
        error: (error, stackTrace) => Center(child: ErrorMessageWidget(error.toString())),
        loading: () {
          return ProgressWidget(
            title: 'Searching device...'.hardcoded,
            subtitle: 'Please hold your phone near device'.hardcoded,
          );
        });
  }

  Widget buildConnectionWidget() {
    BluetoothDevice device = ref.watch(bluetoothControllerProvider.notifier).device!;
    log('device: $device');

        // ! every time the widget build it calls again and again them
        // ! they must be called once outside widget
        // ! Probably to move to another screen when device has found
        ref.read(bleConnectionController(device).notifier).connectDevice(device);
        ref.read(bleConnectionController(device).notifier).setupConnectionStream();
      
  

    /// Variable that watch if device connected
    AsyncValue<bool> connectionState = ref.watch(bleConnectionController(device));

    return connectionState.when(
      data: (connected) {
        log('$connected');
        if (connected) {
          return const Center(child: Text('Connected!!!!'));
        } else {
          return const Center(child: Text('Not Connected!!!!'));
        }
      },
      error: (error, stackTrace) => Center(child: ErrorMessageWidget(error.toString())),
      loading: () => ProgressWidget(
        title: 'Connecting...'.hardcoded,
        subtitle: 'Please hold your phone near device'.hardcoded,
      ),
    );
  }

  Widget deviceNotFoundWidget() {
    return Center(
      child: Column(
        children: [
          Center(
              child: Text(
            'Device not found'.hardcoded,
            style: TextStyles.mediumBold,
          )),
          Center(
              child: Text(
            'Make sure device is on and try again'.hardcoded,
            style: TextStyles.smallNormal,
          )),
          gapH20,
          TextButton(
              onPressed: () async => watchResult(),
              child: Text(
                'Try Again'.hardcoded,
                style: TextStyles.smallNormal,
              )),
        ],
      ),
    );
  }
}
