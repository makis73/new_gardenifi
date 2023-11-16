import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/breakpoints.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/localization/app_localizations_provider.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class BigGreenButton extends ConsumerWidget {
  const BigGreenButton(
    this.message,
    this.isBluetoothOn,
    this.callback, {
    super.key,
  });

  final bool isBluetoothOn;
  final String message;
  final Future<void> Function() callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: Breakpoint.tablet,
              minWidth: width > Breakpoint.tablet ? Breakpoint.tablet : width,
              maxHeight: height * 0.8,
              minHeight: height * 0.08),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(132, 0, 171, 29)),
            onPressed: isBluetoothOn
                ? callback
                : null,
            child: Text(loc.bluetoothConnection, style: TextStyles.bigButtonStyle),
          ),
        ));
  }
}
