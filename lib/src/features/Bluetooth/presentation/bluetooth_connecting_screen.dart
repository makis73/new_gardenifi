import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/error_message_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/breakpoints.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/welcome_screen.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/wifi_setup_screen.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectingScreen extends ConsumerStatefulWidget {
  const BluetoothConnectingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectingScreen> {
  bool deviceFound = false;
  bool deviceConnected = false;

  late BluetoothDevice raspiDevice;

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
                      ? Expanded(child: NoBluetoothWidget(ref: ref))
                      : Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: buildScanResultWidget(scanResultState),
                              ),
                              if (!deviceConnected)
                                // A placeholder instead of BottomWidget
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 100,
                                  ),
                                ),
                              if (deviceConnected)
                                BottomWidget(
                                  context: context,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  isBluetoothOn: isBluetoothOn,
                                  text: 'Press Continue to go to WiFi setup screen'
                                      .hardcoded,
                                  buttonText: 'Continue'.hardcoded,
                                  ref: ref,
                                  callback: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WifiSetupScreen(raspiDevice),
                                        ));
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
            BluetoothDevice device = ref.read(bluetoothRepositoryProvider).device;
            log('device = $device');
            // bool isScanningNow = ref.read(bluetoothRepositoryProvider).isScanningNow();
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //     content: isScanningNow
            //         ? const Text('IsScanning')
            //         : const Text('Not Scanning')));
          },
        ),
      ),
    );
  }

  Widget buildScanResultWidget(AsyncValue<BluetoothDevice?> scanResultState) {
    return scanResultState.when(
        data: (device) {
          if (device != null) {
            setState(() {
              deviceFound = true;
              raspiDevice = device;
            });
            return buildConnectionWidget(device);
          } else {
            setState(() {
              deviceFound = false;
            });
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
        if (state == BluetoothConnectionState.connected) {
          setState(() {
            deviceConnected = true;
          });
          return pairingSuccessWidget();
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

  Widget pairingSuccessWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pairing Succesful'.hardcoded,
          style: TextStyles.bigBold,
        ),
        gapH32,
        const Icon(
          Icons.bluetooth_connected,
          size: 40,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget deviceNotFoundWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Device not found'.hardcoded,
          style: TextStyles.bigBold,
        ),
        Text(
          'Make sure device is on and try again'.hardcoded,
          style: TextStyles.xSmallNormal,
        ),
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
    );
  }

  Widget couldNotConnectWidget(BluetoothDevice device) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Could not connect with device'.hardcoded,
          style: TextStyles.mediumBold,
        ),
        TextButton(
            onPressed: () async {
              await ref.read(bleScanProvider.notifier).connectDevice(device);
            },
            child: Text(
              'Try Again'.hardcoded,
              style: TextStyles.smallNormal,
            )),
      ],
    );
  }
}
