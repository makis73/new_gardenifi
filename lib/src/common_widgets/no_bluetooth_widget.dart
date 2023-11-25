import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class NoBluetoothWidget extends StatelessWidget {
  const NoBluetoothWidget({
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
        'App require bluetooth to be turned on'.hardcoded,
        style: TextStyles.alertMessage,
      ),
      TextButton(
        child: Text(
          'Turn on'.hardcoded,
          style: TextStyles.smallBold.copyWith(color: Colors.blue),
        ),
        onPressed: () async {
          await ref.read(bluetoothRepositoryProvider).turnBluetoothOn();
        },
      ), gapH64
    ]);
  }
}
