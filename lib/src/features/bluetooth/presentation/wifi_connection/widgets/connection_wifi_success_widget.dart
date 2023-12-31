import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bottom_screen_widget.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/programs_screen.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionWifiSuccessWidget extends ConsumerWidget {
  const ConnectionWifiSuccessWidget({
    super.key,
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Device connected to internet succesfuly'.hardcoded,
                    style: TextStyles.mediumBold,
                    textAlign: TextAlign.center,
                  ),
                  gapH32,
                  const Icon(
                    Icons.wifi,
                    size: 40,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          BottomWidget(
            context: context,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            isBluetoothOn: true,
            text: 'You are ready! Press "Continue" to go to main screen'.hardcoded,
            buttonText: 'Continue'.hardcoded,
            ref: ref,
            callback: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('initialized', true);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const ProgramsScreen(),
              ));
            },
          )
        ],
      ),
    );
  }
}
