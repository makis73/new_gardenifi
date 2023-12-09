import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:new_gardenifi_app/src/constants/mqtt_constants.dart';
import 'package:new_gardenifi_app/src/features/mqtt/presentation/mqtt_controller.dart';

// {'valves': ['1', '2', '3', '4'], 'out1': 0, 'out2': 0, 'out3': 0, 'out4': 1, 'server_time': '2023/12/08 21:51:14', 'tz': 'UTC', 'hw_id': '100000005fd258b6'}

class ValveCard extends ConsumerWidget {
  const ValveCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listOfValves = ref.watch(valvesTopicProvider);
    final status = ref.watch(statusTopicProvider);
//
    return Expanded(
      child:listOfValves.isEmpty ? Center(child: Text('No valves'),) : ListView.builder(
        itemCount: listOfValves.length,
        padding: EdgeInsets.symmetric(vertical: 0),
        itemBuilder: (context, index) {
          int valve = int.parse(listOfValves[index]);
          bool valveIsOn = status['out${index + 1}'] == 1 ? true : false;

          Map onStatusMap = {"out": valve, "cmd": 1};
          Map offStatusMap = {"out": valve, "cmd": 0};
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text('Valve ${valve.toString()}'),
              subtitle: Text('$valveIsOn'),
              collapsedBackgroundColor: Colors.white,
              // backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              collapsedShape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              children: [
                Row(
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
    );
  }
}