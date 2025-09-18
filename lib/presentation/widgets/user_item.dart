import 'package:flutter/material.dart';

import '../../domain/entities/kyc_user.dart';

class UserItem extends StatelessWidget {
  final KycUser user;
  final VoidCallback onTap;

  const UserItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user.faceUrl),
      ),
      title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
      subtitle: Text("ID: ${user.id}", style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
      tileColor: const Color(0xFF1C2230),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
