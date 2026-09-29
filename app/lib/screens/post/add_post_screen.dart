import 'dart:typed_data';
import 'package:artisans/screens/post/pic_post.dart';
import 'package:artisans/screens/post/post_deets.dart';
import 'package:artisans/services/compression_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/post_controller.dart';
import '../../models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final PostController _controller = Get.put(PostController());

  Uint8List? rawImageBytes;
  Uint8List? aiCompressedBytes;
  bool useAI = false;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  String category = "jewelry";

  void _handleImagePicked(Uint8List rawBytes) {
    rawImageBytes = rawBytes;
  }

  void _handleUseOriginal(Uint8List compressedBytes) {
    setState(() {
      useAI = false;
      aiCompressedBytes = compressedBytes; // store in case you need it later
    });

    Get.snackbar(
      "Image Mode",
      "Using original photo",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF65D49C),
      colorText: Colors.white,
    );
  }


  void _handleUseAI(Uint8List compressedBytes) {
    setState(() {
      useAI = true;
      aiCompressedBytes = compressedBytes;
    });
    Get.snackbar("Image Mode", "Using AI-generated photo",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFB5B3F2),
      colorText: Colors.white,
    );
  }

  Future<void> _savePost() async {
    // ... (rest of your _savePost logic remains the same)
    if (titleController.text.isEmpty || priceController.text.isEmpty || rawImageBytes == null) {
      Get.snackbar("Error", "Please fill all required fields and pick an image",
          backgroundColor: const Color(0xFFFBD259), colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM
      );
      return;
    }
    final compressed = await CompressionService.compressToBytes(
      useAI ? aiCompressedBytes! : rawImageBytes!,
    );

    if (!CompressionService.isSafeForFirestore(compressed)) {
      Get.snackbar("Error", "Image is still too large to upload. Try a smaller one.");
      return;
    }

    final base64Image = CompressionService.toBase64(compressed);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You must be logged in to add a post");
      return;
    }

    final artisanId = user.uid;
    final post = PostModel(
      id: "",
      artisanId: artisanId,
      title: titleController.text,
      ogDescription: descriptionController.text,
      aiDescription: useAI ? descriptionController.text : "",
      category: category,
      price: double.tryParse(priceController.text) ?? 0,
      purchasesCount: 0,
      likesCount: 0,
      viewsCount: 0,
      isAvailable: true,
      createdAt: Timestamp.now(),
      ogPhotoBase64: useAI ? null : base64Image,
      aiPhotoBase64: useAI ? base64Image : null,
    );
    await _controller.addPost(post);
    Get.snackbar("Success", "Post added!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF65D49C),
        colorText: Colors.white
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB5B3F2);
    const Color secondaryColor = Color(0xFFFBD259);
    const Color accentColor = Color(0xFF65D49C);
    const Color textColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add New Post",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AiPic(
              onImagePicked: _handleImagePicked,
              onUseOriginal: _handleUseOriginal,
              onUseAI: _handleUseAI,
            ),
            PostDetailsForm(
              titleController: titleController,
              descriptionController: descriptionController,
              priceController: priceController,
              category: category,
              onCategoryChanged: (val) => setState(() => category = val),
            ),
            const SizedBox(height: 30),
            Obx(
                  () => _controller.isLoading.value
                  ? const CircularProgressIndicator(color: primaryColor)
                  : ElevatedButton.icon(
                onPressed: _savePost,
                label: Text(
                  "Showcase Your Craft",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  elevation: 8,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}