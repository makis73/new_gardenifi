import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/show_add_remove_valves_widget.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/valves_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class NoValvesWidget extends ConsumerWidget {
  const NoValvesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No valve has been registered.\n".hardcoded,
                  style: TextStyles.mediumBold,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Connect one or more valves on irrigation device and select the port number from the button below to enable them.'
                      .hardcoded
                      .hardcoded,
                  style: TextStyles.smallNormal,
                ),
                gapH24,
                ElevatedButton(
                  child: Text('Enable valves'.hardcoded),
                  onPressed: () {
                    ShowAddRemoveValvesWidget.showBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
          // A placeholder instead of button while device is not connected
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Container(),
            ),
          ),
        ],
      ),
    ));
  }
}
