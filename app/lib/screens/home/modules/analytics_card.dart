import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../analytics/analytics_page.dart';

// Assuming AnalyticsPage is defined in the correct location
// import 'package:artisans/screens/analytics/analytics_page.dart';

class AnalyticsCardWidget extends StatelessWidget {
  // Pass in data from your backend
  final int totalViews;
  final int totalLikes;

  const AnalyticsCardWidget({
    super.key,
    this.totalViews = 1543,
    this.totalLikes = 215,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6A88E5);
    const Color secondaryColor = Color(0xFFFBD259);
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
              children: [
                const Icon(
                  Icons.auto_graph_rounded,
                  size: 60.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 16.0),
                Text(
                  "Your Product Stats",
                  style: GoogleFonts.montserrat(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Views", totalViews, Icons.visibility_rounded, secondaryColor),
                    _buildStatItem("Likes", totalLikes, Icons.favorite_rounded, secondaryColor),
                  ],
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // This is the navigation to the analytics screen.
                      Get.to(() => AnalyticsPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      elevation: 5,
                    ),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
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

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8.0),
        Text(
          value.toString(),
          style: GoogleFonts.montserrat(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.white, // Changed to white for better contrast
          ),
        ),
      ],
    );
  }
}
