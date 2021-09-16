import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/skill_tree.dart';

// TODO: This one decision has guided a lot of bad code. In the future, I want
// there to be two classes of SkillParentData -> One for nodes and one for
// edges. I've tried a few times myself but every time I did I got some random
// assertion error or something.

/// This is the parent class of [SkillEdgeParentData] and [SkillNodeChildData].
/// It's an almost pointless class other than to provide a common base for
/// ParentDataWidget<T> which was not designed to work with mutliple types
/// of data.
class SkillParentData extends ContainerBoxParentData<RenderBox> {
  Widget? skillWidget;

  /// Only available when the skillWidget is a [SkillEdge]
  List<RenderBox>? nodePositions;
}

class SkillParentWidget<EdgeType extends Object, NodeType extends Object,
    IdType extends Object> extends ParentDataWidget<SkillParentData> {
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
      parentData.skillWidget = skillWidget;

      bool needsLayout = false;
      bool needsPaint = false;

      final _skillWidget = parentData.skillWidget;

      if (_skillWidget is SkillNode<NodeType, IdType>) {
        assert(skillWidget is SkillNode<NodeType, IdType>);
        final skillNode = skillWidget as SkillNode<NodeType, IdType>;

        if (_skillWidget.name != skillNode.name) {
          needsPaint = true;
        } else if (_skillWidget.data != skillNode.data) {
          needsLayout = true;
        } else if (_skillWidget.id != skillNode.id) {
          needsLayout = true;
        } else if (_skillWidget.child != skillNode.child) {
          needsLayout = true;
        }
      } else if (_skillWidget is SkillEdge<EdgeType, NodeType, IdType>) {
        assert(skillWidget is SkillEdge<EdgeType, NodeType, IdType>);

        final skillEdge = skillWidget as SkillEdge<EdgeType, NodeType, IdType>;

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
