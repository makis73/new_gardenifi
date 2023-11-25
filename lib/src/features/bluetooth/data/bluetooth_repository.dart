import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BluetoothRepository  {
  BluetoothRepository() : super();

   // The stream to watch Bluetooth adpater state
  Stream<BluetoothAdapterState> adapterStateChanges() => FlutterBluePlus.adapterState;

  // The scan results stream
  Stream<List<ScanResult>> scanStream = FlutterBluePlus.scanResults;

  // The stream to watch Bluetooth connection with device
  Stream<BluetoothConnectionState> connectionStateGhanges(BluetoothDevice device) =>
      device.connectionState;

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
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      throw Exception('Stop Scan Error: $e');
    }
  }

  /// The function to connect to the given device
  Future<void> connectDevice(BluetoothDevice device) async {
    await device.connect();
  }

  /// The function to stop watching the connection state
  stopWatchingConnectionState() {
    // TODO: Must cancel this stream after ending all to do with bluetooth
  }
}

// -------------> PROVIDERS <--------------------

/// The provider of the Bluetooth repository
final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  return BluetoothRepository();
});

/// The provider of the bluetooth adapter state stream
final bluetoothAdapterStateStreamProvider =
    StreamProvider.autoDispose<BluetoothAdapterState>((ref) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return bluetoothRepository.adapterStateChanges();
});

