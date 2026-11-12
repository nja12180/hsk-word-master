import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../data/word_repository.dart';
import '../screens/study_screen.dart';
import '../screens/word_list_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/stats_screen.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const List<String> _titles = <String>['학습', '단어장', '퀴즈', '통계'];

  @override
  Widget build(BuildContext context) {
    final ProgressService service = context.watch<ProgressService>();

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const <Widget>[
          _DashboardTab(),
          WordListScreen(),
          QuizHomeTab(),
          StatsScreen(),
        ],
      ),
      bottomNavigationBar: _FunNavBar(
        index: _tab,
        onTap: (int i) => setState(() => _tab = i),
        labels: _titles,
        favoriteCount: service.favoriteCount,
      ),
    );
  }
}

/// 하단 내비게이션 — 시안 2의 둥근 세그먼트 스타일
class _FunNavBar extends StatelessWidget {
  const _FunNavBar({
    required this.index,
    required this.onTap,
    required this.labels,
    required this.favoriteCount,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final int favoriteCount;

  static const List<IconData> _icons = <IconData>[
    Icons.auto_stories_rounded,
    Icons.menu_book_rounded,
    Icons.quiz_rounded,
    Icons.insights_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: List<Widget>.generate(labels.length, (int i) {
              final bool active = i == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: active ? AppColors.mainGradient : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _icons[i],
                          size: 22,
                          color: active ? Colors.white : AppColors.inkSoft,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w600,
                            color: active ? Colors.white : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// 학습 탭 (홈 대시보드)
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final ProgressService service = context.watch<ProgressService>();
    final Set<int> levels = service.selectedLevels;
    final int dueCount = service.dueWordIds(
      WordRepository.byLevels(levels).map((dynamic w) => w.id as String),
    ).length;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _buildHeader(context, service)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
              child: _buildTodayCard(context, service, dueCount),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
              child: const SectionTitle(
                title: '급수별 단어장',
                subtitle: '원하는 급수를 눌러 바로 학습해요',
                emoji: '📚',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) {
                  final int level = WordRepository.levels[i];
                  return _LevelCard(
                    level: level,
                    total: WordRepository.countOfLevel(level),
                    learned: service.learnedCount,
                    onTap: () => _pushStudy(context, level),
                  );
                },
                childCount: WordRepository.levels.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 12),
              child: const SectionTitle(
                title: '이번 주 기록',
                emoji: '🔥',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              child: _WeekStreak(service: service),
            ),
          ),
        ],
      ),
    );
  }

  void _pushStudy(BuildContext context, int level) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyScreen(
          levels: <int>{level},
          title: 'HSK $level급 학습',
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProgressService service) {
    final String greeting;
    final int hour = DateTime.now().hour;
    if (hour < 6) {
      greeting = '늦은 밤에도 열공 중이네요';
    } else if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 18) {
      greeting = '오후도 화이팅';
    } else {
      greeting = '오늘 하루 수고했어요';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'HSK 단어마스터',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openSettings(context, service),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                gradient: AppColors.sunnyGradient,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppShadows.colored(AppColors.sunny),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('🔥', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 5),
                  Text(
                    '${service.displayStreak}일',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF6B4A00),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(
    BuildContext context,
    ProgressService service,
    int dueCount,
  ) {
    final bool done = service.isDailyGoalDone;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(AppRadius.l),
        boxShadow: AppShadows.colored(AppColors.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      done ? '오늘 목표 달성! 🎉' : '오늘의 학습',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFF0E8),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${service.dailyCount} / ${service.dailyGoal} 단어',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                value: service.dailyProgress,
                size: 62,
                stroke: 7,
                trackColor: Colors.white.withValues(alpha: 0.3),
                child: Text(
                  '${(service.dailyProgress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChunkyProgressBar(
            value: service.dailyProgress,
            height: 10,
            gradient: const LinearGradient(
              colors: <Color>[Colors.white, Color(0xFFFFE9C9)],
            ),
            trackColor: Colors.white.withValues(alpha: 0.28),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              if (dueCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.replay_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '복습 $dueCount개',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.check_circle_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '암기 ${service.masteredCount}개',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 18),
          ChunkyButton(
            label: done ? '한 번 더 학습하기' : '학습 시작하기',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StudyScreen(
                    levels: service.selectedLevels,
                    title: '오늘의 학습',
                  ),
                ),
              );
            },
            color: AppColors.ink,
            height: 54,
            fontSize: 15.5,
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context, ProgressService service) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => _SettingsSheet(service: service),
    );
  }
}

/// 급수 카드
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.total,
    required this.learned,
    required this.onTap,
  });

  final int level;
  final int total;
  final int learned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: AppColors.levelGradient(level),
          borderRadius: BorderRadius.circular(AppRadius.m),
          boxShadow: AppShadows.colored(AppColors.levelColor(level)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'HSK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.white),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$level',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 1),
                  child: Text(
                    '급',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$total단어',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 이번 주 잔디(히트맵)
class _WeekStreak extends StatelessWidget {
  const _WeekStreak({required this.service});

  final ProgressService service;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<DateTime, int>> days = service.recentDays(14);
    final int maxCount = days.fold<int>(
      1,
      (int m, MapEntry<DateTime, int> e) => e.value > m ? e.value : m,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.m),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: days.map((MapEntry<DateTime, int> e) {
                    final double ratio = e.value / maxCount;
                    final bool today = _isToday(e.key);
                    return Tooltip(
                      message: '${e.key.month}/${e.key.day} · ${e.value}개',
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: e.value == 0
                              ? AppColors.line.withValues(alpha: 0.6)
                              : AppColors.coral.withValues(
                                  alpha: 0.25 + ratio * 0.75),
                          borderRadius: BorderRadius.circular(8),
                          border: today
                              ? Border.all(color: AppColors.ink, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text('최고 기록 ', style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              )),
              Text(
                '${service.bestStreak}일',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coral,
                ),
              ),
              const Spacer(),
              Text(
                '총 ${service.totalAnswered}회 학습',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime d) {
    final DateTime now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

/// 설정 바텀시트
class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.service});

  final ProgressService service;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _goal;
  late Set<int> _levels;

  @override
  void initState() {
    super.initState();
    _goal = widget.service.dailyGoal;
    _levels = Set<int>.from(widget.service.selectedLevels);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '학습 설정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          const Text('하루 목표 단어 수', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: <int>[10, 20, 30, 50].map((int g) {
              final bool active = g == _goal;
              return GestureDetector(
                onTap: () => setState(() => _goal = g),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.mainGradient : null,
                    color: active ? null : AppColors.cream,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$g개',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.inkSoft,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text('학습할 급수', style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: WordRepository.levels.map((int lv) {
              final bool active = _levels.contains(lv);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (active) {
                      if (_levels.length > 1) _levels.remove(lv);
                    } else {
                      _levels.add(lv);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.levelGradient(lv) : null,
                    color: active ? null : AppColors.cream,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$lv급',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.inkSoft,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          ChunkyButton(
            label: '저장하기',
            gradient: AppColors.mainGradient,
            onPressed: () async {
              await widget.service.setDailyGoal(_goal);
              await widget.service.setSelectedLevels(_levels);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () async {
                final bool? ok = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext c) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                    title: const Text('학습 기록 초기화'),
                    content: const Text('모든 학습 진도와 즐겨찾기가 삭제됩니다. 계속할까요?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text(
                          '초기화',
                          style: TextStyle(color: AppColors.berry),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await widget.service.resetAll();
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text(
                '학습 기록 초기화',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
