import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/common_widgets/snackbar.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/screens/create_program_screen.dart';
import 'package:new_gardenifi_app/src/features/programs/presentation/widgets/tile_title_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

class ValvesWidget extends ConsumerStatefulWidget {
  const ValvesWidget({super.key});

  @override
  ConsumerState<ValvesWidget> createState() => _ValveCardsState();
}

class _ValveCardsState extends ConsumerState<ValvesWidget> {
  //! WTF is not update isExpanded !!!!!
  bool isExpanded = false;

  Map openValve(int valve) {
    return {"out": valve, "cmd": 1};
  }

  Map closeValve(int valve) {
    return {"out": valve, "cmd": 0};
  }

  @override
  Widget build(BuildContext context) {
    final listOfValves = ref.watch(valvesTopicProvider);
    final status = ref.watch(statusTopicProvider);
    final programs = ref.watch(configTopicProvider);

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
                itemCount: listOfValves.length,
                padding: const EdgeInsets.symmetric(vertical: 0),
                itemBuilder: (context, index) {
                  int valve = int.parse(listOfValves[index]);
                  bool valveIsOn = status['out${index + 1}'] == 1 ? true : false;

                  // Get cycle times and sort them before appear to UI
                  List<String>? cycleTimesList = [];
                  for (var program in programs) {
                    if (program.out == valve) {
                      // TODO: Do i need it? it returns a sorted string with start times
                      cycleTimesList = createSortedTimeTexts(program);
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: TileTitle(valve: valve, valveIsOn: valveIsOn),
                      subtitle: valveIsOn
                          ? const Text(
                              'Close at...',
                              style: TextStyle(color: Colors.black),
                            )
                          : Column(
                              children: [
                                // ...cycleTimesList
                                if (cycleTimesList!.isNotEmpty)
                                  Text('Next run at ${cycleTimesList[0]}')
                              ],
                            ),
                      initiallyExpanded: isExpanded,
                      collapsedBackgroundColor: Colors.white,
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
                                              ))).then((value) {
                                    if (value) {
                                      showSnackbar(context, 'Program send to broker.',
                                          Icons.done, Colors.greenAccent);
                                    } else {
                                      showSnackbar(
                                          context,
                                          'Could not send program to broker. Try again',
                                          Icons.clear,
                                          Colors.red[800]);
                                    }
                                  });
                                },
                                child: cycleTimesList!.isEmpty
                                    ? const Text('Create Program')
                                    : const Text('Edit program')),
                            Switch(
                              value: valveIsOn,
                              onChanged: (value) =>
                                  ref.read(mqttControllerProvider.notifier).sendMessage(
                                        commandTopic,
                                        MqttQos.atLeastOnce,
                                        valveIsOn
                                            ? json.encode(closeValve(valve))
                                            : json.encode(openValve(valve)),
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
            TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = true;
                  });
                },
                child: Text('Expand all'.hardcoded))
          ],
        ),
      ),
    );
  }
}
