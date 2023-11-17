import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({
    super.key,
    required this.title, this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.mediumBold,
          ),
          Text(
            subtitle ?? '',
            style: TextStyles.smallNormal,
          ),
          gapH24,
          const CircularProgressIndicator()
        ],
      ),
    );
  }
}
