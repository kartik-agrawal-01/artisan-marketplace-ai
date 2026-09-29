import 'dart:typed_data';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String id;
  String artisanId;
  String title;
  String ogDescription;
  String aiDescription;
  String category;
  double price;
  int purchasesCount;
  int likesCount;
  int viewsCount;
  bool isAvailable;
  Timestamp createdAt;

  // Base64 stored images
  String? ogPhotoBase64;
  String? aiPhotoBase64;

  PostModel({
    required this.id,
    required this.artisanId,
    required this.title,
    required this.ogDescription,
    required this.aiDescription,
    required this.category,
    required this.price,
    required this.purchasesCount,
    required this.likesCount,
    required this.viewsCount,
    required this.isAvailable,
    required this.createdAt,
    this.ogPhotoBase64,
    this.aiPhotoBase64,
  });

  /// Convert Uint8List to base64
  static String? encodeImage(Uint8List? bytes) {
    if (bytes == null) return null;
    return base64Encode(bytes);
  }

  /// Convert base64 back to Uint8List
  static Uint8List? decodeImage(String? base64Str) {
    if (base64Str == null) return null;
    return base64Decode(base64Str);
  }

  Map<String, dynamic> toMap() {
    return {
      'artisanId': artisanId,
      'title': title,
      'ogDescription': ogDescription,
      'aiDescription': aiDescription,
      'category': category,
      'price': price,
      'purchasesCount': purchasesCount,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'ogPhotoBase64': ogPhotoBase64,
      'aiPhotoBase64': aiPhotoBase64,
    };
  }

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      artisanId: data['artisanId'] ?? '',
      title: data['title'] ?? '',
      ogDescription: data['ogDescription'] ?? '',
      aiDescription: data['aiDescription'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      purchasesCount: (data['purchasesCount'] ?? 0).toInt(),
      likesCount: (data['likesCount'] ?? 0).toInt(),
      viewsCount: (data['viewsCount'] ?? 0).toInt(),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      ogPhotoBase64: data['ogPhotoBase64'],
      aiPhotoBase64: data['aiPhotoBase64'],
    );
  }
}
