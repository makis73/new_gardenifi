import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';

class WifiSetupScreen extends ConsumerWidget {
  WifiSetupScreen(this.device, {super.key});

  final BluetoothDevice device;

 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;
    return Scaffold(
              backgroundColor: const Color.fromARGB(229, 255, 255, 255),
              body: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        BluetoothScreenUpper(radius: radius, showMenuButton: true, logoInTheRight: true)
                      ],
                    ),
                  )
                ],
              ),
    );
  }
}
