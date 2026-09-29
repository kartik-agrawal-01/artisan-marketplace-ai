import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming ApiService is in this path for the AI functionality to remain.
// If you don't need that either, you can remove this import and the _generateDescription method.
import '../../services/api_service.dart';

class PostDetailsForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String category;
  final Function(String) onCategoryChanged;

  const PostDetailsForm({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.category,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  _PostDetailsFormState createState() => _PostDetailsFormState();
}

class _PostDetailsFormState extends State<PostDetailsForm> {
  bool _isAIOptionSelected = false;

  // AI functionality is kept as it was part of the original code.
  void _generateDescription() async {
    try {
      final result = await ApiService.enhanceDescription(
        title: widget.titleController.text,
        description: widget.descriptionController.text,
        language: "en",
        category: widget.category,
      );

      setState(() {
        widget.descriptionController.text = result["short_description"] ?? "";
      });
    } catch (e) {
      print("AI Description Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB5B3F2);
    const Color secondaryColor = Color(0xFFFBD259);
    const Color greenColor = Color(0xFF65D49C);
    const Color textColor = Color(0xFF333333);

    return Container(
      margin: const EdgeInsets.all(24),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Tell us about your product",
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: widget.titleController,
              style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w500),
              decoration: _inputDecoration("Title", Icons.title, primaryColor),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: widget.priceController,
              style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w500),
              decoration: _inputDecoration("Price", Icons.currency_rupee_rounded, greenColor),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: widget.category,
              decoration: _inputDecoration("Category", Icons.category, primaryColor),
              style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w500),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: primaryColor),
              items: const [
                DropdownMenuItem(value: "jewelry", child: Text("Jewelry")),
                DropdownMenuItem(value: "accessories", child: Text("Accessories")),
                DropdownMenuItem(value: "clothing", child: Text("Clothing")),
                DropdownMenuItem(value: "home_decor", child: Text("Home Decor")),
                DropdownMenuItem(value: "art_craft", child: Text("Art & Craft")),
                DropdownMenuItem(value: "ceramics", child: Text("Ceramics")),
                DropdownMenuItem(value: "textiles", child: Text("Textiles")),
                DropdownMenuItem(value: "other", child: Text("Other")),
              ],
              onChanged: (val) => widget.onCategoryChanged(val!),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: widget.descriptionController,
              style: GoogleFonts.montserrat(color: textColor, fontWeight: FontWeight.w500),
              decoration: _inputDecorationWithSuffix(
                "Describe your creation",
                Icons.description,
                primaryColor,
                // A Row holds both icons.
                Row(
                  mainAxisSize: MainAxisSize.min, // Keeps the icons compact
                  children: [
                    // The new microphone icon with a dummy onPressed function.
                    IconButton(
                      icon: const Icon(
                        Icons.mic_none,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        // Placeholder for speech-to-text functionality
                        print("Mic icon pressed!");
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.auto_awesome_rounded,
                        color: _isAIOptionSelected ? primaryColor : secondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isAIOptionSelected = !_isAIOptionSelected;
                          if (_isAIOptionSelected) {
                            _generateDescription();
                          } else {
                            widget.descriptionController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintText: "Enter the product $label",
      hintStyle: GoogleFonts.montserrat(color: color.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }

  InputDecoration _inputDecorationWithSuffix(String label, IconData icon, Color color, Widget suffixIcon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintText: "Enter the product $label",
      hintStyle: GoogleFonts.montserrat(color: color.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }
}