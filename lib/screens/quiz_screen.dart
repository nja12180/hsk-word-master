import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/word_repository.dart';
import '../models/word.dart';
import '../services/progress_service.dart';
import '../services/study_queue_builder.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// 퀴즈 시작 화면 (탭 안에 표시)
class QuizHomeTab extends StatefulWidget {
  const QuizHomeTab({super.key});

  @override
  State<QuizHomeTab> createState() => _QuizHomeTabState();
}

class _QuizHomeTabState extends State<QuizHomeTab> {
  Set<int>? _levels;
  String _mode = 'hanzi2meaning';

  @override
  void initState() {
    super.initState();
    _levels = <int>{3, 4, 5, 6};
  }

  @override
  Widget build(BuildContext context) {
    final ProgressService service = context.watch<ProgressService>();
    final Set<int> levels = _levels ?? service.selectedLevels;
    final int pool = WordRepository.byLevels(levels).length;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '퀴즈',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '4지선다로 실력을 점검해요',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 18),

            // 히어로 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.grapeGradient,
                borderRadius: BorderRadius.circular(AppRadius.l),
                boxShadow: AppShadows.colored(AppColors.grape),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('🧠', style: TextStyle(fontSize: 34)),
                  const SizedBox(height: 12),
                  const Text(
                    '10문제 도전',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '출제 가능한 단어 $pool개',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 출제 방식
            const SectionTitle(title: '출제 방식', emoji: '🎲'),
            const SizedBox(height: 12),
            _ModeCard(
              title: '한자 → 뜻',
              subtitle: '한자를 보고 알맞은 뜻을 고르세요',
              icon: Icons.translate_rounded,
              selected: _mode == 'hanzi2meaning',
              color: AppColors.coral,
              onTap: () => setState(() => _mode = 'hanzi2meaning'),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              title: '뜻 → 한자',
              subtitle: '뜻을 보고 알맞은 한자를 고르세요',
              icon: Icons.text_fields_rounded,
              selected: _mode == 'meaning2hanzi',
              color: AppColors.sky,
              onTap: () => setState(() => _mode = 'meaning2hanzi'),
            ),
            const SizedBox(height: 22),

            // 급수 선택
            const SectionTitle(title: '급수 선택', emoji: '🎯'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _ChoiceChip(
                  label: '전체',
                  active: levels.length == 4,
                  gradient: AppColors.mainGradient,
                  onTap: () => setState(() => _levels = <int>{3, 4, 5, 6}),
                ),
                ...WordRepository.levels.map((int lv) => _ChoiceChip(
                      label: '$lv급',
                      active: levels.length == 1 && levels.contains(lv),
                      gradient: AppColors.levelGradient(lv),
                      onTap: () => setState(() => _levels = <int>{lv}),
                    )),
              ],
            ),
            const SizedBox(height: 28),
            ChunkyButton(
              label: '퀴즈 시작',
              icon: Icons.bolt_rounded,
              gradient: AppColors.grapeGradient,
              color: AppColors.grape,
              height: 58,
              onPressed: pool < 4
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizPlayScreen(
                            levels: levels,
                            mode: _mode,
                          ),
                        ),
                      );
                    },
            ),
            if (pool < 4)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    '단어가 4개 이상 필요해요',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            if (service.totalAnswered > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  children: <Widget>[
                    const Text('📈', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '지금까지 총 ${service.totalAnswered}번 학습했어요',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(
            color: selected ? color : AppColors.line,
            width: selected ? 2.2 : 1.5,
          ),
          boxShadow: selected ? AppShadows.colored(color) : null,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? color : AppColors.line,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.active,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? gradient : null,
          color: active ? null : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: AppColors.line, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// 실제 퀴즈 진행 화면
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.levels,
    required this.mode,
  });

  final Set<int> levels;
  final String mode;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  static const int _questionCount = 10;

  final Random _rnd = Random();

  List<Word> _questions = <Word>[];
  List<List<Word>> _options = <List<Word>>[];
  int _index = 0;
  int _correct = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _buildQuiz();
  }

  void _buildQuiz() {
    final List<Word> pool = WordRepository.byLevels(widget.levels);
    final List<Word> shuffled = List<Word>.from(pool)..shuffle(_rnd);
    _questions = shuffled.take(min(_questionCount, shuffled.length)).toList();
    _options = _questions.map((Word q) {
      final List<Word> ds = StudyQueueBuilder.distractors(
        answer: q,
        pool: pool,
        count: 3,
        random: _rnd,
      );
      final List<Word> opts = <Word>[q, ...ds]..shuffle(_rnd);
      return opts;
    }).toList();
    _index = 0;
    _correct = 0;
    _selectedIndex = null;
    _answered = false;
    _finished = false;
  }

  bool get _isHanziQuestion => widget.mode == 'hanzi2meaning';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈'),
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
                  '${_index + 1} / ${_questions.length}',
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
        child: _finished ? _buildResult() : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final Word q = _questions[_index];
    final List<Word> opts = _options[_index];
    final Color accent = _isHanziQuestion ? AppColors.grape : AppColors.sky;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ChunkyProgressBar(
            value: (_index + (_answered ? 1 : 0)) / _questions.length,
            height: 8,
            gradient: AppColors.grapeGradient,
            trackColor: AppColors.line.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),

          // 문제 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accent.withValues(alpha: 0.14),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.l),
              border: Border.all(
                  color: accent.withValues(alpha: 0.3), width: 2.5),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  _isHanziQuestion ? '이 단어의 뜻은?' : '이 뜻에 맞는 한자는?',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 14),
                if (_isHanziQuestion) ...<Widget>[
                  Text(
                    q.hanzi,
                    style: TextStyle(
                      fontSize: q.hanzi.length > 3 ? 40 : 56,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      letterSpacing: 4,
                      height: 1.1,
                    ),
                  ),
                ] else ...<Widget>[
                  Text(
                    q.meaning,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      height: 1.35,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 보기
          Expanded(
            child: ListView.separated(
              itemCount: opts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int i) {
                final Word opt = opts[i];
                final bool isAnswer = opt.id == q.id;
                final bool isSelected = _selectedIndex == i;

                Color borderColor = AppColors.line;
                Color bgColor = Colors.white;
                Widget? trailing;

                if (_answered) {
                  if (isAnswer) {
                    borderColor = AppColors.mint;
                    bgColor = AppColors.mint.withValues(alpha: 0.12);
                    trailing = const Icon(Icons.check_circle_rounded,
                        color: AppColors.mint, size: 22);
                  } else if (isSelected) {
                    borderColor = AppColors.berry;
                    bgColor = AppColors.berry.withValues(alpha: 0.1);
                    trailing = const Icon(Icons.cancel_rounded,
                        color: AppColors.berry, size: 22);
                  }
                }

                return GestureDetector(
                  onTap: _answered ? null : () => _choose(i, isAnswer),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      border: Border.all(
                        color: borderColor,
                        width: (_answered && (isAnswer || isSelected))
                            ? 2.2
                            : 1.5,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: (_answered && isAnswer)
                                ? AppColors.mint
                                : (isSelected
                                    ? AppColors.berry
                                    : AppColors.cream),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: (_answered &&
                                      (isAnswer || isSelected))
                                  ? Colors.white
                                  : AppColors.inkSoft,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isHanziQuestion ? opt.meaning : opt.hanzi,
                            style: TextStyle(
                              fontSize: _isHanziQuestion ? 14.5 : 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: _isHanziQuestion ? 0 : 1.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (trailing != null) trailing,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_answered) ...<Widget>[
            const SizedBox(height: 14),
            ChunkyButton(
              label: _index == _questions.length - 1 ? '결과 보기' : '다음 문제',
              icon: Icons.arrow_forward_rounded,
              gradient: AppColors.grapeGradient,
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _choose(int index, bool isAnswer) async {
    final ProgressService service = context.read<ProgressService>();
    final Word q = _questions[_index];

    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isAnswer) _correct++;
    });

    await service.recordAnswer(q.id, known: isAnswer);
  }

  void _next() {
    if (_index == _questions.length - 1) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selectedIndex = null;
        _answered = false;
      });
    }
  }

  Widget _buildResult() {
    final double rate =
        _questions.isEmpty ? 0 : _correct / _questions.length;
    final String emoji;
    final String title;
    if (rate >= 0.9) {
      emoji = '🏆';
      title = '완벽해요!';
    } else if (rate >= 0.7) {
      emoji = '🎉';
      title = '잘했어요!';
    } else if (rate >= 0.5) {
      emoji = '💪';
      title = '조금 더 힘내요';
    } else {
      emoji = '📚';
      title = '복습이 필요해요';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: -0.8,
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
                    size: 116,
                    stroke: 12,
                    colors: <Color>[AppColors.grape, AppColors.sky],
                    trackColor: AppColors.line,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$_correct / ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const Text(
                          '정답',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            ChunkyButton(
              label: '다시 풀기',
              icon: Icons.refresh_rounded,
              gradient: AppColors.grapeGradient,
              onPressed: () => setState(_buildQuiz),
            ),
            const SizedBox(height: 10),
            ChunkyButton(
              label: '닫기',
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
