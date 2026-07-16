import 'package:flutter/material.dart';

/// Màu chủ đạo & theme của BearShop (khớp màu app khách hàng + trang
/// BearShop.Admin .NET để đồng bộ thương hiệu).
const kPrimary = Color(0xFFE0266E);
const kPrimaryDark = Color(0xFFA0104C);
const kBg = Color(0xFFF7F3F5);

const kCardRadius = 18.0;
const kFieldRadius = 14.0;

const kBrandGradient = LinearGradient(
  colors: [kPrimary, kPrimaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

List<BoxShadow> get kSoftShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 18,
    offset: const Offset(0, 6),
  ),
];

BoxDecoration kCardDecoration({double radius = kCardRadius}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: kSoftShadow,
);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: kPrimary, primary: kPrimary);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBg,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF2B2130)),
      bodyLarge: TextStyle(color: Color(0xFF2B2130)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: const BorderSide(color: kPrimary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kPrimary.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kFieldRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: kPrimary, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kFieldRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kPrimary),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2B2130),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kPrimary),
  );
}
