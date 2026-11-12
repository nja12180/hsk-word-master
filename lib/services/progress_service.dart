import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 개별 단어의 학습 상태
class WordProgress {
  const WordProgress({
    required this.wordId,
    this.box = 0,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.lastReviewed,
    this.nextReview,
    this.isFavorite = false,
  });

  /// Leitner 박스 (0 = 새 단어, 1~5 = 복습 단계)
  final String wordId;
  final int box;
  final int reviewCount;
  final int correctCount;
  final int wrongCount;
  final DateTime? lastReviewed;
  final DateTime? nextReview;
  final bool isFavorite;

  /// 암기 완료 단계 (box 5 도달)
  bool get isMastered => box >= 5;

  /// 학습을 시작했는가
  bool get isLearning => reviewCount > 0;

  /// 복습 예정일이 지났는가
  bool get isDue {
    if (nextReview == null) return reviewCount == 0;
    return !nextReview!.isAfter(DateTime.now());
  }

  WordProgress copyWith({
    int? box,
    int? reviewCount,
    int? correctCount,
    int? wrongCount,
    DateTime? lastReviewed,
    DateTime? nextReview,
    bool? isFavorite,
  }) {
    return WordProgress(
      wordId: wordId,
      box: box ?? this.box,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'wordId': wordId,
        'box': box,
        'reviewCount': reviewCount,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'lastReviewed': lastReviewed?.toIso8601String(),
        'nextReview': nextReview?.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      wordId: (json['wordId'] ?? '') as String,
      box: (json['box'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      lastReviewed: json['lastReviewed'] == null
          ? null
          : DateTime.tryParse(json['lastReviewed'] as String),
      nextReview: json['nextReview'] == null
          ? null
          : DateTime.tryParse(json['nextReview'] as String),
      isFavorite: (json['isFavorite'] ?? false) as bool,
    );
  }
}

/// 학습 진도 / 스트릭 / 설정 저장 서비스
class ProgressService extends ChangeNotifier {
  static const String _progressBox = 'word_progress';
  static const String _metaBox = 'app_meta';

  static const String _kStreak = 'streak';
  static const String _kBestStreak = 'bestStreak';
  static const String _kLastStudyDate = 'lastStudyDate';
  static const String _kDailyGoal = 'dailyGoal';
  static const String _kDailyCount = 'dailyCount';
  static const String _kDailyDate = 'dailyDate';
  static const String _kSelectedLevels = 'selectedLevels';
  static const String _kStudyLog = 'studyLog';
  static const String _kTotalAnswered = 'totalAnswered';

  late Box<String> _progress;
  late Box _meta;

  bool _ready = false;
  bool get isReady => _ready;

  Map<String, WordProgress> _cache = <String, WordProgress>{};

  Future<void> init() async {
    await Hive.initFlutter();
    _progress = await Hive.openBox<String>(_progressBox);
    _meta = await Hive.openBox(_metaBox);
    _loadCache();
    _ensureDailyReset();
    _ready = true;
    notifyListeners();
  }

  void _loadCache() {
    _cache = <String, WordProgress>{};
    for (final String key in _progress.keys.cast<String>()) {
      final String? raw = _progress.get(key);
      if (raw == null) continue;
      try {
        final Map<String, dynamic> json =
            jsonDecode(raw) as Map<String, dynamic>;
        _cache[key] = WordProgress.fromJson(json);
      } catch (_) {
        // 손상된 데이터는 건너뜁니다.
      }
    }
  }

  // ─────────── 진도 조회 ───────────

  WordProgress progressOf(String wordId) =>
      _cache[wordId] ?? WordProgress(wordId: wordId);

  bool isFavorite(String wordId) => progressOf(wordId).isFavorite;

  Set<String> get favoriteIds => _cache.values
      .where((WordProgress p) => p.isFavorite)
      .map((WordProgress p) => p.wordId)
      .toSet();

  int get learnedCount =>
      _cache.values.where((WordProgress p) => p.isLearning).length;

  int get masteredCount =>
      _cache.values.where((WordProgress p) => p.isMastered).length;

  int get favoriteCount =>
      _cache.values.where((WordProgress p) => p.isFavorite).length;

  /// 오늘 복습 예정 단어 id 목록
  Set<String> dueWordIds(Iterable<String> candidateIds) {
    final Set<String> due = <String>{};
    for (final String id in candidateIds) {
      final WordProgress p = progressOf(id);
      if (p.isDue) due.add(id);
    }
    return due;
  }

  // ─────────── 학습 기록 ───────────

  Future<void> _persist(WordProgress p) async {
    _cache[p.wordId] = p;
    await _progress.put(p.wordId, jsonEncode(p.toJson()));
  }

  /// Leitner 간격(일): box 0→1일, 1→2일, 2→4일, 3→7일, 4→14일, 5→30일
  static const List<int> _intervals = <int>[1, 2, 4, 7, 14, 30];

  Future<void> recordAnswer(String wordId, {required bool known}) async {
    final WordProgress old = progressOf(wordId);
    final int newBox = known
        ? (old.box + 1).clamp(0, _intervals.length)
        : 0;
    final int days = _intervals[newBox.clamp(0, _intervals.length - 1)];
    final DateTime now = DateTime.now();

    await _persist(
      old.copyWith(
        box: newBox,
        reviewCount: old.reviewCount + 1,
        correctCount: old.correctCount + (known ? 1 : 0),
        wrongCount: old.wrongCount + (known ? 0 : 1),
        lastReviewed: now,
        nextReview: now.add(Duration(days: days)),
      ),
    );

    await _bumpDailyCount();
    await _meta.put(_kTotalAnswered, _totalAnswered + 1);
    notifyListeners();
  }

  int get _totalAnswered => (_meta.get(_kTotalAnswered) as int?) ?? 0;
  int get totalAnswered => _totalAnswered;

  Future<void> toggleFavorite(String wordId) async {
    final WordProgress old = progressOf(wordId);
    await _persist(old.copyWith(isFavorite: !old.isFavorite));
    notifyListeners();
  }

  // ─────────── 일일 목표 / 스트릭 ───────────

  int get dailyGoal => (_meta.get(_kDailyGoal) as int?) ?? 20;
  int get dailyCount => (_meta.get(_kDailyCount) as int?) ?? 0;
  int get streak => (_meta.get(_kStreak) as int?) ?? 0;
  int get bestStreak => (_meta.get(_kBestStreak) as int?) ?? 0;

  double get dailyProgress =>
      dailyGoal == 0 ? 0 : (dailyCount / dailyGoal).clamp(0.0, 1.0);

  bool get isDailyGoalDone => dailyCount >= dailyGoal;

  Future<void> setDailyGoal(int goal) async {
    await _meta.put(_kDailyGoal, goal);
    notifyListeners();
  }

  /// 선택된 급수 (기본 3~6급 전부)
  Set<int> get selectedLevels {
    final List<dynamic>? raw = _meta.get(_kSelectedLevels) as List<dynamic>?;
    if (raw == null || raw.isEmpty) return <int>{3, 4, 5, 6};
    return raw.map((dynamic e) => (e as num).toInt()).toSet();
  }

  Future<void> setSelectedLevels(Set<int> levels) async {
    await _meta.put(_kSelectedLevels, levels.toList()..sort());
    notifyListeners();
  }

  /// 오늘 날짜 키 (yyyy-MM-dd)
  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 날짜별 학습량 로그 { 'yyyy-MM-dd': count }
  Map<String, int> get studyLog {
    final String? raw = _meta.get(_kStudyLog) as String?;
    if (raw == null) return <String, int>{};
    try {
      final Map<String, dynamic> map =
          jsonDecode(raw) as Map<String, dynamic>;
      return map.map((String k, dynamic v) =>
          MapEntry<String, int>(k, (v as num).toInt()));
    } catch (_) {
      return <String, int>{};
    }
  }

  /// 오늘이 아닌 경우 일일 카운트 초기화
  void _ensureDailyReset() {
    final String today = dateKey(DateTime.now());
    final String? savedDate = _meta.get(_kDailyDate) as String?;
    if (savedDate != today) {
      _meta.put(_kDailyDate, today);
      _meta.put(_kDailyCount, 0);
    }
  }

  Future<void> _bumpDailyCount() async {
    final String today = dateKey(DateTime.now());
    _ensureDailyReset();
    final int count = ((_meta.get(_kDailyCount) as int?) ?? 0) + 1;
    await _meta.put(_kDailyCount, count);

    // 날짜별 로그 갱신
    final Map<String, int> log = studyLog;
    log[today] = (log[today] ?? 0) + 1;
    await _meta.put(_kStudyLog, jsonEncode(log));

    // 스트릭 갱신 (하루 첫 학습 시)
    final String? lastDate = _meta.get(_kLastStudyDate) as String?;
    if (lastDate != today) {
      final DateTime? last = lastDate == null ? null : DateTime.tryParse(lastDate);
      int newStreak = 1;
      if (last != null) {
        final DateTime lastDay = DateTime(last.year, last.month, last.day);
        final DateTime now = DateTime.now();
        final DateTime todayDay = DateTime(now.year, now.month, now.day);
        final int diff = todayDay.difference(lastDay).inDays;
        if (diff == 1) {
          newStreak = streak + 1;
        } else if (diff == 0) {
          newStreak = streak;
        } else {
          newStreak = 1;
        }
      }
      await _meta.put(_kStreak, newStreak);
      await _meta.put(_kLastStudyDate, today);
      if (newStreak > bestStreak) {
        await _meta.put(_kBestStreak, newStreak);
      }
    }
  }

  /// 스트릭이 끊겼는지 확인해 표시용으로 0 반환
  int get displayStreak {
    final String? lastDate = _meta.get(_kLastStudyDate) as String?;
    if (lastDate == null) return 0;
    final DateTime? last = DateTime.tryParse(lastDate);
    if (last == null) return 0;
    final DateTime today = DateTime.now();
    final int diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (diff <= 1) return streak;
    return 0;
  }

  /// 최근 n일 학습 로그 (오래된 순)
  List<MapEntry<DateTime, int>> recentDays(int n) {
    final Map<String, int> log = studyLog;
    final DateTime now = DateTime.now();
    final List<MapEntry<DateTime, int>> result = <MapEntry<DateTime, int>>[];
    for (int i = n - 1; i >= 0; i--) {
      final DateTime d = now.subtract(Duration(days: i));
      result.add(MapEntry<DateTime, int>(d, log[dateKey(d)] ?? 0));
    }
    return result;
  }

  /// 전체 진도 초기화
  Future<void> resetAll() async {
    await _progress.clear();
    _cache = <String, WordProgress>{};
    await _meta.clear();
    notifyListeners();
  }
}
