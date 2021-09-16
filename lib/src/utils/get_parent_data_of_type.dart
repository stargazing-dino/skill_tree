import 'package:flutter/rendering.dart';

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
