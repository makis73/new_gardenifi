// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/days_of_week_widget.dart';

class DayButton extends ConsumerStatefulWidget {
  const DayButton({required this.day, required this.maxWidth, super.key});

  final DaysOfWeek day;
  final double maxWidth;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DayButtonState();
}

class _DayButtonState extends ConsumerState<DayButton> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.all(2.0),
          child: ElevatedButton(
            child: Text(
              widget.day.name,
              style: TextStyle(color: enabled ? Colors.white : null),
            ),
            style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(0),
                minimumSize: Size(constraints.maxWidth, 50),
                backgroundColor: enabled ? Colors.green[400] : null),
            onPressed: () {
              setState(() {
                // toogle the color of button
                enabled = !enabled;

                if (enabled) {
                  // If the day is selected, add to list, sort it and then update the provider with
                  var state = ref.read(daysOfProgramProvider);
                  var newState = [...state, widget.day];
                  newState.sort((a, b) => a.index.compareTo(b.index));
                  ref.read(daysOfProgramProvider.notifier).state = newState;
                } else {
                  // If the day is diselected, remove it from list, sort the list and then update the provider
                  var state = ref.read(daysOfProgramProvider);
                  state.remove(widget.day);
                  ref.read(daysOfProgramProvider.notifier).state = [...state];
                }
              });
            },
          ),
        ),
      ),
    );
  }

  // List<String> converEnumListToStringList(List<DaysOfWeek> daysList) {
  //   var listOfDaysString = [];
  //   for (var i in daysList) {
  //     listOfDaysString.add(i.name);
  //   }
  //   return listOfDaysString;
  // }
}
