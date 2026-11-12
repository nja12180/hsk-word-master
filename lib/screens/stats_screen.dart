import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/word_repository.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'study_screen.dart';

/// 학습 통계 화면
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressService service = context.watch<ProgressService>();
    final int total = WordRepository.all.length;
    final int learned = service.learnedCount;
    final int mastered = service.masteredCount;
    final int favorites = service.favoriteCount;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Text(
                '학습 기록',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),

          // 요약 카드
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  boxShadow: AppShadows.colored(AppColors.coral),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ProgressRing(
                          value: total == 0 ? 0 : learned / total,
                          size: 82,
                          stroke: 8,
                          trackColor: Colors.white.withValues(alpha: 0.3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '${((learned / total) * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                '진행률',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFF0E8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                '전체 단어',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFF0E8),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$learned / $total',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '암기 완료 $mastered개',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFFF0E8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        _MiniStat(
                          emoji: '🔥',
                          value: '${service.displayStreak}일',
                          label: '연속 학습',
                        ),
                        _MiniStat(
                          emoji: '⭐',
                          value: '$favorites',
                          label: '즐겨찾기',
                        ),
                        _MiniStat(
                          emoji: '📝',
                          value: '${service.totalAnswered}',
                          label: '총 학습',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 급수별 진도
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 26, 18, 12),
              child: SectionTitle(
                title: '급수별 암기율',
                subtitle: '급수를 눌러 바로 학습할 수 있어요',
                emoji: '📊',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: WordRepository.levels
                    .map((int lv) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LevelProgressRow(
                            level: lv,
                            service: service,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => StudyScreen(
                                    levels: <int>{lv},
                                    title: 'HSK $lv급 학습',
                                  ),
                                ),
                              );
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // 학습 잔디
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
              child: SectionTitle(
                title: '최근 30일',
                subtitle: '매일 조금씩 쌓이는 학습 기록',
                emoji: '🌱',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
              child: _Heatmap(service: service),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Column(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFF0E8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelProgressRow extends StatelessWidget {
  const _LevelProgressRow({
    required this.level,
    required this.service,
    required this.onTap,
  });

  final int level;
  final ProgressService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> words =
        WordRepository.byLevel(level).cast<dynamic>();
    final int total = words.length;
    int mastered = 0;
    int learning = 0;
    for (final dynamic w in words) {
      final WordProgress p = service.progressOf(w.id as String);
      if (p.isMastered) {
        mastered++;
      } else if (p.isLearning) {
        learning++;
      }
    }
    final double ratio = total == 0 ? 0 : mastered / total;
    final Color color = AppColors.levelColor(level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppColors.levelGradient(level),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$level급',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '암기 $mastered',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  ' · 학습 중 $learning · 전체 $total',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkSoft,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(ratio * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ChunkyProgressBar(
              value: ratio,
              height: 9,
              gradient: AppColors.levelGradient(level),
              trackColor: AppColors.line.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.service});

  final ProgressService service;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<DateTime, int>> days = service.recentDays(30);
    final int maxCount = days.fold<int>(
      1,
      (int m, MapEntry<DateTime, int> e) => e.value > m ? e.value : m,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: days.map((MapEntry<DateTime, int> e) {
              final double ratio = e.value / maxCount;
              final DateTime now = DateTime.now();
              final bool today = e.key.year == now.year &&
                  e.key.month == now.month &&
                  e.key.day == now.day;
              return Tooltip(
                message: '${e.key.month}/${e.key.day} · ${e.value}개',
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: e.value == 0
                        ? AppColors.cream
                        : AppColors.coral.withValues(
                            alpha: 0.22 + ratio * 0.78),
                    borderRadius: BorderRadius.circular(9),
                    border: today
                        ? Border.all(color: AppColors.ink, width: 2)
                        : null,
                  ),
                  child: e.value == 0
                      ? null
                      : Text(
                          '${e.value}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: ratio > 0.5
                                ? Colors.white
                                : AppColors.coralDark,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text(
                '색이 진할수록 많이 학습했어요',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
