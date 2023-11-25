import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/welcome_screen.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      restorationScopeId: 'app',
      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Gardenifi',
      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      home: const WelcomeScreen(),
    );
  }
}
