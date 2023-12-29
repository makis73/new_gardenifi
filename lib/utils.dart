import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
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

TimeOfDay convertStringToTimeOfDay(BuildContext context, String startTime) {
  DateTime dateTime = DateFormat.Hm().parse(startTime);
  TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  return timeOfDay;
}

String getEndTime(BuildContext context, String startTime, String duration) {
  DateTime dateTime =
      DateFormat.Hm().parse(startTime).add(Duration(minutes: int.parse(duration)));
  TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
  return timeOfDay.format(context);
}

String utcToLocal(String time) {
  var x = DateFormat('M/d/y').format(DateTime.now());
  DateTime localDateTime = DateFormat('M/d/y HH:mm').parseUTC('$x $time').toLocal();
  // Convert DateTime local time to [String]
  String localTimeString = DateFormat('HH:mm').format(localDateTime);

  return localTimeString;
}

String localToUtc(String time) {
  var x = DateFormat('M/d/y').format(DateTime.now());
  DateTime localTime = DateFormat('M/d/y HH:mm').parse('$x $time');
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
  ref.invalidate(configTopicProvider);
  ref.invalidate(statusTopicProvider);
  ref.invalidate(valvesTopicProvider);
  ref.read(mqttControllerProvider.notifier).setupAndConnectClient();
}

List<String> createSortedTimeTexts(Program program) {
  if (program.cycles.isNotEmpty) {
    List<String> sortedTimeList = program.cycles.map((e) => e.start).toList();
    sortedTimeList.sort((a, b) => a.compareTo(b));
    return sortedTimeList;
  }
  return [];
}

List<Cycle> addCycleAndSortList(List<Cycle> cycles, Cycle cycle) {
  var newCycles = [...cycles, cycle];
  newCycles.sort(((a, b) => a.start.compareTo(b.start)));
  return newCycles;
}

extension StringCasingExtension on String {
  String toDecapitalized() => length > 0 ? '${this[0].toLowerCase()}${substring(1)}' : '';
}


// Formating string of day to 2 chars string
String shorteningDays(BuildContext context, String? days) {
  var listOfDays = days!.split(',');
  var shortDaysList = listOfDays.map((e) => e.substring(0, 3));
  return shortDaysList.join(', ');
}

List<DaysOfWeek> stringToDaysOfWeek(String days) {
  List<DaysOfWeek> listOfDaysOfWeek = [];
  List<String> listOfStringDays = days.split(',');
  for (var day in listOfStringDays) {
    switch (day) {
      case 'mon':
        listOfDaysOfWeek.add(DaysOfWeek.Mon);
      case 'tue':
        listOfDaysOfWeek.add(DaysOfWeek.Tue);
      case 'wed':
        listOfDaysOfWeek.add(DaysOfWeek.Wed);
      case 'thu':
        listOfDaysOfWeek.add(DaysOfWeek.Thu);
      case 'fri':
        listOfDaysOfWeek.add(DaysOfWeek.Fri);
      case 'sat':
        listOfDaysOfWeek.add(DaysOfWeek.Sat);
      case 'sun':
        listOfDaysOfWeek.add(DaysOfWeek.Sun);
    }
  }
  return listOfDaysOfWeek;
}



  DaysOfWeek? todayToDaysOfWeek(String day) {
  switch (day) {
    case 'Mon':
      return DaysOfWeek.Mon;
    case 'Tue':
      return DaysOfWeek.Tue;
    case 'Wed':
      return DaysOfWeek.Wed;
    case 'Thu':
      return DaysOfWeek.Thu;
    case 'Fri':
      return DaysOfWeek.Fri;
    case 'Sat':
      return DaysOfWeek.Sat;
    case 'Sun':
      return DaysOfWeek.Sun;
  }
  return null;
}
