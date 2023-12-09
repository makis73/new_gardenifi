import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_connection/screens/welcome_screen.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/programs_screen.dart';

/// The Widget that configures your application.
class RootApp extends StatelessWidget {
  const RootApp({super.key, required this.deviceHasBeenInitialized});

  final bool? deviceHasBeenInitialized;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gardenifi',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      restorationScopeId: 'app',
      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // If the device has not been initialized go to first screen. Else go to main program screen
      home: (deviceHasBeenInitialized == true || deviceHasBeenInitialized == null)
          ? const ProgramsScreen()
          : const WelcomeScreen(),
    );
  }
}
