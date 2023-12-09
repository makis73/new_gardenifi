import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
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
                'Device disconnectet from internet!'.hardcoded,
                style: TextStyles.mediumBold,
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
