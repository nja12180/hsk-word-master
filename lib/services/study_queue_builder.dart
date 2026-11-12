import 'dart:math';

import '../data/word_repository.dart';
import '../models/word.dart';
import 'progress_service.dart';

/// 오늘의 학습 카드 큐를 구성하는 서비스
class StudyQueueBuilder {
  StudyQueueBuilder._();

  /// 학습 큐 생성
  ///
  /// [goals]: 선택된 급수 집합
  /// [size]: 오늘 학습할 카드 수
  /// [service]: 진도 서비스 (복습 우선순위 판단)
  static List<Word> build({
    required Set<int> goals,
    required int size,
    required ProgressService service,
    bool reviewOnly = false,
  }) {
    final List<Word> pool = WordRepository.byLevels(goals);
    if (pool.isEmpty) return <Word>[];

    final List<Word> due = <Word>[];
    final List<Word> weak = <Word>[];
    final List<Word> fresh = <Word>[];

    for (final Word w in pool) {
      final WordProgress p = service.progressOf(w.id);
      if (p.isDue && p.reviewCount > 0) {
        due.add(w);
      } else if (p.reviewCount > 0 && !p.isMastered) {
        weak.add(w);
      } else if (p.reviewCount == 0) {
        fresh.add(w);
      }
    }

    // 복습 우선 → 부족하면 학습 중 단어 → 신규 단어 순으로 채움
    final List<Word> result = <Word>[];
    result.addAll(due);
    if (!reviewOnly) {
      result.addAll(weak);
      result.addAll(fresh);
    }

    // 중복 제거
    final Map<String, Word> unique = <String, Word>{};
    for (final Word w in result) {
      unique.putIfAbsent(w.id, () => w);
    }

    final List<Word> ordered = unique.values.toList();
    if (ordered.length <= size) return ordered;
    return ordered.sublist(0, size);
  }

  /// 주어진 단어 목록에서 오답 보기 3개를 뽑는 헬퍼
  static List<Word> distractors({
    required Word answer,
    required List<Word> pool,
    int count = 3,
    Random? random,
  }) {
    final Random rnd = random ?? Random();
    final List<Word> candidates = pool
        .where((Word w) =>
            w.id != answer.id && w.meaning.trim() != answer.meaning.trim())
        .toList();
    candidates.shuffle(rnd);
    return candidates.take(count).toList();
  }
}
