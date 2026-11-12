import 'package:flutter/material.dart';

/// 시안 2 — 컬러풀 & 플레이풀 디자인 시스템
class AppColors {
  AppColors._();

  // 메인 그라데이션 (코랄 → 피치)
  static const Color coral = Color(0xFFFF7A59);
  static const Color peach = Color(0xFFFFA96B);
  static const Color coralDark = Color(0xFFF05A3C);
  static const Color cream = Color(0xFFFFF6EF);

  // 보조 컬러 (시안 2의 형형색색 포인트)
  static const Color sunny = Color(0xFFFFD166);
  static const Color mint = Color(0xFF5FD3A6);
  static const Color grape = Color(0xFF9B7BE8);
  static const Color sky = Color(0xFF5BB8F5);
  static const Color berry = Color(0xFFF45B8B);

  // 중성 컬러
  static const Color ink = Color(0xFF2E2A28);
  static const Color inkSoft = Color(0xFF6B625E);
  static const Color line = Color(0xFFEDE2D9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFFFF9F4);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[coral, peach],
  );

  static const LinearGradient sunnyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[sunny, Color(0xFFFFB347)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[mint, Color(0xFF3FC1C9)],
  );

  static const LinearGradient grapeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[grape, sky],
  );

  /// 급수별 대표 색상
  static Color levelColor(int level) {
    switch (level) {
      case 3:
        return mint;
      case 4:
        return sky;
      case 5:
        return grape;
      case 6:
        return berry;
      default:
        return coral;
    }
  }

  static LinearGradient levelGradient(int level) {
    switch (level) {
      case 3:
        return const LinearGradient(
          colors: <Color>[mint, Color(0xFF43C6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return const LinearGradient(
          colors: <Color>[sky, Color(0xFF4A9FE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5:
        return const LinearGradient(
          colors: <Color>[grape, Color(0xFF7C6BE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 6:
        return const LinearGradient(
          colors: <Color>[berry, Color(0xFFE0457B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return mainGradient;
    }
  }
}

class AppRadius {
  AppRadius._();
  static const double s = 14;
  static const double m = 20;
  static const double l = 28;
  static const double xl = 36;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x14B08060),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> colored(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.32),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Roboto';

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.coral,
      secondary: AppColors.grape,
      surface: AppColors.white,
    );

    final TextTheme base = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: _fontFamily,
      splashFactory: InkSparkle.splashFactory,
      textTheme: base.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ).copyWith(
        displayLarge: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
          height: 1.1,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSoft,
          height: 1.5,
        ),
        bodySmall: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.inkSoft,
          height: 1.4,
        ),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
      ),
    );
  }
}
