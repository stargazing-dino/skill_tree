import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/node.dart';

class DraggableNode<NodeType, IdType extends Object> extends StatefulWidget {
  const DraggableNode({
    Key? key,
    required this.child,
    required this.node,
    required this.onSwapNode,
    this.feedbackOpacity = 0.5,
  }) : super(key: key);

  final Widget child;

  final Node<NodeType, IdType> node;

  final void Function(Node<NodeType, IdType> node) onSwapNode;

  final double feedbackOpacity;

  @override
  State<DraggableNode<NodeType, IdType>> createState() =>
      _DraggableNodeState<NodeType, IdType>();
}

class _DraggableNodeState<NodeType, IdType extends Object>
    extends State<DraggableNode<NodeType, IdType>> {
  @override
  Widget build(BuildContext context) {
    // TODO the four sides of the node should have a DragTarget for the
    // [EdgePoint] to be connected to. I would honestly like to do four
    // triangles whose inner vertices meet in the center
    // https://stackoverflow.com/questions/56930636/flutter-button-with-custom-shape-triangle

    return Draggable<Node<NodeType, IdType>>(
      data: widget.node,
      child: DragTarget<Node<NodeType, IdType>>(
        onAccept: widget.onSwapNode,
        builder: (
          BuildContext context,
          List<Node<NodeType, IdType>?> candidateData,
          List<dynamic> rejectedData,
        ) {
          if (candidateData.isEmpty) {
            return widget.child;
          } else {
            // If we're hovering over ourself just show the child
            if (candidateData.any((data) => data?.id == widget.node.id)) {
              return widget.child;
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10.0,
                    spreadRadius: 6.0,
                  ),
                ],
              ),
              child: widget.child,
            );
          }
        },
      ),
      feedback: Opacity(
        child: widget.child,
        opacity: widget.feedbackOpacity,
      ),
    );
  }
}
