class WeightLog {
  final DateTime date;
  final double weight;

  WeightLog({
    required this.date,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }

  factory WeightLog.fromMap(Map<dynamic, dynamic> map) {
    return WeightLog(
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}

class ProgressPhoto {
  final DateTime date;
  final String imagePath;

  ProgressPhoto({
    required this.date,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory ProgressPhoto.fromMap(Map<dynamic, dynamic> map) {
    return ProgressPhoto(
      date: DateTime.parse(map['date'] as String),
      imagePath: map['imagePath'] as String,
    );
  }
}
