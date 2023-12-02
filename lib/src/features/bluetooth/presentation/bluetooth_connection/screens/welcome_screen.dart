import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/big_green_button.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/bottom_screen_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/gardenifi_logo.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_connection/screens/bluetooth_connection_screen.dart';
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
            const BluetoothConnectionScreen(),
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
                if (!isBluetoothOn) Expanded(child: NoBluetoothWidget(ref: ref)),
                BottomWidget(
                    context: context,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    isBluetoothOn: isBluetoothOn,
                    text: 'Before continue you must configure the irrigation device'
                        .hardcoded,
                    buttonText: loc.bluetoothConnection,
                    ref: ref,
                    callback: navigateToNextPage),
              ],
            ),
          )
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

