import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';

class BluetoothRepository extends StateNotifier<AsyncValue<bool>> {
  BluetoothRepository() : super(const AsyncValue.data(true));

  // The scan results stream
  Stream<List<ScanResult>> scanStream = FlutterBluePlus.scanResults;
  // The stream to watch Bluetooth adpater state
  Stream<BluetoothAdapterState> adapterStateChanges() => FlutterBluePlus.adapterState;

  /// Function to turn on bluetooth adapter of mobile
  Future<void> turnBluetoothOn() async {
    FlutterBluePlus.turnOn();
  }

  /// Start scaning for devices.
  Future<void> startScan() async {
    try {
      await FlutterBluePlus.startScan();
    } catch (e) {
      throw Exception('Start Scan Error: $e');
    }
  }

  /// Function to stop scanning and cancel the stream subscription.
  Future<void> stopScan(StreamSubscription<List<ScanResult>> scanSubscription) async {
    log('Scan stoped');
    try {
      await FlutterBluePlus.stopScan();
      await scanSubscription.cancel();
    } catch (e) {
      throw Exception('Stop Scan Error: $e');
    }
  }

  // TODO: For debug only
  bool isScanningNow() {
    return FlutterBluePlus.isScanningNow;
  }
}

/// The provider of the repository
final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  final blue = BluetoothRepository();
  ref.onDispose(() => blue.dispose());
  return BluetoothRepository();
});

/// The provider of the bluetooth adapter state stream
final bluetoothAdapterStateStreamProvider =
    StreamProvider.autoDispose<BluetoothAdapterState>((ref) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return bluetoothRepository.adapterStateChanges();
});
