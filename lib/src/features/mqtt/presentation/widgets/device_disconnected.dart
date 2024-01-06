import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class DeviceDisconnectedWidget extends ConsumerWidget {
  const DeviceDisconnectedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Device disconnected from broker!'.hardcoded,
                style: TextStyles.mediumBold.copyWith(color: Colors.red[900]),
                textAlign: TextAlign.center,
              ),
              Text(
                'Make sure device is powered on '.hardcoded,
                style: TextStyles.smallNormal,
              ),
            ],
          ),
        ),
        // A placeholder instead of button while device is not connected
        Flexible(
          flex: 1,
          child: Container(
            height: 100,
          ),
        ),
      ],
    ));
  }
}
