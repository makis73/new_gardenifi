import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';

class BluetoothRepository extends StateNotifier<AsyncValue<bool>> {
  BluetoothRepository() : super(const AsyncValue.data(true));

  // The subscription for the scan stream stream
  late StreamSubscription<List<ScanResult>> _scanSubscription;
  // The scan results stream
  Stream<List<ScanResult>> scanStream = FlutterBluePlus.scanResults;
  // The stream to watch Bluetooth adpater state
  Stream<BluetoothAdapterState> adapterStateChanges() => FlutterBluePlus.adapterState;

  /// Function to turn on bluetooth adapter of mobile
  Future<void> turnBluetoothOn() async {
    FlutterBluePlus.turnOn();
  }

  /// Start watching the stream
  void setupScanStream() async {
    // Sent to widget a loading value
    state = const AsyncValue.loading();

    // Start coundown 10 seconds and if device not found return to widget a false value
    // TODO: Change the timer to 10 - 15 seconds
    final timer = Timer(const Duration(seconds: 5), () async {
      await stopScan();
      state = const AsyncData(false);
    });

    // Start listening for devices
    _scanSubscription = scanStream.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult result = results.last;
          // If device found:
          // stop countdown, stop scan, cancel subscription, sent to widget a true value
          if (result.device.platformName == DEVICE_NAME) {
            timer.cancel();
            stopScan();
            state = const AsyncValue<bool>.data(true);
          }
        }
      },
    );
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
    log('Scan stoped');
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription.cancel();
    } catch (e) {
      throw Exception('Stop Scan Error: $e');
    }
  }

  // TODO: For debug only
  bool isScanningNow() {
    return FlutterBluePlus.isScanningNow;
  }

  
  @override
  void dispose() {
    super.dispose();
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

/// The provider for finding device or not
final scanResultProvider =
    StateNotifierProvider.autoDispose<BluetoothRepository, AsyncValue<bool>>((ref) {
  return BluetoothRepository();
});
