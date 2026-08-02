import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Palette Hex Codes
  // #636B2F - Olive Primary
  // #BAC095 - Soft Sage Muted
  // #D4DE95 - Bright Lime Accent
  // #3D4127 - Deep Dark Olive

  static const Color primary = Color(0xFF636B2F);       // #636B2F
  static const Color sage = Color(0xFFBAC095);          // #BAC095
  static const Color accentLime = Color(0xFFD4DE95);     // #D4DE95
  static const Color primaryDark = Color(0xFF3D4127);     // #3D4127

  static const Color primaryLight = Color(0xFFBAC095);
  static const Color primaryAccent = Color(0xFF636B2F);
  static const Color accentOliveLight = Color(0xFFD4DE95);

  // Text Colors
  static const Color textHeadline = Color(0xFF3D4127);
  static const Color textPrimary = Color(0xFF3D4127);
  static const Color textSecondary = Color(0xFF636B2F);
  static const Color textMuted = Color(0xFF7B8268);

  // Surface & Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color sheetBackground = Colors.white;
  static const Color darkHeaderBg = Color(0xFF3D4127);

  // Border & Card Colors
  static const Color borderUnselected = Color(0xFFE2E6D5);
  static const Color borderSelected = Color(0xFF636B2F);
  static const Color radioUnselected = Color(0xFFBAC095);
  static const Color radioSelected = Color(0xFF636B2F);
  static const Color cardSelectedBg = Color(0xFFF7F8F0);
  static const Color cardUnselectedBg = Colors.white;

  // Button Colors
  static const Color buttonBackground = Color(0xFF636B2F);
  static const Color buttonText = Colors.white;
  static const Color buttonShadow = Color(0x33636B2F);
}
