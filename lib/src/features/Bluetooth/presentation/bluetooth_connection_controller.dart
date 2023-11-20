// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';

// class BleConnectionController extends StateNotifier<AsyncValue<bool>> {
//   BleConnectionController(this.bluetoothRepository, this.device)
//       : super(const AsyncValue.data(true));

//   final BluetoothDevice device;

//   final BluetoothRepository bluetoothRepository;

//   late StreamSubscription<BluetoothConnectionState> _connectionSubscription;

//   void setupConnectionStream() {
//     state = const AsyncValue.loading();

//     Future.delayed(
//       Duration(seconds: 2),
//       () {
//         Stream<BluetoothConnectionState> connectionStream =
//             bluetoothRepository.connectionStream(device);

//         // final timer = Timer(
//         //   const Duration(seconds: 5),
//         //   () {
//         //     state = const AsyncData(false);
//         //   },
//         // );

//         _connectionSubscription = connectionStream.listen((status) {
//           log('connection state: $status');
//           if (status == BluetoothConnectionState.connected) {
//             state = const AsyncData(true);
//           } else {
//             state = const AsyncData(false);
//           }
//         });
//       },
//     );
//   }

//   Future<void> connectDevice(BluetoothDevice device) async =>
//       await bluetoothRepository.connectDevice(device);

//   @override
//   void dispose() {
//     _connectionSubscription.cancel();
//     super.dispose();
//   }
// }

// /// The provider of the BluetoothController class
// final bleConnectionController = StateNotifierProvider.family<BleConnectionController,
//     AsyncValue<bool>, BluetoothDevice>((ref, device) {
//   final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
//   return BleConnectionController(bluetoothRepository, device);
// });
