import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/layout.dart';

// A circular skill tree. I know there's a game that does this, but I'm not
// sure which.
class RadialLayout extends Layout {
  @override
  Size layout({
    required BoxConstraints constraints,
    required List<RenderBox> children,
    required Graph graph,
  }) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}
