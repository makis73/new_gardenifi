import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

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
        padding: EdgeInsets.all(15),
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text('Cycle ${(index+1).toString()}'.hardcoded),
            subtitle: Text(cycles[index].startTime),
            tileColor: Colors.green[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
