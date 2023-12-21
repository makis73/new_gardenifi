class Cycle {
  String start;
  String min;

  Cycle({
    required this.start,
    this.min = '',
  });

  factory Cycle.fromJson(Map<String, dynamic> data) {
    final start = data['start'];
    if (start is! String) {
      throw FormatException(
          'Invalid JSON: requird "start" field of type String in $data');
    }
    final min = data['min'] as String;
    return Cycle(start: start, min: min);
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'min': min,
    };
  }

  Cycle copyWith({
    String? startTime,
    String? duration,
    bool? cycleRunning,
  }) {
    return Cycle(
      start: startTime ?? start,
      min: duration ?? min,
    );
  }

  @override
  String toString() => 'Cycle(start: $start, min: $min)';
}
