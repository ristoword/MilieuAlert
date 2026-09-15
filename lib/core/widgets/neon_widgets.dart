/// Barrel file for MilieuAlert neon-themed widgets.
///
/// Import this file to get access to all reusable neon UI components.
library;

import 'package:flutter/material.dart';
import '../theme.dart';

/// A card with a neon glow border effect.
class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.glowOpacity = 0.3,
  });

  final Widget child;
  final LinearGradient? gradient;
  final EdgeInsets padding;
  final double borderRadius;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grad = gradient ?? NeonColors.primaryGradient;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: grad,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: grad.colors.first.withValues(alpha: glowOpacity),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: isDark ? NeonColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius - 1),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A button with a neon gradient background.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.gradient,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final LinearGradient? gradient;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final grad = gradient ?? NeonColors.primaryGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null ? grad : null,
        color: onPressed == null ? Colors.grey.shade700 : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: grad.colors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// A text widget with an optional neon glow effect.
class NeonText extends StatelessWidget {
  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.glowColor,
    this.enableGlow = true,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final Color? glowColor;
  final bool enableGlow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ?? NeonColors.cyan;
    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      color: textColor,
    );

    if (!enableGlow || !isDark) {
      return Text(text, style: effectiveStyle);
    }

    return Text(
      text,
      style: effectiveStyle.copyWith(
        shadows: [
          Shadow(
            color: (glowColor ?? textColor).withValues(alpha: 0.6),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

/// A container with a neon gradient border.
class NeonBorderContainer extends StatelessWidget {
  const NeonBorderContainer({
    super.key,
    required this.child,
    this.gradient,
    this.borderWidth = 1.5,
    this.borderRadius = 12,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final LinearGradient? gradient;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grad = gradient ?? NeonColors.borderGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: isDark ? NeonColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
