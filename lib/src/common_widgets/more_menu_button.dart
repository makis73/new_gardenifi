// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/show_add_remove_valves_widget.dart';
import 'package:new_gardenifi_app/src/localization/app_localizations_provider.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class MoreMenuButton extends ConsumerWidget {
  const MoreMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MenuAnchor(
        alignmentOffset: const Offset(-130, 0),
        menuChildren: [
          MenuItemButton(
            leadingIcon: Image.asset(
              'assets/icons/valve.png',
              width: 25,
              color: Colors.black.withOpacity(0.7),
            ),
            child: Text('Add/Remove valves'.hardcoded),
            onPressed: () {
              ShowAddRemoveValvesWidget.showBottomSheet(context);
            },
          ),
          const Divider(
            endIndent: 30,
            indent: 30,
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.exit_to_app),
            child: Text(loc.exit),
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
        builder: (context, controller, child) => IconButton(
          iconSize: 25,
          color: Colors.black54,
          icon: const Icon(Icons.menu),
          onPressed: () => controller.open(),
        ),
      ),
    );
  }
}
