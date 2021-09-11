import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/widgets/draggable_edge.dart';

// TODO: Allow for builder to be passed in instead of this
class DraggablePoint extends ParentDataWidget<PointParentData> {
  const DraggablePoint({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  Type get debugTypicalAncestorWidgetClass => DraggableEdge;

  @override
  void applyParentData(RenderObject renderObject) {}
}


// Draggable(
//   feedback: const SizedBox(),
//   child: Container(
//     height: 10.0,
//     width: 10.0,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(16.0),
//       color: Colors.white,
//     ),
//   ),
// )