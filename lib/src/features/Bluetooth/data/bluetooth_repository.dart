import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';

class BluetoothRepository extends StateNotifier<AsyncValue<BluetoothDevice?>> {
  BluetoothRepository() : super(const AsyncValue.data(null));

  late BluetoothDevice device;

  // The stream to watch Bluetooth adpater state
  Stream<BluetoothAdapterState> adapterStateChanges() => FlutterBluePlus.adapterState;

  // The scan results stream
  Stream<List<ScanResult>> scanStream = FlutterBluePlus.scanResults;

  // The scan stream subscription
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  // The stream to watch Bluetooth connection with device
  Stream<BluetoothConnectionState> connectionStateGhanges(BluetoothDevice device) =>
      device.connectionState;

  /// Start searching for the device
  Future<void> startScanStream() async {
    // Sent to widget a loading value
    state = const AsyncValue.loading();
    // Start coundown 10 seconds. If device not found return to widget a false value
    // TODO: Change the timer to 10 - 15 seconds
    final timer = Timer(const Duration(seconds: 5), () async {
      await stopScanAndSubscription();
      state = const AsyncData(null);
    });

    // Start listening for devices
    _scanSubscription = scanStream.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult result = results.last;
          // If device found:stop countdown, stop scan, cancel subscription, sent to widget a true value
          if (result.device.platformName == DEVICE_NAME) {
            device = result.device;
            timer.cancel();
            await stopScanAndSubscription();
            await connectDevice(device);
            state = AsyncValue<BluetoothDevice>.data(device);
          }
        }
      },
    );
  }

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
  Future<void> stopScanAndSubscription() async {
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

  /// The function to connect to the given device
  Future<void> connectDevice(BluetoothDevice device) async {
    state = const AsyncLoading();
    await device.connect();
    state = AsyncValue<BluetoothDevice>.data(device);
  }

  /// The function to stop watching the connection state
  stopWatchingConnectionState() {
    // TODO: Must cancel this stream after ending all to do with bluetooth
  }
}

// ------------- PROVIDERS -----------------------------------------

/// The provider of the Bluetooth repository
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

/// The provider tha watch if device found
final bleScanProvider =
    StateNotifierProvider<BluetoothRepository, AsyncValue<BluetoothDevice?>>(
        (ref) => BluetoothRepository());

/// The provider that watch the bluetooth connection state with the device
final connectionStateProvider = StreamProvider.family
    .autoDispose<BluetoothConnectionState, BluetoothDevice>((ref, device) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return bluetoothRepository.connectionStateGhanges(device);
});
