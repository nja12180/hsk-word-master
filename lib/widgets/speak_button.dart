import 'package:flutter/material.dart';

import '../services/speech_service.dart';
import '../theme/app_theme.dart';

/// 중국어 발음 재생 버튼 (탭하면 재생 중 펄스 애니메이션)
class SpeakButton extends StatefulWidget {
  const SpeakButton({
    super.key,
    required this.text,
    this.color,
    this.size = 44,
    this.iconSize = 20,
    this.bordered = false,
  });

  /// 읽을 텍스트 (보통 한자)
  final String text;
  final Color? color;
  final double size;
  final double iconSize;
  final bool bordered;

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0,
      upperBound: 1,
    );
    SpeechService.instance.init();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_playing) {
      await SpeechService.instance.stop();
      setState(() => _playing = false);
      _pulse.stop();
      return;
    }

    setState(() => _playing = true);
    _pulse.repeat(reverse: true);

    final Future<void> speech = SpeechService.instance.speak(widget.text);

    // 발화 완료 콜백을 지원하지 않는 플랫폼(웹 등)에서도
    // 애니메이션이 최소 시간 동안 유지되도록 합니다.
    final int estimatedMs = 500 + (widget.text.length * 260);
    final Future<void> minimum = Future<void>.delayed(
      Duration(milliseconds: estimatedMs.clamp(700, 2600)),
    );

    await Future.wait<void>(<Future<void>>[speech, minimum]);
    if (!mounted) return;
    setState(() => _playing = false);
    _pulse.stop();
    _pulse.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final Color c = widget.color ?? AppColors.coral;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        final double scale = 1 + (_pulse.value * 0.09);
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: _play,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _playing
                ? c
                : (widget.bordered
                    ? Colors.white
                    : c.withValues(alpha: 0.12)),
            shape: BoxShape.circle,
            border: widget.bordered
                ? Border.all(color: c.withValues(alpha: 0.45), width: 2)
                : null,
            boxShadow: _playing ? AppShadows.colored(c) : null,
          ),
          child: Icon(
            _playing
                ? Icons.graphic_eq_rounded
                : Icons.volume_up_rounded,
            size: widget.iconSize,
            color: _playing
                ? Colors.white
                : (widget.bordered ? c : c),
          ),
        ),
      ),
    );
  }
}
