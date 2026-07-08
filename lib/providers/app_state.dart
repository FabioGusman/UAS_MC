import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/workout.dart';
import '../models/progress.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  List<WorkoutSession> _workouts = [];
  List<WeightLog> _weightLogs = [];
  List<ProgressPhoto> _progressPhotos = [];
  
  String _quoteText = "Disiplin adalah jembatan antara tujuan dan pencapaian.";
  String _quoteAuthor = "Jim Rohn";
  bool _isLoadingQuote = false;

  // Getters
  User? get currentUser => _currentUser;
  List<WorkoutSession> get workouts => _workouts;
  List<WeightLog> get weightLogs => _weightLogs;
  List<ProgressPhoto> get progressPhotos => _progressPhotos;
  String get quoteText => _quoteText;
  String get quoteAuthor => _quoteAuthor;
  bool get isLoadingQuote => _isLoadingQuote;

  // --- ACTIONS ---

  // Login
  Future<bool> login(String email, String password) async {
    final user = HiveService.loginUser(email, password);
    if (user != null) {
      _currentUser = user;
      
      // Load data user dari Hive
      _workouts = HiveService.getWorkouts(email);
      _weightLogs = HiveService.getWeightLogs(email);
      _progressPhotos = HiveService.getProgressPhotos(email);
      
      notifyListeners();
      
      // Ambil quote baru secara asinkronus
      loadMotivationalQuote();
      return true;
    }
    return false;
  }

  // Register
  Future<bool> register(String username, String email, String password) async {
    final newUser = User(
      username: username,
      email: email,
      password: password,
      currentWeight: 0,
      targetWeight: 0,
    );
    return await HiveService.registerUser(newUser);
  }

  // Logout
  void logout() {
    _currentUser = null;
    _workouts = [];
    _weightLogs = [];
    _progressPhotos = [];
    notifyListeners();
  }

  // Update Target Berat / Foto Profil
  Future<void> updateProfile({double? targetWeight, String? profileImagePath}) async {
    if (_currentUser == null) return;
    
    final updatedUser = _currentUser!.copyWith(
      targetWeight: targetWeight ?? _currentUser!.targetWeight,
      profileImagePath: profileImagePath ?? _currentUser!.profileImagePath,
    );
    
    await HiveService.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Tambah Sesi Latihan
  Future<void> addWorkout(String splitName, List<ExerciseLog> exercises) async {
    if (_currentUser == null) return;
    
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      splitName: splitName,
      exercises: exercises,
    );
    
    await HiveService.saveWorkout(_currentUser!.email, session);
    _workouts.add(session);
    notifyListeners();
  }

  // Tambah Catatan Berat Badan
  Future<void> addWeightLog(double weight) async {
    if (_currentUser == null) return;
    
    final log = WeightLog(
      date: DateTime.now(),
      weight: weight,
    );
    
    await HiveService.saveWeightLog(_currentUser!.email, log);
    
    // Reload log berat badan & data user terbaru (current weight diperbarui di HiveService)
    _weightLogs = HiveService.getWeightLogs(_currentUser!.email);
    
    // Sinkronisasi local state user dengan data Hive terupdate
    final rawUser = HiveService.loginUser(_currentUser!.email, _currentUser!.password);
    if (rawUser != null) {
      _currentUser = rawUser;
    }
    
    notifyListeners();
  }

  // Tambah Foto Progress Fisik
  Future<void> addProgressPhoto(String imagePath) async {
    if (_currentUser == null) return;
    
    final photo = ProgressPhoto(
      date: DateTime.now(),
      imagePath: imagePath,
    );
    
    await HiveService.saveProgressPhoto(_currentUser!.email, photo);
    _progressPhotos.insert(0, photo); // Letakkan foto terbaru di atas
    notifyListeners();
  }

  // Load Kutipan dari API
  Future<void> loadMotivationalQuote() async {
    _isLoadingQuote = true;
    notifyListeners();

    try {
      final quote = await ApiService.fetchMotivationalQuote();
      _quoteText = quote['quote'] ?? _quoteText;
      _quoteAuthor = quote['author'] ?? _quoteAuthor;
    } catch (e) {
      print('Gagal mengambil quote dari provider: $e');
    } finally {
      _isLoadingQuote = false;
      notifyListeners();
    }
  }
}
