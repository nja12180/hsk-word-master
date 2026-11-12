import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 중국어 발음(TTS) 서비스
///
/// - Android/iOS: 기기 내장 TTS 엔진 (zh-CN)
/// - Web: 브라우저 Web Speech API (Chrome/Edge/Safari 지원)
///
/// 엔진이 없는 환경(일부 Linux 등)에서도 앱이 죽지 않도록
/// 모든 호출을 안전하게 감싸고, 사용 가능 여부를 노출합니다.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;

  /// TTS 엔진 자체가 없는 플랫폼 → 버튼 비활성 표시용
  bool _available = true;

  /// 중국어(zh) 음성 팩이 설치되지 않은 기기 → 경고 문구 표시용
  bool _languageMissing = false;

  /// TTS 호출이 실제로 실패했는지 여부 (버튼 활성/비활성 판단)
  bool get isAvailable => _available;

  /// 중국어 음성 팩 미설치 기기인지 여부
  bool get isLanguageMissing => _languageMissing;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.42);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);

      if (!kIsWeb) {
        // iOS에서 무음 모드일 때도 소리가 나도록 (Android는 no-op)
        try {
          await _tts.setSharedInstance(true);
        } catch (_) {
          // 미지원 플랫폼은 무시
        }

        // 네이티브에서는 음성 목록을 동기적으로 알 수 있으므로 미리 검사
        try {
          final dynamic languages = await _tts.getLanguages;
          if (languages is List) {
            final bool hasChinese = languages.any(
              (dynamic l) => l is String && l.toLowerCase().startsWith('zh'),
            );
            if (!hasChinese) {
              _languageMissing = true;
              debugPrint('[SpeechService] 중국어 음성 미지원 기기');
            }
          }
        } catch (_) {
          // 목록 조회 실패는 치명적이지 않음 (발화는 그대로 시도)
        }
      }
      // 웹은 음성 목록이 비동기로 로드되므로 언어 검사를 건너뜁니다.
      // (검사하면 정상 동작하는 브라우저에서도 경고가 뜸)
    } catch (e) {
      // TTS 엔진이 없는 플랫폼(웹 미지원 브라우저, 리눅스 등)
      debugPrint('[SpeechService] TTS 초기화 실패: $e');
    }
  }

  /// 단어 발음 재생 (한자 문자열을 그대로 읽습니다)
  Future<void> speak(String text) async {
    final String target = text.trim();
    if (target.isEmpty) return;

    if (!_initialized) {
      await init();
    }

    try {
      await _tts.stop();
      await _tts.setLanguage('zh-CN');
      await _tts.speak(target);
    } catch (e) {
      _available = false;
      debugPrint('[SpeechService] 발화 실패: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // 무시
    }
  }
}
