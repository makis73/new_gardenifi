import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class CouldNotConnectBluetoothWidget extends StatelessWidget {
  const CouldNotConnectBluetoothWidget({
    super.key,
    required this.ref,
    required this.device,
  });

  final WidgetRef ref;
  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Could not connect with device\n'.hardcoded,
          style: TextStyles.mediumBold,
          textAlign: TextAlign.center,
        ),
        TextButton(
            onPressed: () async {
              ref.invalidate(bluetoothControllerProvider);
              await ref.read(bluetoothControllerProvider.notifier).connectDevice(device);
            },
            child: Text(
              'Try Again'.hardcoded,
              style: TextStyles.smallNormal,
            )),
      ],
    );
  }
}
