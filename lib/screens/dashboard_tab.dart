import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Future<void> _changeProfileImage(BuildContext context) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pilih Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFFFFD700)),
              title: const Text('Kamera (Ambil Foto)', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                  if (photo != null) {
                    if (context.mounted) {
                      Provider.of<AppState>(context, listen: false).updateProfile(profileImagePath: photo.path);
                    }
                  }
                } catch (e) {
                  debugPrint('Error mengambil foto profil: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFFFD700)),
              title: const Text('Galeri (Pilih Foto)', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  final XFile? photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (photo != null) {
                    if (context.mounted) {
                      Provider.of<AppState>(context, listen: false).updateProfile(profileImagePath: photo.path);
                    }
                  }
                } catch (e) {
                  debugPrint('Error memilih foto profil: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final totalWorkouts = appState.workouts.length;
    final lastWorkout = appState.workouts.isNotEmpty ? appState.workouts.last.splitName : 'Belum Ada';

    final hasProfileImage = user?.profileImagePath != null &&
        user!.profileImagePath!.isNotEmpty &&
        (kIsWeb || File(user.profileImagePath!).existsSync());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header profil singkat
          Row(
            children: [
              GestureDetector(
                onTap: () => _changeProfileImage(context),
                child: Tooltip(
                  message: 'Ubah Foto Profil',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFFD700),
                    backgroundImage: hasProfileImage
                        ? (kIsWeb
                            ? NetworkImage(user.profileImagePath!)
                            : FileImage(File(user.profileImagePath!))) as ImageProvider
                        : null,
                    child: !hasProfileImage
                        ? const Icon(Icons.person, size: 36, color: Colors.black)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Latihan,',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    Text(
                      user?.username ?? 'Atlet',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Tombol refresh quote
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
                tooltip: 'Refresh Motivasi',
                onPressed: () => appState.loadMotivationalQuote(),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Card Motivasi (External API)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.format_quote, color: Color(0xFFFFD700), size: 30),
                    SizedBox(width: 8),
                    Text(
                      'Fokus Hari Ini',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFD700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appState.isLoadingQuote)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    ),
                  )
                else ...[
                  Text(
                    '"${appState.quoteText}"',
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '- ${appState.quoteAuthor}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistik Ringkas (Usability & Layout Indah)
          const Text(
            'Ringkasan Kebugaran',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              // Card Total Workout
              _buildStatCard(
                icon: Icons.fitness_center,
                title: 'Total Latihan',
                value: '$totalWorkouts Sesi',
                color: Colors.orangeAccent,
              ),
              // Card Split Terakhir
              _buildStatCard(
                icon: Icons.calendar_today,
                title: 'Hari Latihan Terakhir',
                value: lastWorkout,
                color: Colors.greenAccent,
              ),
              // Card Berat Badan Saat Ini
              _buildStatCard(
                icon: Icons.monitor_weight_outlined,
                title: 'Berat Saat Ini',
                value: user?.currentWeight != null && user!.currentWeight! > 0
                    ? '${user.currentWeight} kg'
                    : '-',
                color: Colors.blueAccent,
              ),
              // Card Target Berat
              _buildStatCard(
                icon: Icons.flag_outlined,
                title: 'Target Berat',
                value: user?.targetWeight != null && user!.targetWeight! > 0
                    ? '${user.targetWeight} kg'
                    : 'Belum Diatur',
                color: Colors.pinkAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tips Kebugaran Harian
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFFFD700), size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Hari Ini: Progressive Overload',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cobalah tingkatkan beban, repetisi, atau set secara berkala pada setiap gerakan latihan untuk hasil otot maksimal.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }
}
