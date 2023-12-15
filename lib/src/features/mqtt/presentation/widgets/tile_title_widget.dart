import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class TileTitle extends StatelessWidget {
  const TileTitle({
    super.key,
    required this.valve,
    required this.valveIsOn,
  });

  final int valve;
  final bool valveIsOn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Valve ${valve.toString()}'.hardcoded,
          style: TextStyles.mediumBold,
        ),
        gapW20,
        if (valveIsOn)
          const Icon(
            Icons.autorenew,
            color: Colors.green,
          ),
      ],
    );
  }
}
