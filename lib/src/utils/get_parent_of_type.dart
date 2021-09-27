import 'package:flutter/rendering.dart';

/// Walks up the child parent tree looking for a [RenderObjectElement] that
/// is of type [ParentDataType], returning null if none is found.
ParentType? getParentOfType<ParentType extends RenderObject>(
  RenderBox child,
) {
  RenderObject? current = child;

  while (current != null) {
    if (current is ParentType) {
      return current;
    }

    current = current.parent as RenderObject?;
  }
}
