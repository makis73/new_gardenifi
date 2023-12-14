import 'dart:convert';
import 'dart:developer';

import 'package:new_gardenifi_app/utils.dart';

class Cycle {
  String startTime;
  String duration;
  bool isCycleRunning;

  Cycle({
    required this.startTime,
    required this.duration,
    required this.isCycleRunning,
  });

  // clone() =>
  //     Cycle(startTime: startTime, duration: duration, isCycleRunning: isCycleRunning);

  // Cycle.fromJson(Map<String, dynamic> json)
  //     : startTime = json['start'],
  //       duration = json['min'],
  //       isCycleRunning = json['isCycleRunning'];

  // Map<String, dynamic> toJson() => {
  //       'start': startTime,
  //       'min': duration,
  //       'isCycleRunning': isCycleRunning,
  //     };

  @override
  String toString() =>
      'Cycle(startTime: $startTime, duration: $duration, isCycleRunning: $isCycleRunning)';

  Cycle copyWith({
    String? startTime,
    String? duration,
    bool? isCycleRunning,
  }) {
    return Cycle(
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      isCycleRunning: isCycleRunning ?? this.isCycleRunning,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    

    result.addAll({'startTime': startTime});
    result.addAll({'duration': duration});
    result.addAll({'isCycleRunning': isCycleRunning});

    return result;
  }

  factory Cycle.fromMap(Map<String, dynamic> map) {
    // Convert the UTC time to local time
    var localTime = utcToLocal(map['start']);
    return Cycle(
      startTime: localTime,
      duration: map['min'] ?? '',
      isCycleRunning: map['isCycleRunning'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cycle.fromJson(String source) => Cycle.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Cycle &&
        other.startTime == startTime &&
        other.duration == duration &&
        other.isCycleRunning == isCycleRunning;
  }

  @override
  int get hashCode => startTime.hashCode ^ duration.hashCode ^ isCycleRunning.hashCode;
}
