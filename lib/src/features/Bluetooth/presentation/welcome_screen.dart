import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/big_green_button.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/gardenifi_logo.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/Bluetooth/presentation/bluetooth_connecting_screen.dart';
import 'package:new_gardenifi_app/src/localization/app_localizations_provider.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;

    final bluetoothAdapterProvider = ref.watch(bluetoothAdapterStateStreamProvider);
    final loc = ref.read(appLocalizationsProvider);
    
    final bool isBluetoothOn =
        bluetoothAdapterProvider.value == BluetoothAdapterState.on ? true : false;

    Future<void> navigateToNextPage() async {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BluetoothConnectingScreen(),
      ));
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(229, 255, 255, 255),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  BluetoothScreenUpper(
                      radius: radius,
                      showMenuButton: true,
                      logoInTheRight: false,
                      messageWidget: buildWelcomeText(radius, loc)),
                  GardenifiLogo(height: screenHeight, divider: 8),
                  if (!isBluetoothOn) NoBluetoothWidget(ref: ref),
                  buildBottomWidgets(context, screenWidth, screenHeight, isBluetoothOn,
                      ref, navigateToNextPage),
                ],
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            bool isScanningNow = ref.read(bluetoothRepositoryProvider).isScanningNow();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: isScanningNow
                    ? const Text('IsScanning')
                    : const Text('Not Scanning')));
          },
        ));
  }

  Widget buildBottomWidgets(BuildContext context, double screenWidth, double screenHeight,
      bool isBluetoothOn, WidgetRef ref, Future<void> Function() callback) {
    final loc = ref.read(appLocalizationsProvider);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              'Before continue you must configure the irrigation device.'.hardcoded,
              style: TextStyles.smallNormal,
            ),
          ),
          BigGreenButton(loc.bluetoothConnection, isBluetoothOn, callback)
        ],
      ),
    );
  }

  Positioned buildWelcomeText(double radius, AppLocalizations loc) {
    return Positioned.fill(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: radius / 4),
        child: Text(
          loc.welcomeText,
          style: TextStyles.mediumBold,
          textAlign: TextAlign.center,
        ),
      ),
    ));
  }
}
