import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class DeviceNotFoundWidget extends StatelessWidget {
  const DeviceNotFoundWidget({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Device not found'.hardcoded,
          style: TextStyles.bigBold,
        ),
        Text(
          'Make sure device is on and try again'.hardcoded,
          style: TextStyles.xSmallNormal,
        ),
        TextButton(
            onPressed: () async {
              // ref.invalidate(bluetoothControllerProvider);
              await ref.read(bluetoothControllerProvider.notifier).startScanStream();
              await ref.read(bluetoothControllerProvider.notifier).startScan();
            },
            child: Text(
              'Try Again'.hardcoded,
              style: TextStyles.smallNormal,
            )),
      ],
    );
  }
}
