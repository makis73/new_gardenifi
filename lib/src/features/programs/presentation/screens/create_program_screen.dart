import 'dart:developer';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/cycles_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/showDuratonPicker.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({required this.valve, super.key});

  final int valve;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __CreateProgramScreenStateState();
}

class __CreateProgramScreenStateState extends ConsumerState<CreateProgramScreen> {
  late Program newProgram;

  late Cycle cycle;
  final Duration _duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    final daysSelected = ref.watch(daysOfProgramProvider);
    final startTime = ref.watch(startTimeOfProgramProvider);
    final cycles = ref.watch(cyclesProvider);
    // final duration = ref.watch(durationProvider);
    log('days: $daysSelected');
    // log('startTime: $startTime');
    log('cycles: $cycles');
    // log('duration: ${duration.inMinutes}');

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
          child: Text('Program for valve ${widget.valve}'),
        ),
        Text('Select the days you want to irrigate'.hardcoded),
        const DaysOfWeekWidget(),
        // TODO: If user has not selected days he would not let choose time
        TextButton(
          onPressed: daysSelected.isEmpty
              ? null
              : () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    barrierLabel: "Select start time".hardcoded,
                    barrierColor: Colors.white,
                  );

                  if (time != null) {
                    ref.read(startTimeOfProgramProvider.notifier).state =
                        time.format(context);

                    cycle = Cycle(startTime: time.format(context));

                    ref.read(cyclesProvider.notifier).state = [...cycles, cycle];

                    var duration = await showDurationPickerDialog(context);

                    if (duration != null) {
                      // ref.read(durationProvider.notifier).state = duration;
                      cycle.duration = duration.inMinutes.toString();
                      ref.read(cyclesProvider.notifier).state = [...cycles, cycle];
                    }
                  }
                },
          child: const Text('Add an irrigation cycle'),
        ),
        // TextButton(
        //     onPressed: () async {
        //       var duration = await showDurationPickerDialog();
        //       if (duration != null) {
        //         ref.read(durationProvider.notifier).state = duration;
        //       }
        //     },
        //     child: const Text('Add duration')),
        if (cycles.isNotEmpty) const CyclesWidget(),
      ],
    ));
  }
}

final daysOfProgramProvider = StateProvider<List<DaysOfWeek>>((ref) => []);
final startTimeOfProgramProvider = StateProvider<String>((ref) => '');
final cyclesProvider = StateProvider<List<Cycle>>(((ref) => []));
// final durationProvider = StateProvider<Duration>((ref) => Duration.zero);
