import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/word_repository.dart';
import '../models/word.dart';
import '../services/progress_service.dart';
import '../services/study_queue_builder.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 플래시카드 학습 화면
class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.levels,
    required this.title,
    this.favoritesOnly = false,
  });

  final Set<int> levels;
  final String title;
  final bool favoritesOnly;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  late List<Word> _queue;

  int _index = 0;
  bool _revealed = false;
  int _known = 0;
  int _unknown = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _buildQueue();
  }

  void _buildQueue() {
    final ProgressService service = context.read<ProgressService>();
    if (widget.favoritesOnly) {
      final Set<String> favs = service.favoriteIds;
      _queue = WordRepository.byLevels(widget.levels)
          .where((Word w) => favs.contains(w.id))
          .toList();
    } else {
      _queue = StudyQueueBuilder.build(
        goals: widget.levels,
        size: math.max(service.dailyGoal, 10),
        service: service,
      );
    }
    _index = 0;
    _finished = _queue.isEmpty;
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Word get _current => _queue[_index];

  void _toggleReveal() {
    setState(() => _revealed = !_revealed);
    if (_revealed) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  Future<void> _answer(bool known) async {
    final ProgressService service = context.read<ProgressService>();
    await service.recordAnswer(_current.id, known: known);
    if (!mounted) return;

    setState(() {
      if (known) {
        _known++;
      } else {
        _unknown++;
      }
      _revealed = false;
      _flip.value = 0;
      if (_index < _queue.length - 1) {
        _index++;
      } else {
        _finished = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.levelColor(
      _finished ? widget.levels.first : _current.level,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          if (!_finished)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_index + 1} / ${_queue.length}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _finished
            ? _buildSummary(context)
            : _buildCard(context, accent),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Color accent) {
    final Word word = _current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      child: Column(
        children: <Widget>[
          // 진행 바
          Row(
            children: <Widget>[
              Expanded(
                child: ChunkyProgressBar(
                  value: (_index + (_revealed ? 0.5 : 0)) / _queue.length,
                  height: 8,
                  gradient: AppColors.levelGradient(word.level),
                  trackColor: AppColors.line.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              LevelPill(level: word.level, compact: true),
              const Spacer(),
              _IconAction(
                icon: context.watch<ProgressService>().isFavorite(word.id)
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: accent,
                onTap: () async {
                  await context
                      .read<ProgressService>()
                      .toggleFavorite(word.id);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 카드 영역
          Expanded(
            child: GestureDetector(
              onTap: _toggleReveal,
              child: AnimatedBuilder(
                animation: _flip,
                builder: (BuildContext context, Widget? child) {
                  final double v = _flip.value;
                  final bool showFront = v < 0.5;
                  final double angle = v * math.pi;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angle),
                    child: showFront
                        ? _buildFront(word, accent)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildBack(word, accent),
                          ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 하단 액션
          if (!_revealed)
            Column(
              children: <Widget>[
                ChunkyButton(
                  label: '뜻 보기',
                  icon: Icons.visibility_rounded,
                  gradient: AppColors.levelGradient(word.level),
                  onPressed: _toggleReveal,
                  height: 58,
                ),
                const SizedBox(height: 10),
                Text(
                  '카드를 탭해도 뒤집을 수 있어요',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkSoft.withValues(alpha: 0.8),
                  ),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: _AnswerButton(
                    label: '몰라요',
                    emoji: '😵',
                    color: AppColors.berry,
                    onTap: () => _answer(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnswerButton(
                    label: '알아요',
                    emoji: '😎',
                    color: AppColors.mint,
                    onTap: () => _answer(true),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFront(Word word, Color accent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            word.hanzi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: word.hanzi.length > 4
                  ? 44
                  : (word.hanzi.length > 2 ? 62 : 84),
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.1,
              letterSpacing: word.hanzi.length > 3 ? 2 : 6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              word.pos,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(Word word, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.10),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 3),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              word.hanzi,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.pinyin,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 2,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              word.meaning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.35,
                letterSpacing: -0.5,
              ),
            ),
            if (word.example.isNotEmpty) ...<Widget>[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                  border: Border.all(color: accent.withValues(alpha: 0.16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.format_quote_rounded,
                            size: 15, color: accent),
                        const SizedBox(width: 5),
                        const Text(
                          '예문',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.example,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.5,
                      ),
                    ),
                    if (word.exampleKo.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        word.exampleKo,
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
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final int total = _known + _unknown;
    final double rate = total == 0 ? 0 : _known / total;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 14),
            Text(
              _queue.isEmpty ? '학습할 카드가 없어요' : '오늘 학습 완료!',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _queue.isEmpty
                  ? '단어장에서 다른 급수를 선택해 보세요.'
                  : '$total개 카드를 모두 확인했어요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.l),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: <Widget>[
                  ProgressRing(
                    value: rate,
                    size: 108,
                    stroke: 11,
                    colors: <Color>[AppColors.mint, AppColors.coral],
                    trackColor: AppColors.line,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${(rate * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          '정답률',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SummaryStat(
                          emoji: '😎',
                          label: '알아요',
                          value: '$_known',
                          color: AppColors.mint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryStat(
                          emoji: '😵',
                          label: '몰라요',
                          value: '$_unknown',
                          color: AppColors.berry,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            ChunkyButton(
              label: '계속 학습하기',
              icon: Icons.refresh_rounded,
              gradient: AppColors.mainGradient,
              onPressed: () {
                setState(() {
                  _known = 0;
                  _unknown = 0;
                  _revealed = false;
                  _flip.value = 0;
                  _buildQueue();
                });
              },
            ),
            const SizedBox(height: 10),
            ChunkyButton(
              label: '돌아가기',
              filled: false,
              color: AppColors.inkSoft,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2.4),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Column(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
