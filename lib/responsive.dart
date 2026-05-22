import 'package:flutter/material.dart';

/// Utilitaires responsive pour téléphones et tablettes.
class AppResponsive {
  AppResponsive(this.context);

  final BuildContext context;

  static const double _designWidth = 390;

  Size get size => MediaQuery.sizeOf(context);
  double get width => size.width;
  double get height => size.height;
  EdgeInsets get viewPadding => MediaQuery.paddingOf(context);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(context);

  bool get isSmallPhone => width < 360;
  bool get isMediumPhone => width >= 360 && width < 400;
  bool get isLargePhone => width >= 400 && width < 600;
  bool get isTablet => width >= 600;
  bool get isShortScreen => height < 680;

  double get scale => (width / _designWidth).clamp(0.82, 1.15);

  double get horizontalPadding {
    if (isSmallPhone) return 14;
    if (isMediumPhone) return 18;
    if (isTablet) return 28;
    return 20;
  }

  double get maxContentWidth => isTablet ? 520 : width;

  double get logoSize {
    if (isSmallPhone) return 72;
    if (isShortScreen) return 84;
    return 100;
  }

  double sp(double value) => (value * scale).clamp(value * 0.82, value * 1.12);

  double get titleLarge => sp(26);
  double get titleMedium => sp(22);
  double get bodySize => sp(14);
  double get labelSize => sp(12);
  double get balanceAmountSize => sp(isSmallPhone ? 28 : 34);
  double get sectionTitleSize => sp(17);
  double get navLabelSize => isSmallPhone ? 10 : 11;
  double get quickActionSize => isSmallPhone ? 52 : 60;
  double get headerBottomPadding => isShortScreen ? 36 : 48;

  double get bottomNavHeight => 76 + viewPadding.bottom + 24;

  EdgeInsets pageInsets({double bottom = 0, double top = 0}) {
    return EdgeInsets.fromLTRB(
      horizontalPadding,
      top,
      horizontalPadding,
      bottom,
    );
  }

  EdgeInsets headerInsets() {
    return EdgeInsets.fromLTRB(
      horizontalPadding,
      sp(20),
      horizontalPadding,
      headerBottomPadding,
    );
  }
}

extension ResponsiveContext on BuildContext {
  AppResponsive get responsive => AppResponsive(this);
}

/// Centre le contenu et limite la largeur sur tablette.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return ColoredBox(
      color: backgroundColor ?? const Color(0xFFF8F9F8),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}
