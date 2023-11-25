import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';

// class BluetoothController extends StateNotifier<AsyncValue<bool>> {
//   BluetoothController(this.bluetoothRepository) : super(const AsyncValue.data(false));

  // final BluetoothRepository bluetoothRepository;

  // BluetoothDevice? device;

  // late StreamSubscription<List<ScanResult>> _scanSubscription;

  // late StreamSubscription<BluetoothConnectionState> _connectionSubscription;

  /// Start watching the stream
  // void setupScanStream() async {
  //   // Sent to widget a loading value
  //   state = const AsyncValue.loading();
  //   // Start coundown 10 seconds and if device not found return to widget a false value
  //   // TODO: Change the timer to 10 - 15 seconds
  //   final timer = Timer(const Duration(seconds: 5), () async {
  //     await bluetoothRepository.stopScan(_scanSubscription);
  //     state = const AsyncData(false);
  //   });

  //   // Start listening for devices
  //   _scanSubscription = bluetoothRepository.scanStream.listen(
  //     (results) async {
  //       if (results.isNotEmpty) {
  //         ScanResult result = results.last;
  //         // If device found:
  //         // stop countdown, stop scan, cancel subscription, sent to widget a true value
  //         if (result.device.platformName == DEVICE_NAME) {
  //           timer.cancel();
  //           bluetoothRepository.stopScan(_scanSubscription);
  //           device = result.device;
  //           state = const AsyncValue<bool>.data(true);
  //         }
  //       }
  //     },
  //   );
  // }


  // Future<void> startScan() async => await bluetoothRepository.startScan();

  // Future<void> stopScan() async => await bluetoothRepository.stopScan(_scanSubscription);

  // Future<void> connectDevice() async => await bluetoothRepository.connectDevice();

//   @override
//   void dispose() {
//     _scanSubscription.cancel();
//     super.dispose();
//   }
// }

/// The provider of the BluetoothController class
// final bluetoothControllerProvider =
//     StateNotifierProvider.autoDispose<BluetoothController, AsyncValue<bool>>((ref) {
//   final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
//   return BluetoothController(bluetoothRepository);
// });

// final deviceProvider = Provider<BluetoothDevice>((ref) {
//   return ref.read(bluetoothControllerProvider.notifier).device!;
// });
