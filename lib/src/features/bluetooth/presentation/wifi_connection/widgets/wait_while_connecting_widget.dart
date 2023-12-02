import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/common_widgets/button_placeholder.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class WaitWhileConnectingWidget extends StatelessWidget {
  const WaitWhileConnectingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: ProgressWidget(
                title: 'Please wait while device is connecting to internet'.hardcoded,
                textStyle: TextStyles.smallBold,
              ),
            ),
            const ButtonPlaceholder(),
          ],
        ),
      ),
    );
  }
}
