import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import 'add_workout_screen.dart';

class WorkoutTab extends StatelessWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final workouts = appState.workouts.reversed.toList(); // Sesi latihan terbaru paling atas

    return Scaffold(
      body: workouts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 100,
                      color: Colors.grey[850],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Catatan Latihan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Rencanakan workout split harian Anda dan catat beban serta repetisi gerakan Anda secara teratur di sini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Catat Latihan Pertama'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final session = workouts[index];
                final formattedDate = DateFormat('EEEE, d MMM yyyy - HH:mm', 'id').format(session.date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center, color: Color(0xFFFFD700)),
                    ),
                    title: Text(
                      session.splitName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    childrenPadding: const EdgeInsets.all(16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, thickness: 0.5, color: Colors.grey),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: session.exercises.length,
                        itemBuilder: (context, exIndex) {
                          final exercise = session.exercises[exIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${exIndex + 1}. ${exercise.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFFFD700)),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: exercise.sets.asMap().entries.map((entry) {
                                    final setIndex = entry.key + 1;
                                    final setLog = entry.value;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C2C2C),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Set $setIndex: ${setLog.weight} kg × ${setLog.reps} rep',
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: workouts.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
                );
              },
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
