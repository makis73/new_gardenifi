import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class RefreshNetworksButton extends StatelessWidget {
  const RefreshNetworksButton({
    super.key,
    required this.callback,
  });

  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text('Refresh list'.hardcoded),
      // Refresh the provider and rebuild widget
      onPressed: callback,
      icon: const Icon(
        Icons.refresh,
        color: Colors.green,
      ),
    );
  }
}
