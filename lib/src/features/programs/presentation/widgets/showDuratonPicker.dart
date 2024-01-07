import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

Future<Duration?> showDurationPickerDialog(BuildContext context) async {
  Duration duration = const Duration(minutes: 1);
  var res = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
            title: Text(
              'Select duration'.hardcoded,
            ),
            content: DurationPicker(
              baseUnit: BaseUnit.minute,
              onChange: (val) {
                setState(() => duration = val);
              },
              duration: duration,
              snapToMins: 5.0,
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'.hardcoded, style: TextStyles.mediumNormal),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Ok'.hardcoded, style: TextStyles.mediumNormal),
                onPressed: () => Navigator.pop(context, true),
              ),
            ]);
      });
    },
  );
  return (res) ? duration : null;
}
