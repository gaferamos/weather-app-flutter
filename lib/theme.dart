
import 'dart:ui';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3978C6);
  static const Color secondaryColor = Color(0xFF75B9F2);

  static const Color backgroundColor = Color(0xFF081426);
  static const Color backgroundLight = Color(0xFF102541);
  static const Color backgroundDark = Color(0xFF06101E);

  static const Color glassColor = Color(0x24FFFFFF);
  static const Color glassBorder = Color(0x38FFFFFF);

  static const Color textPrimary = Color(0xFFF4F8FF);
  static const Color textSecondary = Color(0xFFA8BAD0);
  static const Color textMuted = Color(0xFF71869F);

  static const Color sunnyColor = Color(0xFFFFC76A);
  static const Color rainyColor = Color(0xFF78B7E8);
  static const Color cloudyColor = Color(0xFF9BAFC5);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF173A63),
      Color(0xFF0B1D34),
      backgroundDark,
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4A91DB),
      Color(0xFF24538C),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundLight,
      onSurface: textPrimary,
    ),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textPrimary,
    ),

    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    iconTheme: const IconThemeData(
      color: textPrimary,
    ),

    dividerTheme: const DividerThemeData(
      color: glassBorder,
      thickness: 1,
    ),
  );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.blur = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppTheme.glassColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppTheme.glassBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
