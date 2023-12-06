import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> checkInitializationStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    bool? initialized = prefs.getBool('initialized');
    print(' initialized :: $initialized');
    if (initialized != null && initialized == true) {
      return true;
    }
  } catch (error) {
    log('Main:: Error on geting bool initialized ');
  }
  return false;
}