import 'package:flutter/material.dart';
import '../../domain/entities/kyc_user.dart';

class KycDetailScreen extends StatelessWidget {
  final KycUser user;

  const KycDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.faceUrl),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection("Card Recto", user.cardRectoUrl),
            const SizedBox(height: 16),
            _buildSection("Card Verso", user.cardVersoUrl),
            const SizedBox(height: 24),
            _buildInfo("Full Name", user.fullName),
            _buildInfo("Date of Birth", user.dob),
            _buildInfo("Country", user.country),
            _buildInfo("User ID", user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
        ),
      ],
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
