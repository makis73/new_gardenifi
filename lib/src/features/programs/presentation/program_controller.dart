import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/utils.dart';

class ProgramController {
  ProgramController(this.ref);
  final Ref ref;

  int sendSchedule(List<Program> schedule) {
    for (Program program in schedule) {
      for (var cycle in program.cycles) {
        cycle.start = localToUtc(cycle.start);
      }
    }
    try {
      var scheduleEncoded = jsonEncode(schedule);
      ref
          .read(mqttControllerProvider.notifier)
          .sendMessage(configTopic, MqttQos.atLeastOnce, scheduleEncoded);
      return 1;
    } catch (e) {
      log('PROGRAM_CONTROLLER:: Error while sending schedule to broker (error: ${e.toString()})');
      return -1;
    }
  }

  int deleteProgram(int valve) {
    var schedule = ref.read(configTopicProvider);
    var index = schedule.indexWhere(
      (program) => program.out == valve,
    );
    schedule.removeAt(index);
    sendSchedule(schedule);
    return 2;
  }

  // ! What if delete the last cycle? 
  deleteCycle(int cycleIndex) {
    var cycles = ref.read(cyclesOfProgramProvider);
    log('ProgramController:: cyclesProvider BEFORE: ${ref.read(cyclesOfProgramProvider)}');

    log('cycleToDelete: ${cycles[cycleIndex]}');
    cycles.removeAt(cycleIndex);
    ref.read(cyclesOfProgramProvider.notifier).state = [...cycles];
    ref.read(hasProgramChangedProvider.notifier).state = true;
    log('ProgramController:: cyclesProvider AFTER: ${ref.read(cyclesOfProgramProvider)}');
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
    var timeNow = DateFormat('HH:mm').format(DateTime.now());
    var listOfTimes = times.split(' ,');
    if (!listOfTimes.contains(timeNow)) {
      listOfTimes.add(timeNow);
    }
    // If program contains a start time after current time, return this. Else return the first of the list.
    try {
      listOfTimes.sort((a, b) => a.compareTo(b));
      var index = listOfTimes.indexWhere((element) => element == timeNow);
      return listOfTimes[index + 1];
    } catch (e) {
      return listOfTimes[0];
    }
  }

  // Get the the next run of the program
  String getNextRun(List<DaysOfWeek> listOfDays, String times) {
    var today = DateFormat('E').format(DateTime.now());
    var todayDay = todayToDaysOfWeek(today);
    var closestTime = getClosestTime(times);

    if (!listOfDays.contains(todayDay)) {
      listOfDays.add(todayDay!);
    }
    try {
      listOfDays.sort((a, b) => a.index.compareTo(b.index));
      var index = listOfDays.indexWhere((element) => element == todayDay);
      if (timeIsAfterNow(closestTime)) {
        return 'Today $closestTime';
      } else {
        return '${listOfDays[index + 1].name} $closestTime';
      }
    } catch (e) {
      return 'Next ${listOfDays[0].name} $closestTime';
    }
  }

  String getStartTimesAsString(List<Cycle> cycles) {
    List<String> startTimesList = [];

    for (var cycle in cycles) {
      if (cycle.min != '0') {
        var startTime = cycle.start;
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

// ----------- PROVIDERS ---------------

final programProvider = Provider<ProgramController>((ref) {
  return ProgramController(ref);
});
