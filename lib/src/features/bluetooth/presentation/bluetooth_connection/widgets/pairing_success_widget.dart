import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class PairingSuccessWidget extends StatelessWidget {
  const PairingSuccessWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pairing Succesful'.hardcoded,
          style: TextStyles.bigBold,
        ),
        gapH32,
        const Icon(
          Icons.bluetooth_connected,
          size: 40,
          color: Colors.blue,
        ),
      ],
    );
  }
}
