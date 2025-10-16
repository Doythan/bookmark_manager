import 'package:flutter/material.dart';

class AppColors {
  // ============= Primary Colors (Emerald Green) =============
  static const Color primary = Color(0xFF10B981); // 에메랄드 그린
  static const Color primaryLight = Color(0xFF6EE7B7); // 밝은 민트
  static const Color primaryDark = Color(0xFF059669); // 진한 에메랄드
  static const Color primaryContainer = Color(0xFFD1FAE5);

  // ============= Secondary Colors =============
  static const Color secondary = Color(0xFF7C4DFF); // 보라색 악센트
  static const Color secondaryLight = Color(0xFFB388FF);
  static const Color secondaryContainer = Color(0xFFEDE7F6);

  // ============= Background Colors =============
  static const Color background = Color(0xFFFAFAFA); // 더 밝은 회색
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ============= Text Colors =============
  static const Color textPrimary = Color(0xFF1A1A1A); // 더 진한 검정
  static const Color textSecondary = Color(0xFF616161); // 중간 회색
  static const Color textTertiary = Color(0xFF9E9E9E); // 연한 회색
  static const Color textOnPrimary = Colors.white;

  // ============= Status Colors =============
  static const Color error = Color(0xFFEF5350);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color success = Color(0xFF66BB6A);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFFBBDEFB);

  // ============= Border & Divider =============
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // ============= SNS Colors =============
  static const Color youtube = Color(0xFFFF0000);
  static const Color instagram = Color(0xFFE4405F);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color facebook = Color(0xFF1877F2);
  static const Color tiktok = Color(0xFF000000);

  // ============= Gradients =============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF6EE7B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============= Shadows =============
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
