import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/models/layout.dart';

/// A graph whose nodes are repulsed from others
/// See here https://pub.dev/packages/graphview#directed-graph
class DirectedLayout extends Layout {
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
