class WorkoutSession {
  final String id;
  final DateTime date;
  final String splitName; // e.g. "Push Day", "Legs"
  final List<ExerciseLog> exercises;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.splitName,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'splitName': splitName,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutSession.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      splitName: map['splitName'] as String,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => ExerciseLog.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ExerciseLog {
  final String name;
  final List<ExerciseSet> sets;

  ExerciseLog({
    required this.name,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory ExerciseLog.fromMap(Map<dynamic, dynamic> map) {
    return ExerciseLog(
      name: map['name'] as String,
      sets: (map['sets'] as List<dynamic>?)
              ?.map((s) => ExerciseSet.fromMap(s as Map<dynamic, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ExerciseSet {
  final double weight;
  final int reps;

  ExerciseSet({
    required this.weight,
    required this.reps,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'reps': reps,
    };
  }

  factory ExerciseSet.fromMap(Map<dynamic, dynamic> map) {
    return ExerciseSet(
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
    );
  }
}
