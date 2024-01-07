import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

Future<bool?> showDisconnectedAlertDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog.adaptive(
        title: Text(
          'Disconnected from broker!'.hardcoded,
          style: TextStyles.mediumBold,
        ),
        content: Text(
          'Make sure you are connected to internet and try again'.hardcoded,
          style: TextStyles.smallNormal,
        ),
        actions: <Widget>[
          // TextButton(
          //   child: Text('Cancel'),
          //   onPressed: () => Navigator.pop(context),
          // ),
          TextButton(
              onPressed: () {
                // ref.invalidate(mqttControllerProvider);
                Navigator.pop(context, true);
                
              },
              child: const Text('Ok')),
        ]),
  );
}
