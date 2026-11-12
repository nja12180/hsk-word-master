import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/word_repository.dart';
import '../models/word.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'study_screen.dart';

/// 단어장 (검색 / 급수 필터 / 즐겨찾기)
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String _query = '';
  Set<int> _levels = <int>{3, 4, 5, 6};
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<Word> _filtered(ProgressService service) {
    List<Word> list = WordRepository.search(_query, levels: _levels);
    if (_favoritesOnly) {
      final Set<String> favs = service.favoriteIds;
      list = list.where((Word w) => favs.contains(w.id)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ProgressService service = context.watch<ProgressService>();
    final List<Word> words = _filtered(service);

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              children: <Widget>[
                const Text(
                  '단어장',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${words.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.coral,
                    ),
                  ),
                ),
                const Spacer(),
                _ToggleChip(
                  label: '즐겨찾기',
                  icon: Icons.bookmark_rounded,
                  active: _favoritesOnly,
                  onTap: () =>
                      setState(() => _favoritesOnly = !_favoritesOnly),
                ),
              ],
            ),
          ),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppShadows.soft,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (String v) => setState(() => _query = v),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: '한자, 병음, 뜻으로 검색',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkSoft,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.inkSoft, size: 21),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.inkSoft),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 급수 필터
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _LevelFilterChip(
                    label: '전체',
                    active: _levels.length == 4,
                    gradient: AppColors.mainGradient,
                    onTap: () =>
                        setState(() => _levels = <int>{3, 4, 5, 6}),
                  ),
                  const SizedBox(width: 8),
                  ...WordRepository.levels.map((int lv) {
                    final bool only =
                        _levels.length == 1 && _levels.contains(lv);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _LevelFilterChip(
                        label: '$lv급',
                        active: only,
                        gradient: AppColors.levelGradient(lv),
                        onTap: () => setState(() => _levels = <int>{lv}),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),
          Expanded(
            child: words.isEmpty
                ? const EmptyState(
                    message: '조건에 맞는 단어가 없어요',
                    sub: '검색어나 급수 필터를 바꿔 보세요',
                    emoji: '🔍',
                  )
                : ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                    itemCount: words.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 9),
                    itemBuilder: (BuildContext context, int i) {
                      final Word w = words[i];
                      return _WordTile(
                        word: w,
                        progress: service.progressOf(w.id),
                        onTap: () => _showWordSheet(context, w),
                        onFavorite: () async {
                          await service.toggleFavorite(w.id);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showWordSheet(BuildContext context, Word word) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final ProgressService s = context.read<ProgressService>();
        return _WordDetailSheet(word: word, service: s);
      },
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? AppColors.sunnyGradient : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 15,
              color: active ? const Color(0xFF6B4A00) : AppColors.inkSoft,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: active ? const Color(0xFF6B4A00) : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelFilterChip extends StatelessWidget {
  const _LevelFilterChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? gradient : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: active
              ? null
              : Border.all(color: AppColors.line, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.word,
    required this.progress,
    required this.onTap,
    required this.onFavorite,
  });

  final Word word;
  final WordProgress progress;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.levelColor(word.level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(
            color: progress.isMastered
                ? AppColors.mint.withValues(alpha: 0.5)
                : AppColors.line.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Row(
          children: <Widget>[
            // 급수 색 바
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.levelGradient(word.level),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        word.hanzi,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          word.pinyin,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                      if (progress.isMastered) ...<Widget>[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: AppColors.mint),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    word.meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                progress.isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 21,
                color: progress.isFavorite
                    ? AppColors.sunny
                    : AppColors.inkSoft.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 단어 상세 바텀시트
class _WordDetailSheet extends StatefulWidget {
  const _WordDetailSheet({required this.word, required this.service});

  final Word word;
  final ProgressService service;

  @override
  State<_WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends State<_WordDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final Word w = widget.word;
    final WordProgress p = widget.service.progressOf(w.id);
    final Color accent = AppColors.levelColor(w.level);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: SingleChildScrollView(
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
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                LevelPill(level: w.level, compact: true),
                const SizedBox(width: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    w.pos,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await widget.service.toggleFavorite(w.id);
                    setState(() {});
                  },
                  icon: Icon(
                    p.isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: p.isFavorite ? AppColors.sunny : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              w.hanzi,
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: 3,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              w.pinyin,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              w.meaning,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                height: 1.4,
                letterSpacing: -0.3,
              ),
            ),
            if (w.example.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      w.example,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.5,
                      ),
                    ),
                    if (w.exampleKo.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        w.exampleKo,
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
            const SizedBox(height: 20),
            // 학습 현황
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Row(
                children: <Widget>[
                  _StatMini(
                    label: '복습',
                    value: '${p.reviewCount}회',
                    color: accent,
                  ),
                  _divider(),
                  _StatMini(
                    label: '정답',
                    value: '${p.correctCount}',
                    color: AppColors.mint,
                  ),
                  _divider(),
                  _StatMini(
                    label: '오답',
                    value: '${p.wrongCount}',
                    color: AppColors.berry,
                  ),
                  _divider(),
                  _StatMini(
                    label: '단계',
                    value: '${p.box}/5',
                    color: AppColors.grape,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ChunkyButton(
              label: '이 단어 학습하기',
              icon: Icons.play_arrow_rounded,
              gradient: AppColors.levelGradient(w.level),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StudyScreen(
                      levels: <int>{w.level},
                      title: 'HSK ${w.level}급 학습',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 26,
        color: AppColors.line,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}
