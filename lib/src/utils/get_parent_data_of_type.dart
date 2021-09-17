import 'package:flutter/rendering.dart';

/// Walks up the child parent tree looking for a [RenderObjectElement] that
/// is of type [ParentDataType], returning null if none is found.
ParentDataType? getParentDataOfType<ParentDataType extends ParentData>(
  RenderBox child,
) {
  var currentParent = child.parent as RenderObject?;

  while (currentParent != null) {
    if (currentParent.parentData == null) {
      return null;
    }

    if (currentParent.parentData is ParentDataType) {
      return currentParent.parentData as ParentDataType;
    }

    currentParent = currentParent.parent as RenderObject?;
  }
}
