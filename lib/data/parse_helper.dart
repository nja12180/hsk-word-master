import '../models/word.dart';

/// 파이프(|)로 구분된 단어 표를 [Word] 목록으로 변환합니다.
///
/// 각 줄 형식: `한자|병음|뜻|품사|예문|예문해석`
List<Word> parseWordTable(String raw, int level, String prefix) {
  final words = <Word>[];
  final lines = raw.split('\n');
  var index = 0;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final parts = trimmed.split('|');
    if (parts.length < 4) continue;
    index++;
    words.add(
      Word(
        id: '${prefix}_${index.toString().padLeft(4, '0')}',
        hanzi: parts[0],
        pinyin: parts[1],
        meaning: parts[2],
        pos: parts[3],
        level: level,
        example: parts.length > 4 ? parts[4] : '',
        exampleKo: parts.length > 5 ? parts[5] : '',
      ),
    );
  }
  return words;
}
