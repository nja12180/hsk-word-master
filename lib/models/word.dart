/// HSK 3.0 단어 모델
///
/// [level] 값은 3, 4, 5, 6 중 하나입니다.
class Word {
  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String pos;
  final int level;
  final String example;
  final String exampleKo;

  const Word({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.pos,
    required this.level,
    this.example = '',
    this.exampleKo = '',
  });

  /// 검색용 통합 문자열 (한자 / 병음 / 뜻 / 예문)
  String get searchKey => '$hanzi $pinyin $meaning $example';
}
