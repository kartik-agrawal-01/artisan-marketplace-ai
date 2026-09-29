import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../post/add_post_screen.dart';

// Assuming AddPostPage is defined in the correct location
// import 'package:artisans/screens/post/add_post_screen.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6A88E5);
    const Color secondaryColor = Color(0xFFFBD259);
    const Color greenColor = Color(0xFF65D49C);
    const Color textColor = Color(0xFF333333);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        // Use a gradient for a more premium look
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.9), primaryColor.withOpacity(1.0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            offset: const Offset(0, 10),
            blurRadius: 25,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background "flair" elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo_rounded,
                  size: 60.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Ready to Share Your Creation?",
                  style: GoogleFonts.montserrat(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => AddPostPage());
                    },
                    icon: const Icon(
                      Icons.add_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Create Post',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF16C47F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}