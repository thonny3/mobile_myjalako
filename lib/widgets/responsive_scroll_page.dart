import 'package:flutter/material.dart';
import '../responsive.dart';

/// Page scrollable avec padding horizontal responsive.
class ResponsiveScrollPage extends StatelessWidget {
  final double bottomPadding;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveScrollPage({
    super.key,
    required this.children,
    this.bottomPadding = 0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: r.pageInsets(bottom: bottomPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
