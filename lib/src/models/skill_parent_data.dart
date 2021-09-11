import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';

/// This is the parent class of [SkillEdgeParentData] and [SkillNodeChildData].
/// It's an almost pointless class other than to provide a common base for
/// ParentDataWidget<T> which was not designed to work with mutliple types
/// of data.
class SkillParentData extends ContainerBoxParentData<RenderBox> {
  Widget? skillWidget;
}

// TODO: We should pass through types here
class SkillParentWidget extends ParentDataWidget<SkillParentData> {
  const SkillParentWidget({
    Key? key,
    required Widget child,
    required this.skillWidget,
  }) : super(key: key, child: child);

  final Widget skillWidget;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as SkillParentData;

    if (parentData.skillWidget != skillWidget) {
      bool needsLayout = false;
      bool needsPaint = false;

      final _skillWidget = parentData.skillWidget;

      if (_skillWidget is SkillNode) {
        assert(skillWidget is SkillNode);
        final skillNode = skillWidget as SkillNode;

        if (_skillWidget.depth != skillNode.depth) {
          needsLayout = true;
        } else if (_skillWidget.name != skillNode.name) {
          needsPaint = true;
        } else if (_skillWidget.data != skillNode.data) {
          needsLayout = true;
        } else if (_skillWidget.id != skillNode.id) {
          needsLayout = true;
        } else if (_skillWidget.child != skillNode.child) {
          needsLayout = true;
        }
      } else if (_skillWidget is SkillEdge) {
        assert(skillWidget is SkillEdge);

        final skillEdge = skillWidget as SkillEdge;

        if (_skillWidget.from != skillEdge.from) {
          needsLayout = true;
        } else if (_skillWidget.to != skillEdge.to) {
          needsLayout = true;
        } else if (_skillWidget.data != skillEdge.data) {
          needsLayout = true;
        } else if (_skillWidget.id != skillEdge.id) {
          needsLayout = true;
        }
      } else {
        throw Exception('Unknown skill widget type $_skillWidget');
      }

      parentData.skillWidget = skillWidget;

      needsLayout = true;

      if (needsLayout) {
        final AbstractNode? targetParent = renderObject.parent;
        if (targetParent is RenderObject) targetParent.markNeedsLayout();
      }

      if (needsPaint) {
        final AbstractNode? targetParent = renderObject.parent;
        if (targetParent is RenderObject) targetParent.markNeedsPaint();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SkillParentData;
}
