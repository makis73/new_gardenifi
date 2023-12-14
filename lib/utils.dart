import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:new_gardenifi_app/src/features/mqtt/domain/program.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
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
  DateTime dateTime =
      DateFormat.Hm().parse(startTime).add(Duration(minutes: int.parse(duration)));
  TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  return timeOfDay.format(context);
}

String utcToLocal(String time) {
  var x = DateFormat('M/d/y').format(DateTime.now());
  DateTime localDateTime = DateFormat('M/d/y hh:mm').parseUTC('$x $time').toLocal();
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

void refreshMainScreen(WidgetRef ref) {
  ref.invalidate(cantConnectProvider);
  ref.invalidate(disconnectedProvider);
  ref.invalidate(mqttControllerProvider);
  ref.read(mqttControllerProvider.notifier).setupAndConnectClient();
}

List<Text> createSortedTimeTexts(Program program) {
  List<String> sortedTimeList = program.cycles.map((e) => e.startTime).toList();
  sortedTimeList.sort((a, b) => a.compareTo(b));
  List<Text> textList = sortedTimeList.map((e) => Text(e)).toList();
  return textList;
}

var fakeProgram = [
  {
    "out": 1,
    "name": "home",
    "days": "thu",
    "cycles": [
      {"start": "13:10", "min": "5", "isCycleRunning": false},
      {"start": "10:00", "min": "10", "isCycleRunning": false},
      {"start": "08:00", "min": "8", "isCycleRunning": false},
      {"start": "06:00", "min": "6", "isCycleRunning": false}
    ]
  },
  {
    "out": 2,
    "name": null,
    "days": "fri",
    "cycles": [
      {"start": "13:00", "min": "15", "isCycleRunning": false}
    ]
  }
];
