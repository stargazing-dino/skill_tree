import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controls the theming of the overall skill tree. Setting a property here
/// applies it to all nodes and edges. These properties are global to the tree
/// but can be overridden by individual nodes or edges.
///
/// Note, if no theme is given, a default theme is created following the
/// [ThemeData] of the app.
@immutable
class SkillTreeThemeData with Diagnosticable {
  // TODO: Implement.
}

class SkillTreeTheme extends StatelessWidget {
  const SkillTreeTheme({
    Key? key,
    required this.data,
    required this.child,
  }) : super(key: key);

  final SkillTreeThemeData data;

  final Widget child;

  static SkillTreeThemeData of(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedSkillTheme>();

    final _fallbackTheme = SkillTreeThemeData();

    return inheritedTheme?.theme.data ?? _fallbackTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _InheritedSkillTheme extends InheritedWidget {
  const _InheritedSkillTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  final SkillTreeTheme theme;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    throw UnimplementedError();
  }
}
