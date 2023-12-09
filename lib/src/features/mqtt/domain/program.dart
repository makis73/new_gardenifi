import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/features/mqtt/domain/cycle.dart';
import 'package:new_gardenifi_app/utils.dart';

class Program {
  int? out;
  String? name;
  String? days;
  List<Cycle>? cycles;

  Program({
    this.out,
    this.name,
    this.days,
    this.cycles,
  });

  List<String>? listOfDays;

  @override
  String toString() {
    if (days != null) {
      String daysString = days!;
      return '$daysString, $cycles';
    } else {
      return 'null days';
    }
  }

  clone() => Program(
      out: out,
      name: name,
      days: days,
      cycles: cycles!.map((e) => e.clone() as Cycle).toList());

  String startTimesToString(BuildContext context, List<Cycle> cycles) {
    List<String> startTimesList = [];

    cycles.forEach((cycle) {
      if (cycle.duration != '0') {
        var startTime = cycle.startTime ;  
        var duration = cycle.duration;
        var endTime = timeConvert(context, startTime, duration);

        startTimesList.add('$startTime - $endTime\n');
      }
    });
    // short the list of times
    startTimesList.sort((a, b) {
      return a.compareTo(b);
    });

    return startTimesList.join();
  }

  String shorteningDays(BuildContext context, String? days) {
    var listOfDays = days!.split(',');

    var shortDaysList = listOfDays
        .map((e) => e.substring(0, 3));

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
    listOfDays = days?.split(',');
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
  }

  Map<String, dynamic> toJson() {
    return {
      'out': out,
      'name': name,
      'days': ((days?.split(','))?.map((e) => translateDay(e)))?.join(','),
      'cycles': cycles?.map((e) => e.toJson()).toList(),
    };
  }

  Program.fromJson(Map<String, dynamic> json) {
    out = json['out'];
    name = json['name'];
    List<String> daysList = json['days'].split(',');
    String decodedDays = daysList.map((e) => decodeDay(e)).join(',');
    days = decodedDays;
    cycles = <Cycle>[];
    for (var e in json['cycles']) {
      cycles?.add(Cycle.fromJson(e));
    }
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
  }
}
