import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple Maps–like chrome: white/translucent cards, SF-style rounding.
/// Cyan stays as LEZ / brand accent.
class MapsColors {
  MapsColors._();

  static const Color route = Color(0xFF007AFF);
  static const Color routeCasing = Color(0xFFFFFFFF);
  static const Color routeAlt = Color(0x6693B4D4);
  static const Color accent = Color(0xFF00C4D8);
  static const Color endRed = Color(0xFFFF3B30);
  static const Color glassLight = Color(0xF7FFFFFF);
  static const Color glassDark = Color(0xE61C1C1E);
  static const Color ink = Color(0xFF1C1C1E);
  static const Color inkMuted = Color(0xFF6E6E73);
  static const Color lezFill = Color(0x3300C4D8);
  static const Color lezBorder = Color(0xFF00C4D8);
  static const Color lezOnRouteFill = Color(0x4DFF9F0A);
  static const Color lezOnRouteBorder = Color(0xFFFF9F0A);
  static const double radius = 20;
  static const double radiusSheet = 22;
}

class MapsGlass extends StatelessWidget {
  const MapsGlass({
    super.key,
    required this.child,
    this.radius = MapsColors.radius,
    this.padding,
    this.tint,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = tint ??
        (isDark ? MapsColors.glassDark : MapsColors.glassLight);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class NeonColors {
  NeonColors._();

  static const Color cyan = Color(0xFF00E5FF);
  static const Color magenta = Color(0xFFFF00E5);
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color purple = Color(0xFFD500F9);
  static const Color orange = Color(0xFFFF6D00);
  static const Color pink = Color(0xFFFF1744);

  static const Color deepSpace = Color(0xFF0A0A1A);
  static const Color darkSurface = Color(0xFF121228);
  static const Color darkCard = Color(0xFF1A1A35);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [orange, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [orange, Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [neonGreen, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [magenta, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient borderGradient = LinearGradient(
    colors: [cyan, electricBlue, purple, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? const Color(0xFF1A1A2E)
        : Colors.white;

    return TextTheme(
      displayLarge: GoogleFonts.exo2(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.exo2(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineLarge: GoogleFonts.exo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.exo2(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.exo2(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.exo2(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }

  static ThemeData get light {
    final textTheme = _buildTextTheme(Brightness.light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: MapsColors.route,
        secondary: MapsColors.accent,
        tertiary: NeonColors.purple,
        surface: Colors.white,
        onSurface: MapsColors.ink,
        error: MapsColors.endRed,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.exo2(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF2FFFFFF),
        selectedItemColor: MapsColors.accent,
        unselectedItemColor: MapsColors.inkMuted,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = _buildTextTheme(Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0B12),
      colorScheme: const ColorScheme.dark(
        primary: MapsColors.accent,
        secondary: MapsColors.route,
        tertiary: NeonColors.purple,
        surface: MapsColors.glassDark,
        onSurface: Colors.white,
        error: MapsColors.endRed,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: NeonColors.deepSpace,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: NeonColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.exo2(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeonColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NeonColors.cyan, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NeonColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
