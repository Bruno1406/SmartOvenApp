class TemperatureCurve {
  final String name;
  final double targetTemperature;
  final double finalTemperature;
  final double heatingTime;
  final double holdTime;
  final double coolingTime;
  final List<double> times;
  final List<double> temperatures;
  final DateTime createdAt;

  TemperatureCurve({
    required this.name,
    required this.targetTemperature,
    required this.finalTemperature,
    required this.heatingTime,
    required this.holdTime,
    required this.coolingTime,
    required this.times,
    required this.temperatures,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'targetTemperature': targetTemperature,
    'finalTemperature': finalTemperature,
    'heatingTime': heatingTime,
    'holdTime': holdTime,
    'coolingTime': coolingTime,
    'times': times,
    'temperatures': temperatures,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TemperatureCurve.fromJson(Map<String, dynamic> json) {
    return TemperatureCurve(
      name: json['name'],
      targetTemperature: (json['targetTemperature'] ?? 0).toDouble(),
      finalTemperature: (json['finalTemperature'] ?? 0).toDouble(),
      heatingTime: (json['heatingTime'] ?? 0).toDouble(),
      holdTime: (json['holdTime'] ?? 0).toDouble(),
      coolingTime: (json['coolingTime'] ?? 0).toDouble(),
      times: List<double>.from(
        (json['times'] as List).map((e) => (e as num).toDouble()),
      ),
      temperatures: List<double>.from(
        (json['temperatures'] as List).map((e) => (e as num).toDouble()),
      ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
