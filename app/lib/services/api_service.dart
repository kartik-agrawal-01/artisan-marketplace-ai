import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.0.106:8000";

  /// Sends compressed image bytes to FastAPI and gets back AI-modified versions
  static Future<Map<String, Uint8List>> cleanImage(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ai/clean-image'),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'upload.jpg',
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final jsonResponse = json.decode(body);

      return {
        "transparent": base64Decode(jsonResponse["transparent_png_base64"]),
        "studio": base64Decode(jsonResponse["studio_background_base64"]),
      };
    } else {
      throw Exception("Failed with status ${response.statusCode}");
    }
  }
  static Future<Map<String, dynamic>> enhanceDescription({
    required String title,
    required String description,
    required String language,
    required String category,
  }) async {
    final url = Uri.parse('$baseUrl/ai/enhance-description');

    final body = {
      "title": title,
      "description": description,
      "language": language,
      "category": category,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed with status ${response.statusCode}: ${response.body}");
    }
  }
}
