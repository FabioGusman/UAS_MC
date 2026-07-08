import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  // Fallback quote list ketika offline atau terjadi error API
  static const List<Map<String, String>> _fallbackQuotes = [
    {
      'quote': "Disiplin adalah jembatan antara tujuan dan pencapaian Anda.",
      'author': "Jim Rohn"
    },
    {
      'quote': "Satu-satunya hari latihan yang buruk adalah hari latihan yang tidak Anda lakukan.",
      'author': "Anonim"
    },
    {
      'quote': "Rasa sakit yang Anda rasakan hari ini akan menjadi kekuatan yang Anda rasakan besok.",
      'author': "Arnold Schwarzenegger"
    },
    {
      'quote': "Jangan batasi tantangan Anda. Tantang batasan Anda.",
      'author': "Jerry Dunn"
    },
    {
      'quote': "Konsistensi adalah apa yang mengubah rata-rata menjadi luar biasa.",
      'author': "Anonim"
    },
    {
      'quote': "Kebugaran bukan tentang menjadi lebih baik dari orang lain. Ini tentang menjadi lebih baik dari diri Anda sebelumnya.",
      'author': "Anonim"
    }
  ];

  // Mengambil kutipan motivasi harian
  static Future<Map<String, String>> fetchMotivationalQuote() async {
    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final first = data[0];
          return {
            'quote': first['q'] as String,
            'author': first['a'] as String,
          };
        }
      }
    } catch (e) {
      // Jika terjadi error koneksi, time-out, dll., kita gunakan fallback lokal
      print('Quote API error, using fallback: $e');
    }

    // Mengambil quote secara acak dari fallback list
    final random = Random();
    return _fallbackQuotes[random.nextInt(_fallbackQuotes.length)];
  }
}
