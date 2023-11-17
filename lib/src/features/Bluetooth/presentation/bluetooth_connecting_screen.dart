import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BluetoothConnectingScreen extends ConsumerStatefulWidget {
  const BluetoothConnectingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BluetoothConnectinScreenState();
}

class _BluetoothConnectinScreenState extends ConsumerState<BluetoothConnectingScreen> {
  Future<void> watchResult() async {
    ref.read(scanResultProvider.notifier).setupScanStream();
    await ref.read(scanResultProvider.notifier).startScan();
  }

  @override
  void initState() {
    // Start scan for devices and listening the stream 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      watchResult();
    });
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
    AsyncValue<bool> scanResultState = ref.watch(scanResultProvider);

    return WillPopScope(
      // If user press the back button during scanning stop scan and unsubscribe from stream
      onWillPop: () async {
        ref.read(bluetoothRepositoryProvider).stopScan();
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
                      buildScanResultWidget(scanResultState),
                      // if (scanResultState == const AsyncData(false))
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
    return scanResultState.when(data: (foundDevice) {
      if (foundDevice) {
        // TODO: Connect with device .....
        return ProgressWidget(
          title: 'Connecting with device...'.hardcoded,
          subtitle: 'Please hold your phone near device'.hardcoded,
        );
      } else {
        return deviceNotFoundWidget();
      }
    }, error: (error, stackTrace) {
      // TODO: Do something when error
      return const Center(child: Text('Error'));
    }, loading: () {
      return ProgressWidget(
        title: 'Searching device...'.hardcoded,
        subtitle: 'Please hold your phone near device'.hardcoded,
      );
    });
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
