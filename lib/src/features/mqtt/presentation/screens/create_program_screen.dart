import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/features/mqtt/domain/program.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/widgets/days_of_week_widget.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({required this.valve, super.key});

  final int valve;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __CreateProgramScreenStateState();
}

class __CreateProgramScreenStateState extends ConsumerState<CreateProgramScreen> {
  late Program newProgram;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final radius = screenHeight / 4;

    var state = ref.watch(daysOfProgramProvider);
    log('days: $state');

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
        const DaysOfWeekWidget(),
      ],
    ));
  }
}

final daysOfProgramProvider = StateProvider<List<DaysOfWeek>>((ref) => []);
