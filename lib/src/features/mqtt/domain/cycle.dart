class Cycle {
  String startTime;
  String duration;
  bool isCycleRunning;

  Cycle({
    required this.startTime,
    required this.duration,
    required this.isCycleRunning,
  });

  clone() => Cycle(
      startTime: startTime, duration: duration, isCycleRunning: isCycleRunning);

  Cycle.fromJson(Map<String, dynamic> json)
      : startTime = json['start'],
        duration = json['min'],
        isCycleRunning = json['isCycleRunning'];

  Map<String, dynamic> toJson() => {
        'start': startTime,
        'min': duration,
        'isCycleRunning': isCycleRunning,
      };
}
