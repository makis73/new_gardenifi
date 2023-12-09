import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> checkInitializationStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    bool? initialized = prefs.getBool('initialized');
    print('initialized :: $initialized');
    if (initialized != null && initialized == true) {
      return true;
    }
  } catch (error) {
    log('Main:: Error on geting bool initialized ');
  }
  return false;
}

String timeConvert(BuildContext context, String startTime, String duration) {
  DateTime dateTime = DateFormat.Hm()
      .parse(startTime)
      .add(Duration(minutes: int.parse(duration)));
  TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  return timeOfDay.format(context);
}

String utcToLocal(String time) {
  var x = DateFormat('M/d/y').format(DateTime.now());
  DateTime localDateTime =
      DateFormat('M/d/y hh:mm').parseUTC('$x $time').toLocal();
  // Convert DateTime local time to [String]
  String localTimeString = DateFormat('HH:mm').format(localDateTime);

  return localTimeString;
}

String localToUtc(String time) {
  var x = DateFormat('M/d/y').format(DateTime.now());
  DateTime localTime = DateFormat('M/d/y hh:mm').parse('$x $time');
  // Convert [DateTime] to UTC
  DateTime utcTime = localTime.toUtc();

  // Convert UTC to [String]
  String utcTimeString = DateFormat('HH:mm').format(utcTime);
  return utcTimeString;
}
