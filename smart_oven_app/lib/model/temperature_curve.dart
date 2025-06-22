class TemperatureCurve {
  final String id;
  final String name;
  final DateTime date;
  final List<double> temperatures;
  final List<double> times;

  TemperatureCurve({
    required this.id,
    required this.name,
    required this.date,
    required this.temperatures,
    required this.times,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'temperatures': temperatures,
    'times': times,
  };

  factory TemperatureCurve.fromJson(Map<String, dynamic> json) =>
      TemperatureCurve(
        id: json['id'],
        name: json['name'],
        date: DateTime.parse(json['date']),
        temperatures: List<double>.from(json['temperatures']),
        times: List<double>.from(json['times']),
      );
}
