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
import 'package:new_gardenifi_app/src/features/Bluetooth/data/test_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/welcome_screen.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectingScreen extends ConsumerStatefulWidget {
  const BluetoothConnectingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectingScreen> {
  // bool deviceFound = false;

  @override
  void initState() {
    // Start scan for devices and listening the stream
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(bleScanProvider.notifier).startScanStream();
      ref.read(bleScanProvider.notifier).startScan();
      // watchResult();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;

    /// Variable that watch the state of the bluetooth adapter
    final bluetoothAdapterProvider = ref.watch(bluetoothAdapterStateStreamProvider);

    final bool isBluetoothOn =
        bluetoothAdapterProvider.value == BluetoothAdapterState.on ? true : false;

    /// Variable that watch if device found
    AsyncValue<BluetoothDevice?> scanResultState = ref.watch(bleScanProvider);

    // final bool isConnected =
    //     connectionState.value == BluetoothConnectionState.connected ? true : false;

    return WillPopScope(
      // If user press the back button during scanning stop scan and unsubscribe from stream
      onWillPop: () async {
        ref.read(bluetoothRepositoryProvider).stopScanAndSubscription();
        return true;
      }, //stopStreamAndScan,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(229, 255, 255, 255),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  BluetoothScreenUpper(
                    radius: radius,
                    showMenuButton: false,
                    logoInTheRight: true,
                  ),
                  !isBluetoothOn
                      ? NoBluetoothWidget(ref: ref)
                      : Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              buildScanResultWidget(scanResultState),
                              BottomWidget(
                                context: context,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                isBluetoothOn: isBluetoothOn,
                                text: 'Press Continue to go to WiFi setup screen'.hardcoded,
                                buttonText: 'Continue'.hardcoded,
                                ref: ref,
                                callback: () async {
                                  throw UnimplementedError();
                                },
                              )
                            ],
                          ),
                      ),
                ],
              ),
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

  Widget buildScanResultWidget(AsyncValue<BluetoothDevice?> scanResultState) {
    return scanResultState.when(
        data: (device) {
          if (device != null) {
            return buildConnectionWidget(device);
          } else {
            return deviceNotFoundWidget();
          }
        },
        error: (error, stackTrace) => Center(child: ErrorMessageWidget(error.toString())),
        loading: () => ProgressWidget(
              title: 'Searching device...'.hardcoded,
              subtitle: 'Please hold your phone near device'.hardcoded,
            ));
  }

  Widget buildConnectionWidget(BluetoothDevice device) {
    /// Variable that watch the connection with device
    final connectionState = ref.watch(connectionStateProvider(device));
    log('From widget: connection state = $connectionState');

    return connectionState.when(
      data: (state) {
        log('$state');
        if (state == BluetoothConnectionState.connected) {
          return Center(
              child: Text(
            'Pairing Succesful'.hardcoded,
            style: TextStyles.mediumBold,
          ));
        } else {
          return couldNotConnectWidget(device);
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
              onPressed: () async {
                ref.read(bleScanProvider.notifier).startScanStream();
                ref.read(bleScanProvider.notifier).startScan();
              },
              child: Text(
                'Try Again'.hardcoded,
                style: TextStyles.smallNormal,
              )),
        ],
      ),
    );
  }

  Widget couldNotConnectWidget(BluetoothDevice device) {
    return Center(
      child: Column(
        children: [
          Center(
              child: Text(
            'Could not connect with device'.hardcoded,
            style: TextStyles.mediumBold,
          )),
          gapH20,
          TextButton(
              onPressed: () async {
                await ref.read(bleScanProvider.notifier).connectDevice(device);
              },
              child: Text(
                'Try Again'.hardcoded,
                style: TextStyles.smallNormal,
              )),
        ],
      ),
    );
  }
}
