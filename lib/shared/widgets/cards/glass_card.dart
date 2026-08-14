import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Glass Card — Glassmorphic container widget
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.gradient,
    this.onTap,
    this.borderRadius = AppSpacing.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSpacing.animNormal,
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                colors: isDark
                    ? [AppColors.darkCard, AppColors.darkCard.withValues(alpha: 0.8)]
                    : [AppColors.lightCard, AppColors.lightCard.withValues(alpha: 0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          child: child,
        ),
      ),
    );
  }
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Stat Card — Dashboard metric card with gradient
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.gradient,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppSpacing.animNormal,
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(_isHovered ? 1.02 : 1.0, _isHovered ? 1.02 : 1.0, 1.0),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 24),
                  ),
                  if (widget.trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.trendUp ? Icons.trending_up : Icons.trending_down,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.trend!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
