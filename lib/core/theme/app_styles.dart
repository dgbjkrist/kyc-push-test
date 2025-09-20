import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static BoxDecoration cardBox({Color color = AppColors.colorBlue, double alpha = 30}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha(alpha.toInt()),
          blurRadius: 9,
          offset: const Offset(0, 0),
          blurStyle: BlurStyle.outer,
        ),
      ],
    );
  }

  static BoxDecoration listTileBox(Color color) => cardBox(color: color, alpha: 40);
}