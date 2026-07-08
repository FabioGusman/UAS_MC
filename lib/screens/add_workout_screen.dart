import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/workout.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _splitNameController = TextEditingController();

  // Menyimpan struktur data latihan dinamis:
  // [
  //   {
  //     'nameController': TextEditingController(),
  //     'sets': [
  //       { 'weightController': TextEditingController(), 'repsController': TextEditingController() }
  //     ]
  //   }
  // ]
  final List<Map<String, dynamic>> _exercises = [];

  @override
  void initState() {
    super.initState();
    // Tambahkan 1 latihan default saat halaman dibuka pertama kali
    _addExercise();
  }

  @override
  void dispose() {
    _splitNameController.dispose();
    for (var ex in _exercises) {
      ex['nameController'].dispose();
      for (var set in ex['sets']) {
        set['weightController'].dispose();
        set['repsController'].dispose();
      }
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add({
        'nameController': TextEditingController(),
        'sets': [
          {
            'weightController': TextEditingController(),
            'repsController': TextEditingController()
          }
        ]
      });
    });
  }

  void _removeExercise(int index) {
    setState(() {
      final ex = _exercises.removeAt(index);
      ex['nameController'].dispose();
      for (var set in ex['sets']) {
        set['weightController'].dispose();
        set['repsController'].dispose();
      }
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _exercises[exerciseIndex]['sets'].add({
        'weightController': TextEditingController(),
        'repsController': TextEditingController()
      });
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      final set = _exercises[exerciseIndex]['sets'].removeAt(setIndex);
      set['weightController'].dispose();
      set['repsController'].dispose();
    });
  }

  void _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 gerakan latihan!'), backgroundColor: Colors.red),
      );
      return;
    }

    final List<ExerciseLog> exerciseLogs = [];
    for (var ex in _exercises) {
      final name = ex['nameController'].text.trim();
      final List<ExerciseSet> sets = [];

      for (var set in ex['sets']) {
        final weight = double.parse(set['weightController'].text);
        final reps = int.parse(set['repsController'].text);
        sets.add(ExerciseSet(weight: weight, reps: reps));
      }

      exerciseLogs.add(ExerciseLog(name: name, sets: sets));
    }

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.addWorkout(_splitNameController.text.trim(), exerciseLogs);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi latihan berhasil disimpan!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke halaman utama
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Latihan Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFFFD700)),
            onPressed: _saveWorkout,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Split Name Input di paling atas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _splitNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Split Hari Latihan (misal: Push Day, Legs)',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama split tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
            const Divider(),

            // List gerakan latihan dinamis
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _exercises.length,
                itemBuilder: (context, exIndex) {
                  final exercise = _exercises[exIndex];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[850]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Judul Latihan & Tombol Hapus Gerakan
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFFFFD700),
                                child: Text(
                                  '${exIndex + 1}',
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: exercise['nameController'],
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Gerakan (misal: Bench Press)',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama gerakan tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (_exercises.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _removeExercise(exIndex),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Header Set Tabel
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                Expanded(child: Text('Beban (kg)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                SizedBox(width: 16),
                                Expanded(child: Text('Repetisi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // List input per Set
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: exercise['sets'].length,
                            itemBuilder: (context, setIndex) {
                              final setItem = exercise['sets'][setIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    // Set Number
                                    SizedBox(
                                      width: 40,
                                      child: Center(
                                        child: Text(
                                          '#${setIndex + 1}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    // Weight Input
                                    Expanded(
                                      child: TextFormField(
                                        controller: setItem['weightController'],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(8),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Kosong';
                                          if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Error';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Reps Input
                                    Expanded(
                                      child: TextFormField(
                                        controller: setItem['repsController'],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(8),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Kosong';
                                          if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Error';
                                          return null;
                                        },
                                      ),
                                    ),
                                    // Delete Set Button
                                    SizedBox(
                                      width: 40,
                                      child: exercise['sets'].length > 1
                                          ? IconButton(
                                              icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                                              onPressed: () => _removeSet(exIndex, setIndex),
                                            )
                                          : const SizedBox(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Tombol Tambah Set
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => _addSet(exIndex),
                              icon: const Icon(Icons.add, size: 18, color: Color(0xFFFFD700)),
                              label: const Text(
                                'Tambah Set',
                                style: TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tombol Tambah Gerakan di paling bawah
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add, color: Color(0xFFFFD700)),
                      label: const Text(
                        'TAMBAH GERAKAN BARU',
                        style: TextStyle(color: Color(0xFFFFD700)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveWorkout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: const Text('SIMPAN'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
