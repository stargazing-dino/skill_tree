import 'package:flutter/rendering.dart';

/// Walks up the child parent tree looking for a [RenderObjectElement] that
/// is of type [ParentDataType], returning null if none is found.
ParentType? getParentOfType<ParentType extends RenderObject>(
  RenderBox child,
) {
  var currentParent = child.parent as RenderObject?;

  while (currentParent != null) {
    if (currentParent.parent == null) {
      return null;
    }

    if (currentParent.parent is ParentType) {
      return currentParent.parent as ParentType;
    }

    currentParent = currentParent.parent as RenderObject?;
  }
}
