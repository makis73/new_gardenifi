import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/alert_dialogs.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/program_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/showDuratonPicker.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

class CyclesWidget extends ConsumerStatefulWidget {
  const CyclesWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CyclesWidgetState();
}

class _CyclesWidgetState extends ConsumerState<CyclesWidget> {
  @override
  Widget build(BuildContext context) {
    List<Cycle> cycles = ref.watch(cyclesOfProgramProvider);
    return Expanded(
      child: ListView.builder(
        itemCount: cycles.length,
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          var cycle = cycles[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 10, right: 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cycle ${(index + 1).toString()}'.hardcoded,
                    style: TextStyles.smallBold,
                  ),
                  IconButton(
                      onPressed: () async {
                        var res = await showAlertDialog(
                            context: context,
                            title: 'Cycle deletion!'.hardcoded,
                            defaultActionText: 'Yes'.hardcoded,
                            content:
                                'Are you sure you want to delete this cycle?'.hardcoded,
                            cancelActionText: 'Cancel'.hardcoded);
                        (res == true)
                            ? ref.read(programProvider).deleteCycle(index)
                            : null;
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.black54,
                        size: 20,
                      ))
                ],
              ),
              subtitle: Row(
                children: [
                  Text('Start: '.hardcoded),
                  FilledButton(
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime:
                            convertStringToTimeOfDay(context, cycles[index].start),
                        barrierLabel: "Select start time".hardcoded,
                        barrierColor: Colors.white,
                        barrierDismissible: false,
                      );

                      if (time != null) {
                        var newCycle = cycle.copyWith(startTime: time.format(context));
                        cycles.removeAt(index);
                        ref.read(cyclesOfProgramProvider.notifier).state =
                            addCycleAndSortList(cycles, newCycle);
                        ref.read(hasProgramChangedProvider.notifier).state = true;
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white54,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(cycles[index].start),
                  ),
                  gapW32,
                  Text('duration: '.hardcoded),
                  FilledButton(
                    onPressed: () async {
                      var duration = await showDurationPickerDialog(context);

                      if (duration != null) {
                        var newCycle =
                            cycle.copyWith(duration: duration.inMinutes.toString());

                        cycles.removeAt(index);
                        ref.read(cyclesOfProgramProvider.notifier).state = [
                          ...cycles,
                          newCycle
                        ];
                        ref.read(hasProgramChangedProvider.notifier).state = true;
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white54,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(cycles[index].min),
                  ),
                ],
              ),
              tileColor: Colors.green[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          );
        },
      ),
    );
  }
}
