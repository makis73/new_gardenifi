import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/utils.dart';

class ProgramController {
  final Ref ref;

  ProgramController(this.ref);

  bool sendSchedule(List<Program> schedule) {
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
      return true;
    } on Exception catch (e) {
      log('PROGRAM_CONTROLLER:: Error while sending schedule to broker (error: ${e.toString()})');
      return false;
    }
  }
}

final programProvider = Provider<ProgramController>((ref) {
  return ProgramController(ref);
});
