import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';
import 'package:new_gardenifi_app/utils.dart';

// {'valves': ['1', '2', '3', '4'], 'out1': 0, 'out2': 0, 'out3': 0, 'out4': 1, 'server_time': '2023/12/08 21:51:14', 'tz': 'UTC', 'hw_id': '100000005fd258b6'}

class ValveCards extends ConsumerStatefulWidget {
  const ValveCards({super.key});

  @override
  ConsumerState<ValveCards> createState() => _ValveCardsState();
}

class _ValveCardsState extends ConsumerState<ValveCards> {
  //! WTF is not update isExpanded !!!!!
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final listOfValves = ref.watch(valvesTopicProvider);
    final status = ref.watch(statusTopicProvider);
//
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

                  Map onStatusMap = {"out": valve, "cmd": 1};
                  Map offStatusMap = {"out": valve, "cmd": 0};
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Text(
                            'Valve ${valve.toString()}',
                            style: TextStyles.mediumBold,
                          ),
                          gapW20,
                          if (valveIsOn)
                            const Icon(
                              Icons.autorenew,
                              color: Colors.green,
                            ),
                        ],
                      ),
                      subtitle: valveIsOn
                          ? const Text(
                              'Close at...',
                              style: TextStyle(color: Colors.black),
                            )
                          : null,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Switch(
                              value: valveIsOn,
                              onChanged: (value) =>
                                  ref.read(mqttControllerProvider.notifier).sendMessage(
                                        commandTopic,
                                        MqttQos.atLeastOnce,
                                        valveIsOn
                                            ? json.encode(offStatusMap)
                                            : json.encode(onStatusMap),
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
