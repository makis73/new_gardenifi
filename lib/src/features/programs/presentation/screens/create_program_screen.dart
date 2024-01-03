import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/alert_dialogs.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
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
   CreateProgramScreen({required this.valve, required this.name, super.key});

  final int valve;
  String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __CreateProgramScreenStateState();
}

class __CreateProgramScreenStateState extends ConsumerState<CreateProgramScreen> {
  late Cycle cycle;
  bool editName = false;

  TextEditingController nameController = TextEditingController();

  // Get the cyclces if they exist from the program for this valve
  List<Cycle> getCycles(List<Program> schedule) {
    try {
      return schedule.firstWhere((program) => program.out == widget.valve).cycles;
    } catch (e) {
      return [];
    }
  }

  String getName(List<Program> schedule) {
    try {
      return schedule.firstWhere((program) => program.out == widget.valve).name;
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currentSchedule = ref.read(configTopicProvider);
      ref.read(daysOfProgramProvider.notifier).state =
          ref.read(programProvider).getDays(currentSchedule, widget.valve);
      ref.read(cyclesOfProgramProvider.notifier).state = getCycles(currentSchedule);
    });
    super.initState();
  }

  bool hasProgram() {
    var index = ref
        .read(configTopicProvider)
        .indexWhere((program) => program.out == widget.valve);
    return (index != -1) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 6;

    final currentSchedule = ref.watch(configTopicProvider);
    final cyclesOfCurrentProgram = ref.watch(cyclesOfProgramProvider);
    final daysOfCurrentProgram = ref.watch(daysOfProgramProvider);
    final daysSelected = ref.watch(daysOfProgramProvider);

    final hasChanged = ref.watch(hasProgramChangedProvider);

    return PopScope(
      canPop: (ref.read(hasProgramChangedProvider)) ? false : true,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          var res = await showAlertDialog(
              context: context,
              title: 'Are you sure?'.hardcoded,
              defaultActionText: 'Yes'.hardcoded,
              cancelActionText: 'Cancel'.hardcoded,
              content:
                  'There are changes that have not been saved. Are you sure you want go back?'
                      .hardcoded);
          if (res == true) {
            Navigator.pop(context);
          } else {}
        }
      },
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BluetoothScreenUpper(
                radius: radius,
                showMenuButton: true,
                showAddRemoveMenu: true,
                showInitializeMenu: true,
                showLogo: true),
            Center(
              child: Text(
                'Edit/Create program'.hardcoded,
                style: TextStyles.mediumBold,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              editName
                  ? SizedBox(
                      width: 150,
                      child: TextField(
                        controller: nameController..text = widget.name,
                        style: TextStyles.mediumNormal.copyWith(color: Colors.green),
                        autofocus: true,
                        onSubmitted: (value) {
                          widget.name = nameController.text;
                          setState(() {
                            editName = false;
                          });
                          ref.read(hasProgramChangedProvider.notifier).state = true;
                        },
                      ),
                    )
                  : Text(
                      widget.name,
                      style: TextStyles.mediumBold.copyWith(color: Colors.green),
                    ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      editName = true;
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.black54,
                  ))
            ]),

            const Divider(indent: 50, endIndent: 50),
            Text('Select the days you want to irrigate'.hardcoded),
            const DaysOfWeekWidget(),
            const Divider(indent: 50, endIndent: 50),
            TextButton.icon(
              onPressed: (daysOfCurrentProgram.isEmpty)
                  ? null
                  : () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        barrierLabel: "Select start time".hardcoded,
                        barrierColor: Colors.white,
                        barrierDismissible: false,
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
                          ref.read(hasProgramChangedProvider.notifier).state = true;
                          // Add the selected duration to the previous new created cycle
                          cycle.min = duration.inMinutes.toString();
                          // Update the provider
                          ref.read(cyclesOfProgramProvider.notifier).state =
                              addCycleAndSortList(cyclesOfCurrentProgram, cycle);
                        }
                      }
                    },
              label: Text('Add an irrigation cycle'.hardcoded),
              icon: const Icon(Icons.add_circle_outline),
            ),
            // ! Widget overflow on landscape !
            (cyclesOfCurrentProgram.isNotEmpty)
                ? const CyclesWidget()
                : Expanded(child: Container()),
            if (hasChanged)
              OutlinedButton(
                onPressed: () {
                  var listOfDays =
                      convertListDaysOfWeekToListString(daysSelected).join(',');
                  var program = Program(
                    out: widget.valve,
                    name: widget.name,
                    days: listOfDays,
                    cycles: cyclesOfCurrentProgram,
                  );
                  // Check if there is already a program for this valve and return 1 or -1
                  var index = currentSchedule.indexWhere(
                    (program) => program.out == widget.valve,
                  );
                  // If already exist a program for this valve, replace it with the new created, else add this to the schedule(List<Program)
                  if (index != -1) {
                    currentSchedule[index] = program;
                  } else {
                    currentSchedule.add(program);
                  }
                  var res = ref.read(programProvider).sendSchedule(currentSchedule);
                  Navigator.pop(context, res);
                },
                style: OutlinedButton.styleFrom(fixedSize: const Size(250, 20)),
                child: Text(
                  'Save'.hardcoded,
                  style: TextStyles.smallBold,
                ),
              ),
            if (hasProgram())
              TextButton(
                child: Text(
                  'Delete program'.hardcoded,
                  style: TextStyles.xSmallNormal.copyWith(color: Colors.red[800]),
                ),
                onPressed: () async {
                  var delete = await showAlertDialog(
                      context: context,
                      title: 'Program Deletion'.hardcoded,
                      defaultActionText: 'Yes'.hardcoded,
                      cancelActionText: 'Cancel'.hardcoded,
                      content: 'Are you sure you want to delete this program?'.hardcoded);
                  if (delete == true) {
                    var res = ref.read(programProvider).deleteProgram(widget.valve);
                    Navigator.pop(context, res);
                  }
                },
              )
          ],
        ),
      )),
    );
  }
}

// ----------- PROVIDERS ------------

final daysOfProgramProvider = StateProvider.autoDispose<List<DaysOfWeek>>((ref) => []);
final startTimeOfProgramProvider = StateProvider.autoDispose<String>((ref) => '');
final cyclesOfProgramProvider = StateProvider.autoDispose<List<Cycle>>((ref) => []);
final hasProgramChangedProvider = StateProvider.autoDispose<bool>((ref) => false);
