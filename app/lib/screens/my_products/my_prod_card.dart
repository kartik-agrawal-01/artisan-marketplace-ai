import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/post_model.dart';

class MyProdCard extends StatelessWidget {
  final PostModel post;

  const MyProdCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes =
    PostModel.decodeImage(post.ogPhotoBase64 ?? post.aiPhotoBase64);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with rounded corners
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageBytes != null
                ? Image.memory(
              imageBytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, size: 70, color: Colors.grey),
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "\₹${post.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF65D49C), // Green for price
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  post.aiDescription.isNotEmpty
                      ? post.aiDescription
                      : post.ogDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chip
                Chip(
                  label: Text(
                    post.category,
                    style: const TextStyle(
                       // Blue for category text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFFFBD259), // Yellow for category chip
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.shopping_bag, "${post.purchasesCount}", const Color(0xFFB5B3F2)), // Blue for bag
                    _buildStatItem(Icons.favorite, "${post.likesCount}", Colors.redAccent),
                    _buildStatItem(Icons.remove_red_eye, "${post.viewsCount}", Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}