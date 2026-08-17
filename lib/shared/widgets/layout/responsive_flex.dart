import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// Responsive Flex Layout — Adapts dynamically
/// Mobile: Renders children in vertical Column (unwrapping Expanded)
/// Tablet & Web/Desktop: Renders children in horizontal Row
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;
  final double breakpoint;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.spacing = 16.0,
    this.breakpoint = 768.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final isCompact = screenWidth < breakpoint;

    if (isCompact) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            _unwrapExpanded(children[i]),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          children[i],
        ],
      ],
    );
  }

  Widget _unwrapExpanded(Widget widget) {
    if (widget is Expanded) {
      return widget.child;
    }
    if (widget is Flexible) {
      return widget.child;
    }
    return widget;
  }
}
