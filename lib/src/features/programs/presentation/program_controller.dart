import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/utils.dart';

class ProgramController {
  ProgramController(this.ref);
  final Ref ref;

  bool sendSchedule(List<Program> schedule) {
    for (Program program in schedule) {
      for (var cycle in program.cycles) {
        log('start: ${cycle.start}');

        cycle.start = localToUtc(cycle.start);
        log('start: ${cycle.start}');
      }
    }
    try {
      var scheduleEncoded = jsonEncode(schedule);
      ref
          .read(mqttControllerProvider.notifier)
          .sendMessage(configTopic, MqttQos.atLeastOnce, scheduleEncoded);
      return true;
    } catch (e) {
      log('PROGRAM_CONTROLLER:: Error while sending schedule to broker (error: ${e.toString()})');
      return false;
    }
  }

  void convertScheduleToLocalTZ(List<Program> schedule) {
    for (var program in schedule) {
      for (var cycle in program.cycles) {
        cycle.start = utcToLocal(cycle.start);
      }
    }
  }

  List<DaysOfWeek> getDays(List<Program> schedule, int valve) {
    try {
      String days = schedule.firstWhere((program) => program.out == valve).days;
      return stringToDaysOfWeek(days);
    } catch (e) {
      return [];
    }
  }

  String getClosestTime(String times) {
    var timeNow = DateFormat('hh:mm').format(DateTime.now());

    var listOfTimes = times.split(' ,');
    if (!listOfTimes.contains(timeNow)) {
      listOfTimes.add(timeNow);
    }

    try {
      listOfTimes.sort((a, b) => a.compareTo(b));
      var index = listOfTimes.indexWhere((element) => element == timeNow);
      return listOfTimes[index + 1];
    } catch (e) {
      return listOfTimes[0];
    }
  }

  bool compareTimes(String time) {
    var timeNow = DateFormat('hh:mm').format(DateTime.now());
    var res = time.compareTo(timeNow);
    if (res == 1) {
      return true;
    } else {
      return false;
    }
  }

  String getClosestDay(List<DaysOfWeek> list, String times) {
    var today = DateFormat('E').format(DateTime.now());
    var todayDay = todayToDaysOfWeek(today);

    var closestTime = getClosestTime(times);

    // ------------------------------

    if (!list.contains(todayDay)) {
      list.add(todayDay!);
    }
    try {
      list.sort((a, b) => a.index.compareTo(b.index));
      var index = list.indexWhere((element) => element == todayDay);
      if (compareTimes(closestTime)) {
        return '${list[index].name} $closestTime';
      } else {
        return '${list[index + 1].name} $closestTime';
      }
    } catch (e) {
      return '${list[0].name} $closestTime';
    }
  }

  // TODO: Do i need this ????
  String startTimesToString(List<Cycle> cycles) {
    List<String> startTimesList = [];

    for (var cycle in cycles) {
      if (cycle.min != '0') {
        var startTime = cycle.start;
        var duration = cycle.min;

        startTimesList.add('$startTime ');
      }
    }
    // short the list of times
    startTimesList.sort((a, b) {
      return a.compareTo(b);
    });

    return startTimesList.join(',');
  }
}

final programProvider = Provider<ProgramController>((ref) {
  return ProgramController(ref);
});
