import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 급수 뱃지 (3급 민트 / 4급 하늘 / 5급 보라 / 6급 베리)
class LevelPill extends StatelessWidget {
  const LevelPill({
    super.key,
    required this.level,
    this.compact = false,
    this.solid = true,
  });

  final int level;
  final bool compact;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.levelColor(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        gradient: solid ? AppColors.levelGradient(level) : null,
        color: solid ? null : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 11 : 13,
            color: solid ? Colors.white : color,
          ),
          const SizedBox(width: 3),
          Text(
            'HSK $level급',
            style: TextStyle(
              fontSize: compact ? 10.5 : 12,
              fontWeight: FontWeight.w800,
              color: solid ? Colors.white : color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 둥글둥글 그라데이션 버튼
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.color,
    this.icon,
    this.filled = true,
    this.expand = true,
    this.height = 56,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? color;
  final IconData? icon;
  final bool filled;
  final bool expand;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color base = color ?? AppColors.coral;
    final bool disabled = onPressed == null;

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(
            icon,
            size: fontSize + 3,
            color: filled ? Colors.white : base,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: filled ? Colors.white : base,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: filled ? (gradient ?? LinearGradient(colors: <Color>[base, base])) : null,
          color: filled ? null : Colors.white,
          borderRadius: BorderRadius.circular(height / 2),
          border: filled ? null : Border.all(color: base.withValues(alpha: 0.45), width: 1.8),
          boxShadow: filled && !disabled ? AppShadows.colored(base) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// 진행률 링
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 76,
    this.stroke = 9,
    this.colors = const <Color>[AppColors.coral, AppColors.peach],
    this.child,
    this.trackColor,
  });

  final double value;
  final double size;
  final double stroke;
  final List<Color> colors;
  final Widget? child;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double v, Widget? _) {
                return CircularProgressIndicator(
                  value: v,
                  strokeWidth: stroke,
                  strokeCap: StrokeCap.round,
                  backgroundColor: trackColor ?? Colors.white.withValues(alpha: 0.42),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.first),
                );
              },
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// 가로 진행 바
class ChunkyProgressBar extends StatelessWidget {
  const ChunkyProgressBar({
    super.key,
    required this.value,
    this.height = 12,
    this.gradient,
    this.trackColor,
  });

  final double value;
  final double height;
  final Gradient? gradient;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: trackColor ?? Colors.white.withValues(alpha: 0.45),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double v, Widget? _) {
                return Container(
                  width: c.maxWidth * v,
                  decoration: BoxDecoration(
                    gradient: gradient ?? AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(height),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// 섹션 타이틀
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.emoji,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (emoji != null) ...<Widget>[
          Text(emoji!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 7),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// 빈 상태 표시
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.emoji = '🧸',
    this.sub,
  });

  final String message;
  final String emoji;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (sub != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                sub!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
