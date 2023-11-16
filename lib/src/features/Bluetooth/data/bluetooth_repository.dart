import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';

class BluetoothRepository extends StateNotifier<List<ScanResult>> {
  BluetoothRepository() : super([]);

  // The subscription for the scan stream stream
  late StreamSubscription<List<ScanResult>> _scanSubscription;
  // The scan results stream
  Stream<List<ScanResult>> scanStream = FlutterBluePlus.scanResults;

  // The stream to watch Bluetooth adpater state
  Stream<BluetoothAdapterState> adapterStateChanges() => FlutterBluePlus.adapterState;

  // Function to turn on bluetooth adapter of mobile
  Future<void> turnBluetoothOn() async {
    FlutterBluePlus.turnOn();
  }

  // TODO: statenotifier to be of type bool not List<ScanResult>.

  // Start watching the stream
  void setupScanStream() {
    log('setupScanStream started');
    _scanSubscription = scanStream.listen((results) async {
      if (results.isNotEmpty) {
        state = results;
      }
    });
    log('state = ${state.toString()}');
  }

  /// Start scan for devices. Run after [setupScanStream]
  Future<void> startScan() async {
    log('Scan started');
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Start Scan Error: $e');
    }
  }

  /// Function to stop scan althougt it will stop by default after 15 seconds.
  Future<void> stopScan() async {
    log('Scan stoped');
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      throw Exception('Stop Scan Error: $e');
    }
  }

  // For debug only
  bool isScanningNow() {
    return FlutterBluePlus.isScanningNow;
  }

  /// Always [cancel] stream subscription
  @override
  void dispose() {
    super.dispose();
    log('stream closed');
    _scanSubscription.cancel();
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

/// The provider of the state (List<ScanResult>)
final scanResultProvider =
    StateNotifierProvider<BluetoothRepository, List<ScanResult>>((ref) {
  return BluetoothRepository();
});
