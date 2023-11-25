import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectDeviceScreen extends ConsumerWidget {
  const ConnectDeviceScreen(this.device, {super.key});
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(child: Text('Connecting screen')),
    );
  }
}
