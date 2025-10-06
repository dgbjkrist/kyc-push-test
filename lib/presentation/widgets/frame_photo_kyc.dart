import 'dart:io';

import 'package:flutter/material.dart';

class FramePhotoKyc extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? path;

  const FramePhotoKyc({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: path != null && path!.isNotEmpty
                  ? _buildImageWithOverlay(path!)
                  : _buildPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithOverlay(String imagePath) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(imagePath),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(Icons.error, color: Colors.red, size: 50),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Reprendre",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 50, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          "Appuyer pour prendre une photo",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}