import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/common_widgets/button_placeholder.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class WaitWhileFetchingWidget extends StatelessWidget {
  const WaitWhileFetchingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: ProgressWidget(
              title: 'Please wait while fetching networks'.hardcoded,
              textStyle: TextStyles.smallBold,
            ),
          ),
          const ButtonPlaceholder(),
        ],
      ),
    );
  }
}
