import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/workout.dart';
import '../models/progress.dart';

class HiveService {
  static const String _userBoxName = 'userBox';
  static const String _workoutBoxName = 'workoutBox';
  static const String _progressBoxName = 'progressBox';

  // Inisialisasi Box
  static Future<void> init() async {
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_workoutBoxName);
    await Hive.openBox(_progressBoxName);
  }

  // --- AUTHENTICATION ---

  // Daftar User Baru
  static Future<bool> registerUser(User user) async {
    final box = Hive.box(_userBoxName);
    if (box.containsKey(user.email)) {
      return false; // Email sudah terdaftar
    }
    await box.put(user.email, user.toMap());
    return true;
  }

  // Login User
  static User? loginUser(String email, String password) {
    final box = Hive.box(_userBoxName);
    final userData = box.get(email);
    if (userData != null) {
      final userMap = Map<dynamic, dynamic>.from(userData as Map);
      final user = User.fromMap(userMap);
      if (user.password == password) {
        return user;
      }
    }
    return null;
  }

  // Update Profile User (misal target berat badan, foto profil)
  static Future<void> updateUser(User user) async {
    final box = Hive.box(_userBoxName);
    await box.put(user.email, user.toMap());
  }

  // --- WORKOUT SPLITS & LOGS ---

  // Simpan Sesi Latihan Baru
  static Future<void> saveWorkout(String email, WorkoutSession session) async {
    final box = Hive.box(_workoutBoxName);
    final key = 'workouts_$email';
    final existingData = box.get(key) as List<dynamic>? ?? [];
    final newList = List<dynamic>.from(existingData)..add(session.toMap());
    await box.put(key, newList);
  }

  // Ambil Semua Sesi Latihan
  static List<WorkoutSession> getWorkouts(String email) {
    final box = Hive.box(_workoutBoxName);
    final key = 'workouts_$email';
    final rawData = box.get(key) as List<dynamic>?;
    if (rawData == null) return [];
    return rawData
        .map((e) => WorkoutSession.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  // --- PROGRESS TRACKER (WEIGHT & PHOTOS) ---

  // Simpan Catatan Berat Badan
  static Future<void> saveWeightLog(String email, WeightLog log) async {
    final box = Hive.box(_progressBoxName);
    final key = 'weight_$email';
    final existingData = box.get(key) as List<dynamic>? ?? [];
    final newList = List<dynamic>.from(existingData)..add(log.toMap());
    await box.put(key, newList);

    // Update berat badan saat ini di profile user
    final userBox = Hive.box(_userBoxName);
    final userData = userBox.get(email);
    if (userData != null) {
      final user = User.fromMap(Map<dynamic, dynamic>.from(userData as Map));
      final updatedUser = user.copyWith(currentWeight: log.weight);
      await updateUser(updatedUser);
    }
  }

  // Ambil Catatan Berat Badan (urut kronologis)
  static List<WeightLog> getWeightLogs(String email) {
    final box = Hive.box(_progressBoxName);
    final key = 'weight_$email';
    final rawData = box.get(key) as List<dynamic>?;
    if (rawData == null) return [];
    final list = rawData
        .map((e) => WeightLog.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    // Sort berdasarkan tanggal terkecil ke terbesar
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  // Simpan Foto Progress Fisik (Camera Feature)
  static Future<void> saveProgressPhoto(String email, ProgressPhoto photo) async {
    final box = Hive.box(_progressBoxName);
    final key = 'photos_$email';
    final existingData = box.get(key) as List<dynamic>? ?? [];
    final newList = List<dynamic>.from(existingData)..add(photo.toMap());
    await box.put(key, newList);
  }

  // Ambil Semua Foto Progress Fisik
  static List<ProgressPhoto> getProgressPhotos(String email) {
    final box = Hive.box(_progressBoxName);
    final key = 'photos_$email';
    final rawData = box.get(key) as List<dynamic>?;
    if (rawData == null) return [];
    final list = rawData
        .map((e) => ProgressPhoto.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    // Urutkan berdasarkan tanggal terbaru dahulu
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
