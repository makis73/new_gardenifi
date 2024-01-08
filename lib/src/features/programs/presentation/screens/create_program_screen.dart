import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/alert_dialogs.dart';
import 'package:new_gardenifi_app/src/common_widgets/screen_upper_portrait.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/program_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/button_add_cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/cycles_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/button_delete_program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/button_save_program.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  CreateProgramScreen({required this.valve, required this.name, super.key});

  final int valve;
  String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __CreateProgramScreenStateState();
}

class __CreateProgramScreenStateState extends ConsumerState<CreateProgramScreen> {
  bool editName = false;

  TextEditingController nameController = TextEditingController();

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

  bool hasProgram() {
    var index = ref
        .read(configTopicProvider)
        .indexWhere((program) => program.out == widget.valve);
    return (index != -1) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
      child: Scaffold(body: OrientationBuilder(builder: (context, orientation) {
        return (orientation == Orientation.portrait)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScreenUpperPortrait(
                        radius: radius, showMenuButton: false, showLogo: true),
                    createTitle(),
                    createValveNameRow(),
                    const Divider(indent: 50, endIndent: 50),
                    Text('Select the days you want to irrigate'.hardcoded),
                    const DaysOfWeekWidget(),
                    const Divider(indent: 50, endIndent: 50),
                    AddCycleButton(
                        ref: ref,
                        daysOfCurrentProgram: daysOfCurrentProgram,
                        context: context,
                        cyclesOfCurrentProgram: cyclesOfCurrentProgram),
                    (cyclesOfCurrentProgram.isNotEmpty)
                        ? const CyclesWidget()
                        : Expanded(child: Container()),
                    if (hasChanged)
                      SaveProgramButton(
                          widget: widget,
                          ref: ref,
                          daysSelected: daysSelected,
                          cyclesOfCurrentProgram: cyclesOfCurrentProgram,
                          currentSchedule: currentSchedule,
                          context: context),
                    if (hasProgram())
                      DeleteProgramButtonWidget(
                          ref: ref, widget: widget, context: context)
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    createTitle(),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                createValveNameRow(),
                                const DaysOfWeekWidget(),
                                AddCycleButton(
                                    ref: ref,
                                    daysOfCurrentProgram: daysOfCurrentProgram,
                                    context: context,
                                    cyclesOfCurrentProgram: cyclesOfCurrentProgram),
                                     if (hasChanged)
                                  SaveProgramButton(
                                      widget: widget,
                                      ref: ref,
                                      daysSelected: daysSelected,
                                      cyclesOfCurrentProgram: cyclesOfCurrentProgram,
                                      currentSchedule: currentSchedule,
                                      context: context),
                                      if (hasProgram())
                      DeleteProgramButtonWidget(
                          ref: ref, widget: widget, context: context)
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Column(
                              children: [
                                
                                (cyclesOfCurrentProgram.isNotEmpty)
                                    ? const CyclesWidget()
                                    : Expanded(child: Container()),
                               
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
      })),
    );
  }

  Padding createProgramScreenPortrait(
      double radius,
      List<DaysOfWeek> daysOfCurrentProgram,
      BuildContext context,
      List<Cycle> cyclesOfCurrentProgram,
      bool hasChanged,
      List<DaysOfWeek> daysSelected,
      List<Program> currentSchedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScreenUpperPortrait(radius: radius, showMenuButton: false, showLogo: true),
          createTitle(),
          createValveNameRow(),
          const Divider(indent: 50, endIndent: 50),
          Text('Select the days you want to irrigate'.hardcoded),
          const DaysOfWeekWidget(),
          const Divider(indent: 50, endIndent: 50),
          AddCycleButton(
              ref: ref,
              daysOfCurrentProgram: daysOfCurrentProgram,
              context: context,
              cyclesOfCurrentProgram: cyclesOfCurrentProgram),
          (cyclesOfCurrentProgram.isNotEmpty)
              ? const CyclesWidget()
              : Expanded(child: Container()),
          if (hasChanged)
            SaveProgramButton(
                widget: widget,
                ref: ref,
                daysSelected: daysSelected,
                cyclesOfCurrentProgram: cyclesOfCurrentProgram,
                currentSchedule: currentSchedule,
                context: context),
          if (hasProgram())
            DeleteProgramButtonWidget(ref: ref, widget: widget, context: context)
        ],
      ),
    );
  }

  Center createTitle() {
    return Center(
      child: Text(
        'Edit/Create program'.hardcoded,
        style: TextStyles.mediumBold,
      ),
    );
  }

  Padding createValveNameRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          editName
              ? SizedBox(
                  width: 250,
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
              : Expanded(
                  child: Center(
                    child: Text(
                      widget.name,
                      style: TextStyles.mediumBold.copyWith(color: Colors.green),
                    ),
                  ),
                ),
          if (!editName)
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
        ],
      ),
    );
  }
}

// ----------- PROVIDERS ------------

final daysOfProgramProvider = StateProvider.autoDispose<List<DaysOfWeek>>((ref) => []);
final startTimeOfProgramProvider = StateProvider.autoDispose<String>((ref) => '');
final cyclesOfProgramProvider = StateProvider.autoDispose<List<Cycle>>((ref) => []);
final hasProgramChangedProvider = StateProvider.autoDispose<bool>((ref) => false);
