import 'dart:convert';
import 'dart:developer';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/program_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/cycles_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/showDuratonPicker.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({required this.valve, super.key});

  final int valve;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __CreateProgramScreenStateState();
}

class __CreateProgramScreenStateState extends ConsumerState<CreateProgramScreen> {
  late Cycle cycle;

  // Get the cyclces if they exist from the program for this valve
  List<Cycle> getCycles(List<Program> schedule) {
    try {
      return schedule.firstWhere((program) => program.out == widget.valve).cycles;
    } catch (e) {
      return [];
    }
  }

  // Get the days if they exist from the program for this valve
  List<DaysOfWeek> getDays(List<Program> schedule) {
    try {
      String days = schedule.firstWhere((program) => program.out == widget.valve).days;
      return stringToDaysOfWeek(days);
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currentSchedule = ref.read(configTopicProvider);
      ref.read(daysOfProgramProvider.notifier).state = getDays(currentSchedule);
      ref.read(cyclesOfProgramProvider.notifier).state = getCycles(currentSchedule);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    var currentSchedule = ref.watch(configTopicProvider);
    var cyclesOfCurrentProgram = ref.watch(cyclesOfProgramProvider);
    var daysOfCurrentProgram = ref.watch(daysOfProgramProvider);

    final daysSelected = ref.watch(daysOfProgramProvider);

    return Scaffold(
        body: Column(
      children: [
        BluetoothScreenUpper(
            radius: radius,
            showMenuButton: true,
            showAddRemoveMenu: true,
            showInitializeMenu: true,
            showLogo: true),
        Center(
          child: Text('Program for valve ${widget.valve}'.hardcoded),
        ),
        Text('Select the days you want to irrigate'.hardcoded),
        const DaysOfWeekWidget(),
        // TODO: If user has not selected days he would not let choose time
        TextButton(
          onPressed: (daysOfCurrentProgram.isEmpty)
              ? null
              : () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    barrierLabel: "Select start time".hardcoded,
                    barrierColor: Colors.white,
                  );

                  if (time != null) {
                    // Create a new cycle with selected start time
                   
                    cycle = Cycle(start: time.format(context));
                    // Update the provider who keeps the state of cycle
                    ref.read(cyclesOfProgramProvider.notifier).state = [
                      ...cyclesOfCurrentProgram,
                      cycle
                    ];
                    // Select the duration for that cycle
                    var duration = await showDurationPickerDialog(context);

                    if (duration != null) {
                      // Add the selected duration to the previous new created cycle
                      cycle.min = duration.inMinutes.toString();
                      // Update the provider
                      ref.read(cyclesOfProgramProvider.notifier).state =
                          addCycleAndSortList(cyclesOfCurrentProgram, cycle);
                    }
                  }
                },
          child: const Text('Add an irrigation cycle'),
        ),
        if (cyclesOfCurrentProgram.isNotEmpty) const CyclesWidget(),
        TextButton(
            onPressed: () {
              var listOfDays = convertListDaysOfWeekToListString(daysSelected).join(',');
              var program = Program(
                out: widget.valve,
                days: listOfDays,
                cycles: cyclesOfCurrentProgram,
              );

              var index = currentSchedule.indexWhere(
                (program) => program.out == widget.valve,
              );

              // If already exist a program for this valve, replace it with the new created, else add this to the schedule(List<Program)
              if (index != -1) {
                currentSchedule[index] = program;
                var res = ref.read(programProvider).sendSchedule(currentSchedule);
                Navigator.pop(context, res);
              } else {
                currentSchedule.add(program);
                var res = ref.read(programProvider).sendSchedule(currentSchedule);
                Navigator.pop(context, res);
              }
            },
            child: Text('Save'.hardcoded)),
        TextButton(
          child: Text('Delete'.hardcoded),
          onPressed: () {
            ref.read(daysOfProgramProvider.notifier).state = [];
            ref.read(cyclesOfProgramProvider.notifier).state = [];

            ref
                .read(mqttControllerProvider.notifier)
                .sendMessage(configTopic, MqttQos.atLeastOnce, jsonEncode([]));
          },
        )
      ],
    ));
  }
}

List<String> convertListDaysOfWeekToListString(List<DaysOfWeek> listDaysOfWeek) {
  var listOfDaysString = listDaysOfWeek.map((e) {
    var nameOfDay = e.name;
    return nameOfDay.toDecapitalized();
  }).toList();
  return listOfDaysString;
}

final daysOfProgramProvider = StateProvider.autoDispose<List<DaysOfWeek>>((ref) => []);
final startTimeOfProgramProvider = StateProvider.autoDispose<String>((ref) => '');
final cyclesOfProgramProvider = StateProvider.autoDispose<List<Cycle>>(((ref) => []));
