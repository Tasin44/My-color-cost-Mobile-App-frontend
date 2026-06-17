import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primaryColor = Color(0xffFF5FA0);
  static const Color secondaryColor = Color(0xffE993FE);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      secondaryColor, // Top: #E993FE
      primaryColor, // Bottom: #FF5FA0
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      secondaryColor, // Left: #E993FE
      primaryColor, // Right: #FF5FA0
    ],
  );
}
