import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 시안 2 스타일의 플래시카드 (그라데이션 + 두꺼운 테두리 + 스티커 느낌)
class FunFlashcard extends StatelessWidget {
  const FunFlashcard({
    super.key,
    required this.hanzi,
    this.pinyin,
    this.meaning,
    this.example,
    this.exampleKo,
    this.level,
    this.showBack = true,
    this.accent,
  });

  final String hanzi;
  final String? pinyin;
  final String? meaning;
  final String? example;
  final String? exampleKo;
  final int? level;
  final bool showBack;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color a = accent ?? AppColors.coral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: a.withValues(alpha: 0.28), width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: a.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            hanzi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: hanzi.length > 4 ? 40 : (hanzi.length > 2 ? 54 : 72),
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.12,
              letterSpacing: hanzi.length > 3 ? 1 : 5,
            ),
          ),
          if (pinyin != null && pinyin!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              pinyin!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: a,
                letterSpacing: 0.4,
              ),
            ),
          ],
          if (showBack && meaning != null) ...<Widget>[
            const SizedBox(height: 18),
            Container(
              height: 2,
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              meaning!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.35,
                letterSpacing: -0.4,
              ),
            ),
          ],
          if (showBack && example != null && example!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: a.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    example!,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      height: 1.5,
                    ),
                  ),
                  if (exampleKo != null && exampleKo!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 5),
                    Text(
                      exampleKo!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkSoft,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
