import 'package:flutter/rendering.dart';

/// Walks up the child parent tree looking for a [RenderObjectElement] that
/// is of type [ParentDataType], returning null if none is found.
ParentDataType? getParentDataOfType<ParentDataType extends ParentData>(
  RenderBox child,
) {
  RenderObject? current = child;

  while (current != null) {
    if (current.parentData is ParentDataType) {
      return current.parentData as ParentDataType;
    }

    current = current.parent as RenderObject?;
  }
}
