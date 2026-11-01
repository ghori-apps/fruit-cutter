import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryOrange = Color(0xFFFF6D00);
  static const Color primaryRed = Color(0xFFFF1744);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryPurple = Color(0xFFA855F7);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color darkBackground = Color(0xFF120E18);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.baloo2TextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryOrange,
        surface: Color(0xFF1E1728),
      ),
    );
  }

  static BoxDecoration glassDecoration({
    double opacity = 0.25,
    Color color = Colors.black,
    double borderRadius = 20,
    Color borderColor = const Color(0x33FFFFFF),
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
    double borderRadius = 20,
    Color borderColor = const Color(0x44FFFFFF),
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static TextStyle titleStyle({double fontSize = 36, Color color = Colors.white}) {
    return GoogleFonts.baloo2(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color,
      shadows: [
        const Shadow(
          color: Colors.black54,
          blurRadius: 10,
          offset: Offset(2, 3),
        ),
      ],
    );
  }

  static TextStyle bodyStyle({double fontSize = 16, Color color = Colors.white, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
