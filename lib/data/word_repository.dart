import '../models/word.dart';
import 'hsk_level3.dart';
import 'hsk_level4.dart';
import 'hsk_level5.dart';
import 'hsk_level6.dart';

/// 전체 HSK 3.0 단어 저장소
class WordRepository {
  WordRepository._();

  static final List<Word> _all = <Word>[
    ...hskLevel3Words,
    ...hskLevel4Words,
    ...hskLevel5Words,
    ...hskLevel6Words,
  ];

  static List<Word> get all => List<Word>.unmodifiable(_all);

  static List<Word> byLevel(int level) =>
      _all.where((w) => w.level == level).toList(growable: false);

  static List<Word> byLevels(Set<int> levels) =>
      _all.where((w) => levels.contains(w.level)).toList(growable: false);

  static Word? byId(String id) {
    for (final w in _all) {
      if (w.id == id) return w;
    }
    return null;
  }

  static List<int> get levels => const <int>[3, 4, 5, 6];

  static int countOfLevel(int level) =>
      _all.where((w) => w.level == level).length;

  /// 검색어로 단어 필터링 (한자/병음/뜻/예문)
  static List<Word> search(String query, {Set<int>? levels}) {
    final q = query.trim().toLowerCase();
    final base = levels == null ? _all : byLevels(levels);
    if (q.isEmpty) return base;
    return base
        .where((w) => w.searchKey.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
