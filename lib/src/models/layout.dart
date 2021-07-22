import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/graph.dart';

/// Defines the structure a layout must have to be used as a layout.
abstract class Layout {
  Size layout({
    required BoxConstraints constraints,
    required List<RenderBox> children,
    required Graph graph,
  });
}
