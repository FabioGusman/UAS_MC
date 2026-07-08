import 'package:flutter/material.dart';
import '../models/progress.dart';

class CustomWeightChartPainter extends CustomPainter {
  final List<WeightLog> logs;

  CustomWeightChartPainter({required this.logs});

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;

    final paintLine = Paint()
      ..color = const Color(0xFFFFD700) // Amber Gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintDot = Paint()
      ..color = const Color(0xFFFFA500) // Orange
      ..style = PaintingStyle.fill;

    final paintDotOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintGrid = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Tambahkan margin di sekeliling area menggambar grafik
    const double paddingX = 24.0;
    const double paddingY = 24.0;

    final double width = size.width - (paddingX * 2);
    final double height = size.height - (paddingY * 2);

    // Temukan berat minimal dan maksimal untuk penskalaan sumbu Y
    double minWeight = logs.first.weight;
    double maxWeight = logs.first.weight;

    for (var log in logs) {
      if (log.weight < minWeight) minWeight = log.weight;
      if (log.weight > maxWeight) maxWeight = log.weight;
    }

    // Hindari pembagian dengan nol jika berat badan sama semua
    if (minWeight == maxWeight) {
      minWeight -= 5;
      maxWeight += 5;
    } else {
      // Tambahkan padding di atas dan bawah sumbu Y
      final diff = maxWeight - minWeight;
      minWeight -= diff * 0.15;
      maxWeight += diff * 0.15;
    }

    final double weightRange = maxWeight - minWeight;
    final int dataCount = logs.length;

    // 1. Gambar Garis Grid Horizontal
    const int gridLinesCount = 3;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = paddingY + (height * i / gridLinesCount);
      canvas.drawLine(
        Offset(paddingX, y),
        Offset(size.width - paddingX, y),
        paintGrid,
      );

      // Gambar label berat badan di samping grid
      final double gridWeight = maxWeight - (weightRange * i / gridLinesCount);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${gridWeight.toStringAsFixed(1)} kg',
          style: const TextStyle(color: Colors.grey, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingX - 22, y - 6));
    }

    // 2. Hitung Titik-titik Koordinat (X, Y)
    final List<Offset> points = [];
    for (int i = 0; i < dataCount; i++) {
      final log = logs[i];
      // Petakan X berdasarkan indeks log
      final double x = paddingX + (width * i / (dataCount - 1));
      // Petakan Y berdasarkan nilai berat badan (Y terbalik di sistem Canvas)
      final double y = paddingY + height - (height * (log.weight - minWeight) / weightRange);
      points.add(Offset(x, y));
    }

    // 3. Gambar Garis Penghubung antar Titik
    final Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paintLine);

    // 4. Gambar Bulatan Titik Data & Teks Nilainya
    for (int i = 0; i < points.length; i++) {
      final offset = points[i];
      final log = logs[i];

      // Gambar titik
      canvas.drawCircle(offset, 5.0, paintDot);
      canvas.drawCircle(offset, 5.0, paintDotOutline);

      // Gambar nilai berat badan di atas titik
      final valuePainter = TextPainter(
        text: TextSpan(
          text: '${log.weight} kg',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(offset.dx - (valuePainter.width / 2), offset.dy - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomWeightChartPainter oldDelegate) {
    return oldDelegate.logs != logs;
  }
}
