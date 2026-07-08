import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/app_state.dart';
import '../models/progress.dart';
import '../widgets/custom_chart.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  // Mengambil gambar (Kamera atau Galeri)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompresi agar hemat memori
      );

      if (!mounted) return;

      if (photo != null) {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.addProgressPhoto(photo.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto progress berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pilih Sumber Foto Progres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFFFFD700)),
              title: const Text('Kamera (Ambil Foto)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFFFFD700)),
              title: const Text('Galeri (Pilih Foto)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Menyimpan Log Berat Badan Baru
  void _saveWeightLog() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    _weightController.clear();
    FocusScope.of(context).unfocus();

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.addWeightLog(weight);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berat badan berhasil dicatat!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Dialog untuk Mengubah Target Berat Badan
  void _showSetTargetDialog() {
    final targetController = TextEditingController(
      text: Provider.of<AppState>(context, listen: false).currentUser?.targetWeight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur Target Berat Badan'),
        content: TextField(
          controller: targetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Target (kg)',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final target = double.tryParse(targetController.text) ?? 0.0;
              if (target > 0) {
                Provider.of<AppState>(context, listen: false).updateProfile(targetWeight: target);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Target berat badan diperbarui!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  // Menampilkan Foto Fullscreen
  void _viewPhotoFullscreen(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: kIsWeb
                  ? Image.network(
                      path,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Image.file(
                      File(path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
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
    final List<WeightLog> weightLogs = appState.weightLogs;
    final List<ProgressPhoto> progressPhotos = appState.progressPhotos;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Target & Berat Saat ini
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Berat Saat Ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        user?.currentWeight != null && user!.currentWeight! > 0
                            ? '${user.currentWeight} kg'
                            : '-',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showSetTargetDialog,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Target Berat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, color: const Color(0xFFFFD700).withOpacity(0.7), size: 12),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.targetWeight != null && user!.targetWeight! > 0
                              ? '${user.targetWeight} kg'
                              : 'Atur Target',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form Log Berat Badan
          Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Catat Berat Baru (kg)',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Kosong';
                      if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Error';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveWeightLog,
                    child: const Icon(Icons.save_outlined),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Grafik Tren Berat Badan
          const Text('Tren Berat Badan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: weightLogs.length < 2
                ? const Center(
                    child: Text(
                      'Masukkan minimal 2 catatan berat badan\nuntuk melihat grafik tren.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : CustomPaint(
                    painter: CustomWeightChartPainter(logs: weightLogs),
                  ),
          ),
          const SizedBox(height: 28),

          // Physique Check-in Section (Camera Feature)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Foto Progress Fisik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFFFFD700)),
                label: const Text('Ambil Foto', style: TextStyle(color: Color(0xFFFFD700))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          progressPhotos.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey[750]),
                      const SizedBox(height: 8),
                      const Text(
                        'Belum ada foto progress.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ambil foto tubuh secara berkala untuk memantau perubahan bentuk fisik Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: progressPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = progressPhotos[index];
                    final dateStr = DateFormat('d MMM yy').format(photo.date);

                    return GestureDetector(
                      onTap: () => _viewPhotoFullscreen(photo.imagePath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            kIsWeb
                                ? Image.network(
                                    photo.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[850],
                                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                                    ),
                                  )
                                : Image.file(
                                    File(photo.imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[850],
                                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                                    ),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.6),
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Text(
                                  dateStr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 28),

          // Riwayat Berat Badan (List)
          if (weightLogs.isNotEmpty) ...[
            const Text('Riwayat Catatan Berat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weightLogs.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Colors.grey),
              itemBuilder: (context, index) {
                // Tampilkan dari data terbaru (reverse order)
                final log = weightLogs[weightLogs.length - 1 - index];
                final dateStr = DateFormat('d MMMM yyyy').format(log.date);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr, style: const TextStyle(color: Colors.white70)),
                      Text(
                        '${log.weight} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
