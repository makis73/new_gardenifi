import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
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
    List<Cycle> cycles = ref.watch(cyclesProvider);
    return Expanded(
      child: ListView.builder(
        itemCount: cycles.length,
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          var cycle = cycles[index];
          return Card(
            child: ListTile(
              title: Text('Cycle ${(index + 1).toString()}'.hardcoded),
              subtitle: Row(
                children: [
                  Text('Start: '.hardcoded),
                  FilledButton(
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: convertStringToTimeOfDay(context, cycles[index].startTime),
                        barrierLabel: "Select start time".hardcoded,
                        barrierColor: Colors.white,
                      );

                      if (time != null) {
                        ref.read(startTimeOfProgramProvider.notifier).state =
                            time.format(context);
                        var newCycle = cycle.copyWith(startTime: time.format(context));
                        // cycle = Cycle(startTime: time.format(context));
                        cycles.removeAt(index);
                        ref.read(cyclesProvider.notifier).state = [...cycles, newCycle];
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white54,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(cycles[index].startTime),
                  ),
                  gapW32,
                  Text('duration: '.hardcoded),
                  FilledButton(
                    onPressed: () async {
                      var duration = await showDurationPickerDialog(context);

                      if (duration != null) {
                        // ref.read(durationProvider.notifier).state = duration;
                        var newCycle =
                            cycle.copyWith(duration: duration.inMinutes.toString());

                        cycles.removeAt(index);
                        ref.read(cyclesProvider.notifier).state = [...cycles, newCycle];
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white54,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(cycles[index].duration),
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
