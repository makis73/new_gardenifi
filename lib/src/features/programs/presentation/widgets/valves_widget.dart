import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/common_widgets/snackbar.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/cycle.dart';
import 'package:new_gardenifi_app/src/features/programs/domain/program.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/program_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/days_of_week_widget.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/tile_title_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

class ValvesWidget extends ConsumerStatefulWidget {
  const ValvesWidget({required this.listOfValves, super.key});

  final List<String> listOfValves;

  @override
  ConsumerState<ValvesWidget> createState() => _ValveCardsState();
}

class _ValveCardsState extends ConsumerState<ValvesWidget> {
  List<ExpansionTileController> conList = [];
  bool isExpanded = false;

  Map openValveCmd(int valve) {
    return {"out": valve, "cmd": 1};
  }

  Map closeValveCmd(int valve) {
    return {"out": valve, "cmd": 0};
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(statusTopicProvider);
    final schedule = ref.watch(configTopicProvider);

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () {
          refreshMainScreen(ref);
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.listOfValves.length,
                padding: const EdgeInsets.symmetric(vertical: 0),
                itemBuilder: (context, index) {
                  ExpansionTileController con = ExpansionTileController();
                  conList.add(con);

                  int valve = int.parse(widget.listOfValves[index]);
                  bool valveIsOn = status['out$valve'] == 1 ? true : false;

                  // Check if there is a program for this valve.
                  Program? program =
                      ref.read(programProvider).getProgram(schedule, valve);

                  // If a program for this valve exists get cycles, days, start times and name
                  List<Cycle> cycles = program != null ? program.cycles : [];
                  List<DaysOfWeek> days =
                      program != null ? stringToDaysOfWeek(program.days) : [];
                  List<Map<String, String>> mapOfTimes = program != null
                      ? ref.watch(programProvider).getTimesAsMap(program.cycles)
                      : [];
                  String name = (program != null && program.name.isNotEmpty)
                      ? program.name
                      : 'Valve ${valve.toString()}'.hardcoded;

                  // Get the next run of this valve.
                  var listOfStartTimes =
                      ref.read(programProvider).getStartTimesAsString(mapOfTimes);
                  String nextRun =
                      ref.watch(programProvider).getNextRun(days, listOfStartTimes);

                  // Get the time the valve will close
                  String? nextEnd;
                  if (nextRun.length > 4) {
                    nextEnd = ref
                        .watch(programProvider)
                        .getNextEnd(mapOfTimes, nextRun.substring(nextRun.length - 5));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      controller: con,
                      title: TileTitle(name: name, valveIsOn: valveIsOn),
                      subtitle: valveIsOn
                          ? Text(
                              nextEnd != null ? 'Closes at $nextEnd'.hardcoded : '',
                              style: const TextStyle(color: Colors.black),
                            )
                          : (cycles.isNotEmpty)
                              ? Row(
                                  children: [
                                    Text('Next run: '.hardcoded),
                                    Text(nextRun,
                                        style: TextStyles.xSmallNormal
                                            .copyWith(color: Colors.black))
                                  ],
                                )
                              : Text('No program'.hardcoded),
                      collapsedBackgroundColor:
                          valveIsOn ? Colors.lightBlue.withOpacity(0.1) : Colors.white,
                      collapsedTextColor: Colors.green[900],
                      backgroundColor: Colors.green[100]!.withOpacity(0.5),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      collapsedShape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CreateProgramScreen(
                                                valve: valve,
                                                name: name,
                                              ))).then((value) {
                                    if (value != null && value == 1) {
                                      showSnackbar(
                                          context, 'Program send to broker.'.hardcoded,
                                          icon: Icons.done, color: Colors.greenAccent);
                                    } else if (value != null && value == -1) {
                                      showSnackbar(
                                          context,
                                          'Could not send program to broker. Try again'
                                              .hardcoded,
                                          icon: Icons.clear,
                                          color: Colors.red[800]);
                                    } else if (value != null && value == 2) {
                                      showSnackbar(
                                        context,
                                        'Program deleted'.hardcoded,
                                        icon: Icons.done,
                                        color: Colors.greenAccent,
                                      );
                                    } else if (value == null) {
                                      if (ref.read(hasProgramChangedProvider)) {
                                        refreshMainScreen(ref);
                                      }
                                    }
                                  });
                                },
                                child: cycles.isEmpty
                                    ? Text('Create Program'.hardcoded)
                                    : Text('View/Edit program'.hardcoded)),
                            Switch(
                              value: valveIsOn,
                              onChanged: (value) =>
                                  ref.read(mqttControllerProvider.notifier).sendMessage(
                                        commandTopic,
                                        MqttQos.atLeastOnce,
                                        valveIsOn
                                            ? json.encode(closeValveCmd(valve))
                                            : json.encode(openValveCmd(valve)),
                                        true,
                                      ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (MediaQuery.of(context).orientation == Orientation.portrait) TextButton(
                onPressed: () {
                  if (!conList[0].isExpanded) {
                    setState(() {
                      isExpanded = true;
                    });
                    for (var con in conList) {
                      con.expand();
                    }
                  } else {
                    setState(() {
                      isExpanded = false;
                    });
                    for (var con in conList) {
                      con.collapse();
                    }
                  }
                },
                child: isExpanded
                    ? Text('Collapse all'.hardcoded)
                    : Text('Expand all'.hardcoded))
          ],
        ),
      ),
    );
  }
}
