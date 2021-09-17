import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skill_tree/src/models/node.dart';

typedef WrapWidget = Widget Function(BuildContext context, Widget child);

// TODO: onUpdate

/// This class is wrapped by a SkillNode and provides a draggable interface for
/// nodes. The update strategy for moving nodes is determined by the user.
class DragableSkillNode<NodeType, IdType extends Object> extends StatelessWidget
    implements Node<NodeType, IdType> {
  const DragableSkillNode({
    Key? key,
    required this.child,
    required this.data,
    required this.id,
    // TODO: Make all of this required
    this.depth,
    this.name,
    this.requirement,
    this.buildFeedback,
    this.buildPlaceholder,
    this.isDraggable = true,
  }) : super(key: key);

  final Widget child;

  @override
  final NodeType? data;

  @override
  final IdType id;

  @override
  final String? name;

  /// Related to rendering. This is used to determine the placement of the node
  /// in the tree.
  final int? depth;

  /// Related to rendering. This is used to determine whether this node has
  /// been acquired or not.
  final int? requirement;

  final WrapWidget? buildFeedback;

  final WidgetBuilder? buildPlaceholder;

  final bool isDraggable;

  @override
  Widget build(BuildContext context) {
    if (!isDraggable) return child;

    final _buildFeedback = buildFeedback;

    return DragTarget<DragableSkillNode<NodeType, IdType>>(
      onAccept: (node) {
        // TODO:
      },
      builder: (
        BuildContext context,
        List<DragableSkillNode<NodeType, IdType>?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return Draggable<DragableSkillNode<NodeType, IdType>>(
          onDragStarted: () {
            // TODO:
          },
          child: child,
          feedback: _buildFeedback?.call(context, child) ??
              defaultBuildFeedback(context, child),
          childWhenDragging: buildPlaceholder?.call(context) ??
              defaultBuildPlaceHolder(context),
          data: this,
        );
      },
    );
  }

  static Widget defaultBuildPlaceHolder(BuildContext context) {
    return const Text('drag here');
  }

  static Widget defaultBuildFeedback(BuildContext context, Widget child) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }
}
