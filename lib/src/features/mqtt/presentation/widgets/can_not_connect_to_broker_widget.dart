import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class CanNotConnectToBrokerWidget extends ConsumerWidget {
  const CanNotConnectToBrokerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Can\'t connect to broker.'.hardcoded,
                  style: TextStyles.mediumBold.copyWith(color: Colors.red[900]),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Make sure you are connected to internet and try again'.hardcoded,
                  style: TextStyles.smallNormal,
                  textAlign: TextAlign.center,
                ),
                TextButton(
                    onPressed: () async {
                      // TODO: To something
                    },
                    child: Text(
                      'Try Again'.hardcoded,
                      style: TextStyles.smallNormal,
                    )),
                // gapH32,
                // const Icon(
                //   Icons.wifi_off,
                //   size: 40,
                //   color: Colors.blue,
                // )
              ],
            ),
          ), // A placeholder instead of button while device is not connected
          Flexible(
            flex: 1,
            child: SizedBox(
              height: 100,
              child: Column(
                children: [
                  Text('If problem persist exit the app and try open again.'
                      .hardcoded),
                  TextButton(
                      onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                      child: Text('Exit'.hardcoded))
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
