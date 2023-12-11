import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/valves_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class ShowAddRemoveValvesWidget {
  static Future<void> showBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Add/Remove valves'.hardcoded,
                style: TextStyles.mediumBold,
              ),
              const Divider(
                indent: 50,
                endIndent: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ValveNumberWidget('1'),
                  ValveNumberWidget('2'),
                  ValveNumberWidget('3'),
                  ValveNumberWidget('4'),
                ],
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Done'.hardcoded))
            ],
          ),
        );
      },
    );
  }
}
