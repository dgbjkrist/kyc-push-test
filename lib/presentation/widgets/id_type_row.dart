import 'package:flutter/material.dart';
import 'package:kyc/core/theme/app_colors.dart';
import 'package:kyc/core/theme/app_styles.dart';

class IdTypeRow extends StatelessWidget {
  final String title;
  final Widget textImage;
  final VoidCallback action;

  const IdTypeRow({
    super.key,
    required this.title,
    required this.textImage,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.listTileBox(AppColors.colorBlue),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        onTap: () => action(),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E003D),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
      ),
    );
  }
}
