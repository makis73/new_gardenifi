import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_connecting_screen.dart';

class BluetoothScreenController extends StateNotifier<AsyncValue<bool>> {
  BluetoothScreenController(this.bluetoothRepository, this.ref)
      : super(const AsyncValue.data(false));

  final BluetoothRepository bluetoothRepository;
  final Ref ref;

}

