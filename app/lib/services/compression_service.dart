import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CompressionService {
  /// Compresses image bytes and saves as a [File].
  static Future<File> compress(Uint8List bytes, {String fileName = "compressed.jpg"}) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, fileName);

    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800, // higher resolution for saved file
      minHeight: 800,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    final compressedFile = File(targetPath);
    await compressedFile.writeAsBytes(result);
    return compressedFile;
  }

  /// Compresses and returns [Uint8List] directly (useful for Firestore).
  static Future<Uint8List> compressToBytes(Uint8List bytes) async {
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 600, // smaller for Firestore safety
      minHeight: 600,
      quality: 60,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  /// Converts bytes into base64 string.
  static String toBase64(Uint8List bytes) => base64Encode(bytes);

  /// Compress + encode in one step.
  static Future<Map<String, dynamic>> compressAndEncode(Uint8List rawBytes) async {
    final compressed = await compressToBytes(rawBytes);
    return {
      "bytes": compressed,
      "base64": base64Encode(compressed),
    };
  }

  /// Utility: Check if image size is safe for Firestore (under 1MB).
  static bool isSafeForFirestore(Uint8List bytes) {
    return bytes.lengthInBytes < 900 * 1024; // ~900KB buffer
  }
}
