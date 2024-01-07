import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> aboutDialog({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  PackageInfo info = await PackageInfo.fromPlatform();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final hwId = prefs.getString('hwId');
  if (context.mounted) {
    var textStyle = const TextStyle(color: Colors.black87, fontSize: 12);
    var metadata = ref.read(metadataTopicProvider);
    showAboutDialog(
        context: context,
        applicationIcon: Image.asset(
          'assets/images/logo_without_text.png',
          width: 50,
          fit: BoxFit.contain,
        ),
        applicationName: 'RaspirriV1',
        applicationVersion: 'Version ${info.version}',
        // applicationLegalese: '',
        children: [
          Text('Hardware Id: $hwId\n', style: textStyle),
          Text('Uptime: ${metadata['uptime']}', style: textStyle),
          Text('Server version: ${metadata['git_commit']}', style: textStyle),
          gapH12,
          InkWell(
              child: Text(
            'https://github.com/gardenifi/server/tree/main',
            style: textStyle.copyWith(color: Colors.blue),
          ))
        ]);
  }
  return null;
}
