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
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/welcome_screen.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/wifi_setup_screen.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectionScreen extends ConsumerStatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectionScreen> {
  bool deviceConnected = false;

  late BluetoothDevice raspiDevice;

  @override
  void initState() {
    // Start scan for devices and listening the stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bluetoothControllerProvider.notifier).startScanStream();
      ref.read(bluetoothControllerProvider.notifier).startScan();
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
    AsyncValue<BluetoothDevice?> scanResultState = ref.watch(bluetoothControllerProvider);

    return WillPopScope(
      // If user press the back button during scanning stop scan and unsubscribe from stream
      onWillPop: () async {
        ref.read(bluetoothControllerProvider.notifier).stopScan();
        log('${FlutterBluePlus.isScanningNow}');
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
                                child: buildFindingDeviceWidget(scanResultState),
                              ),
                              if (!deviceConnected)
                                // A placeholder instead of button while device is not connected
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    height: 100,
                                  ),
                                ),
                              if (deviceConnected)
                                // When device connect show the button
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
                                          builder: (context) =>
                                              WiFiSetupScreen(raspiDevice),
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
      ),
    );
  }

  Widget buildFindingDeviceWidget(AsyncValue<BluetoothDevice?> scanResultState) {
    return scanResultState.when(
        data: (device) {
          if (device != null) {
            setState(() {
              raspiDevice = device;
            });
            return buildConnectionWidget(raspiDevice);
          } else {
            return buildDeviceNotFoundWidget();
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
    final connectionState = ref.watch(connectionProvider);
    log('From widget: connection state = $connectionState');

    return connectionState.when(
      data: (state) {
        if (state == BluetoothConnectionState.connected) {
          setState(() {
            deviceConnected = true;
          });
          return buildPairingSuccessWidget();
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

  Widget buildPairingSuccessWidget() {
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

  Widget buildDeviceNotFoundWidget() {
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
              ref.read(bluetoothControllerProvider.notifier).startScanStream();
              ref.read(bluetoothControllerProvider.notifier).startScan();
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
              await ref.read(bluetoothControllerProvider.notifier).connectDevice(device);
            },
            child: Text(
              'Try Again'.hardcoded,
              style: TextStyles.smallNormal,
            )),
      ],
    );
  }
}
