import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_connecting_screen.dart';

class BluetoothScreenController extends StateNotifier<AsyncValue<void>> {
  BluetoothScreenController(this.bluetoothRepository, this.ref)
      : super(const AsyncValue.data(null));

  final BluetoothRepository bluetoothRepository;
  final Ref ref;

  getResult() {
    List<ScanResult> result = ref.watch(scanResultProvider);
  }

  Future<void> startScan() async {
    state = const AsyncValue.loading();
    ref.read(bluetoothRepositoryProvider).setupScanStream();
    await ref.read(bluetoothRepositoryProvider).startScan();
    List<ScanResult> result = ref.watch(scanResultProvider);
    log(result.toString());
    state = const AsyncValue.data(null);
  }

  Future<void> watchScanStream() async {
    await startScan();
    state = const AsyncValue<bool>.loading();
    bluetoothRepository.scanStream.listen((results) {
      log('${results.last}');
      // if (results.last == DEVICE_NAME) {
      //   state = const AsyncValue.data(true);
      // }
    });
  }
}

final bluetoothConnectionController =
    StateNotifierProvider<BluetoothScreenController, AsyncValue<void>>((ref) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return BluetoothScreenController(bluetoothRepository, ref);
});
