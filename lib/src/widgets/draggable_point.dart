import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/edge.dart';

class DraggablePoint<EdgeType, IdType extends Object> extends StatefulWidget {
  const DraggablePoint({
    Key? key,
    required this.child,
    required this.edge,
    required this.onDropPoint,
    this.feedbackOpacity = 0.5,
  }) : super(key: key);

  final Widget child;

  final Edge<EdgeType, IdType> edge;

  final void Function(Edge<EdgeType, IdType> edge) onDropPoint;

  final double feedbackOpacity;

  @override
  State<DraggablePoint<EdgeType, IdType>> createState() =>
      _DraggablePointState<EdgeType, IdType>();
}

class _DraggablePointState<EdgeType, IdType extends Object>
    extends State<DraggablePoint<EdgeType, IdType>> {
  @override
  Widget build(BuildContext context) {
    return Draggable<Edge<EdgeType, IdType>>(
      data: widget.edge,
      child: DragTarget<Edge<EdgeType, IdType>>(
        onAccept: widget.onDropPoint,
        builder: (
          BuildContext context,
          List<Edge<EdgeType, IdType>?> candidateData,
          List<dynamic> rejectedData,
        ) {
          if (candidateData.isEmpty) {
            return widget.child;
          } else {
            // If we're hovering over ourself just show the child
            if (candidateData.any((data) => data?.id == widget.edge.id)) {
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
