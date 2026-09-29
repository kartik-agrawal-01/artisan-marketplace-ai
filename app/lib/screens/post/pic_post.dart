import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/compression_service.dart';
import '../../services/api_service.dart';

class AiPic extends StatefulWidget {
  final Function(Uint8List rawBytes) onImagePicked;
  final Function(Uint8List compressedBytes) onUseAI;
  final Function(Uint8List compressedBytes) onUseOriginal;

  const AiPic({
    Key? key,
    required this.onImagePicked,
    required this.onUseOriginal,
    required this.onUseAI,
  }) : super(key: key);

  @override
  _AiPicState createState() => _AiPicState();
}

class _AiPicState extends State<AiPic> {
  Uint8List? _selectedImageBytes;
  Uint8List? _studioPreview;
  Uint8List? _transparentPreview;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final rawBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = rawBytes;
        _studioPreview = null;
        _transparentPreview = null;
      });
      widget.onImagePicked(rawBytes);
    }
  }

  Future<void> _handleUseOriginal() async {
    if (_selectedImageBytes == null) return;
    final compressedBytes = await CompressionService.compressToBytes(_selectedImageBytes!);
    widget.onUseOriginal(compressedBytes);
  }

  Future<void> _handleUseAI() async {
    if (_selectedImageBytes == null) return;
    final compressedBytes = await CompressionService.compressToBytes(_selectedImageBytes!);

    try {
      final modifiedMap = await ApiService.cleanImage(compressedBytes);
      print("AI response keys: ${modifiedMap.keys}");

      setState(() {
        _studioPreview = modifiedMap["studio"];
        _transparentPreview = modifiedMap["transparent"];
      });
    } catch (e) {
      debugPrint("AI processing failed: $e");
      widget.onUseAI(compressedBytes); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB5B3F2);
    const Color secondaryColor = Color(0xFFFBD259);
    const Color textColor = Color(0xFF333333);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: _selectedImageBytes == null
                  ? _buildPlaceholder(context, primaryColor)
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _selectedImageBytes!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImageBytes != null && _studioPreview == null && _transparentPreview == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.check_circle_outline,
                    label: "Use Original",
                    color: primaryColor,
                    onPressed: _handleUseOriginal,
                    textColor: textColor,
                  ),
                  _buildActionButton(
                    icon: Icons.auto_awesome,
                    label: "Use AI",
                    color: secondaryColor,
                    onPressed: _handleUseAI,
                    textColor: textColor,
                  ),
                ],
              ),
            if (_studioPreview != null || _transparentPreview != null) ...[
              const SizedBox(height: 16),
              Text(
                "AI Results",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_studioPreview != null)
                    Expanded(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _studioPreview!,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildActionButton(
                            icon: Icons.image,
                            label: "Use Studio",
                            color: secondaryColor,
                            onPressed: () => widget.onUseAI(_studioPreview!),
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (_transparentPreview != null)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _transparentPreview!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildActionButton(
                            icon: Icons.layers_clear,
                            label: "Use Transparent",
                            color: primaryColor,
                            onPressed: () => widget.onUseAI(_transparentPreview!),
                            textColor: textColor,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, Color color) => Container(
    height: 250,
    width: double.infinity,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.5), width: 2),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 64, color: color),
        const SizedBox(height: 8),
        Text(
          "Tap to upload an image",
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        elevation: 3,
      ),
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
