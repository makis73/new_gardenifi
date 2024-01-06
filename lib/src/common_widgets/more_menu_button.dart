// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/alert_dialogs.dart';
import 'package:new_gardenifi_app/src/common_widgets/snackbar.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_connection/screens/welcome_screen.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/program_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/about_dialog.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/show_add_remov_bottomsheet.dart';
import 'package:new_gardenifi_app/src/localization/app_localizations_provider.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class MoreMenuButton extends ConsumerWidget {
  const MoreMenuButton({
    super.key,
    this.addRemoveValves = false,
    this.initializeIoT = false,
  });

  final bool? addRemoveValves;
  final bool? initializeIoT;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MenuAnchor(
        alignmentOffset: const Offset(-130, 0),
        menuChildren: [
          if (addRemoveValves == true)
            MenuItemButton(
              leadingIcon: Image.asset(
                'assets/icons/valve.png',
                width: 25,
                color: Colors.black.withOpacity(0.7),
              ),
              child: Text('Add/Remove valves'.hardcoded),
              onPressed: () {
                ShowAddRemoveBottomSheet.showBottomSheet(context);
              },
            ),
          if (initializeIoT == true)
            MenuItemButton(
              leadingIcon: const Icon(Icons.home_repair_service),
              child: Text('Initialize IoT device'.hardcoded),
              onPressed: () async {
                var res = await showAlertDialog(
                    cancelActionText: 'Cancel'.hardcoded,
                    defaultActionText: 'Ok'.hardcoded,
                    context: context,
                    title: 'Initialze IoT'.hardcoded,
                    content:
                        'Are you sure you want to initialze the IoT device'.hardcoded);
                if (res == true) {
                  Navigator.of(context).popAndPushNamed('welcomeScreen');
                }
              },
            ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.restart_alt),
            onPressed: () async {
              var res = await showAlertDialog(
                  context: context,
                  title: 'Reboot',
                  defaultActionText: 'Yes'.hardcoded,
                  content:
                      'Are you sure you want to reboot IoT device? Your programs will not be lost'
                          .hardcoded,
                  cancelActionText: 'Cancel'.hardcoded);
              if (res == true) {
                showSnackbar(context, 'IoT will reboot now!');
                ref.read(programProvider).rebootDevice();
              }
            },
            child: Text('Reboot IoT device'.hardcoded),
          ),
          const Divider(
            endIndent: 30,
            indent: 30,
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.info_outline),
            child: Text('About'.hardcoded),
            onPressed: () => aboutDialog(context: context, ref: ref),
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
