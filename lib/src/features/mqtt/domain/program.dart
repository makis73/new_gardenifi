import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:new_gardenifi_app/src/features/mqtt/domain/cycle.dart';
import 'package:new_gardenifi_app/utils.dart';

class Program {
  int out;
  String? name;
  String days;
  List<Cycle> cycles;

  Program({
    required this.out,
    this.name,
    required this.days,
    required this.cycles,
  });

  List<String>? listOfDays;

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'out': out});
    if (name != null) {
      result.addAll({'name': name});
    }
    result.addAll({'days': days});
    result.addAll({'cycles': cycles.map((x) => x.toMap()).toList()});

    return result;
  }

  factory Program.fromMap(Map<String, dynamic> map) {
    // log('cycles: ${map['cycles']}');
    return Program(
      out: map['out']?.toInt() ?? 0,
      name: map['name'],
      days: map['days'] ?? '',
      cycles: List<Cycle>.from(map['cycles']?.map((x) => Cycle.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Program.fromJson(String source) => Program.fromMap(json.decode(source));

  @override
  String toString() {
    String daysString = days;
    return 'Program: valve: $out, name: $name, days: $daysString, $cycles';
  }

  // clone() => Program(
  //     out: out,
  //     name: name,
  //     days: days,
  //     cycles: cycles.map((e) => e.clone() as Cycle).toList());

  String startTimesToString(BuildContext context, List<Cycle> cycles) {
    List<String> startTimesList = [];

    for (var cycle in cycles) {
      if (cycle.duration != '0') {
        var startTime = cycle.startTime;
        var duration = cycle.duration;
        var endTime = timeConvert(context, startTime, duration);

        startTimesList.add('$startTime - $endTime\n');
      }
    }
    // short the list of times
    startTimesList.sort((a, b) {
      return a.compareTo(b);
    });

    return startTimesList.join();
  }

  String shorteningDays(BuildContext context, String? days) {
    var listOfDays = days!.split(',');

    var shortDaysList = listOfDays.map((e) => e.substring(0, 3));

    Map daysMap = {
      'ΔΕΥΤΕΡΑ': 1,
      'ΤΡΙΤΗ': 2,
      'ΤΕΤΑΡΤΗ': 3,
      'ΠΕΜΠΤΗ': 4,
      'ΠΑΡΑΣΚΕΥΗ': 5,
      'ΣΑΒΒΑΤΟ': 6,
      'ΚΥΡΙΑΚΗ': 7,
      'MONDAY': 10,
      'THUSDAY': 20,
      'WEDNESDAY': 30,
      'THURSDAY': 40,
      'FRIDAY': 50,
      'SATURDAY': 60,
      'SUNDAY': 70,
    };

    return shortDaysList.join(', ');
  }

  splitDays() {
    listOfDays = days.split(',');
  }

  String? decodeDay(String day) {
    switch (day) {
      case "mon":
        return 'Day_Mon_Value';
      case "tue":
        return 'Day_Tue_Value';
      case "wed":
        return 'Day_Wed_Value';
      case "thu":
        return 'Day_Thu_Value';
      case "fri":
        return 'Day_Fri_Value';
      case "sat":
        return 'Day_Sat_Value';
      case "sun":
        return 'Day_Sun_Value';
      case '':
        return null;
    }
    return null;
  }

  String? translateDay(String day) {
    switch (day) {
      case "Day_Mon_Value":
        return 'mon';
      case "Day_Tue_Value":
        return 'tue';
      case "Day_Wed_Value":
        return 'wed';
      case "Day_Thu_Value":
        return 'thu';
      case "Day_Fri_Value":
        return 'fri';
      case "Day_Sat_Value":
        return 'sat';
      case "Day_Sun_Value":
        return 'sun';
    }
    return null;
  }
}
