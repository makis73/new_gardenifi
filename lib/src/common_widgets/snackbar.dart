import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

void showSnackbar(BuildContext context, String title, IconData icon, Color? color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(title),
        Icon(
          icon,
          color: color,
        )
      ]),
      duration: const Duration(seconds: 3),
      width: MediaQuery.of(context).size.width * 0.8,
      behavior: SnackBarBehavior.floating,
    ));
  }