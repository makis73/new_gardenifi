import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';

class BluetoothController extends StateNotifier<AsyncValue<BluetoothDevice?>> {
  BluetoothController(this.bluetoothRepository) : super(const AsyncValue.data(null));

  final BluetoothRepository bluetoothRepository;

  BluetoothDevice? device;

  late StreamSubscription<List<ScanResult>> _scanSubscription;

  Future<void> startScan() async => await bluetoothRepository.startScan();

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  Future<void> startScanStream() async {
    // Sent to widget a loading value
    state = const AsyncValue.loading();
    // Start coundown 10 seconds. If device not found return to widget a false value
    // TODO: Change the timer to 10 - 15 seconds
    final timer = Timer(const Duration(seconds: 5), () async {
      await bluetoothRepository.stopScan();
      state = const AsyncData(null);
    });

    // Start listening for devices
    _scanSubscription = bluetoothRepository.scanStream.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult result = results.last;
          // If device found: stop countdown, stop scan, cancel subscription, connect device and sent to widget the device
          if (result.device.platformName == DEVICE_NAME) {
            device = result.device;
            timer.cancel();
            await _scanSubscription.cancel();
            await bluetoothRepository.stopScan();
            await bluetoothRepository.connectDevice(device!);
            state = AsyncValue<BluetoothDevice>.data(device!);
          }
        }
      },
    );
  }

  Future<void> stopScan() async => await bluetoothRepository.stopScan();

  Future<void> connectDevice(BluetoothDevice device) async =>
      await bluetoothRepository.connectDevice(device);

  Stream<BluetoothConnectionState> watchConnectionChanges() =>
      bluetoothRepository.connectionStateGhanges(device!);
}

//-------------> PROVIDERS <--------------//

// / The provider of the BluetoothController class
final bluetoothControllerProvider =
    StateNotifierProvider<BluetoothController, AsyncValue<BluetoothDevice?>>((ref) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return BluetoothController(bluetoothRepository);
});

// The provider of the device
final deviceProvider = Provider<BluetoothDevice>((ref) {
  return ref.read(bluetoothControllerProvider.notifier).device!;
});

// The provider that watch the connection of the device
final connectionProvider = StreamProvider.autoDispose<BluetoothConnectionState>((ref) {
  final connectionStream =
      ref.watch(bluetoothControllerProvider.notifier).watchConnectionChanges();
  return connectionStream;
});
