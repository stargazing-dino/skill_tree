import 'package:flutter/material.dart';

// TODO: This needs to be more customizable

class DragNode extends StatelessWidget {
  final Widget? child;

  final int i;

  final int j;

  final void Function(DragNode current, DragNode other) onAccept;

  final bool isEditable;

  final WidgetBuilder? placeholderBuilder;

  const DragNode({
    Key? key,
    required this.child,
    required this.i,
    required this.j,
    required this.onAccept,
    required this.isEditable,
    this.placeholderBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeHolderStyle = theme.textTheme.subtitle1 ??
        TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        );

    final placeholder = isEditable
        ? CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            minRadius: 40,
            child: Center(
              child: Text(
                'Drag\nhere',
                textAlign: TextAlign.center,
                style: placeHolderStyle,
              ),
            ),
          )
        : Container();

    return DragTarget<DragNode>(
      key: key,
      onAccept: (node) => onAccept(this, node),
      builder: (context, _, __) {
        final childNode = child;

        if (childNode == null) {
          // Simple drag target
          return placeholder;
        } else if (i == -1 || j == -1) {
          // Keyless children
          return Draggable<DragNode>(
            feedback: childNode,
            childWhenDragging: Container(),
            data: this,
            child: childNode,
          );
        } else {
          if (isEditable) {
            return Draggable<DragNode>(
              feedback: childNode,
              childWhenDragging: placeholder,
              data: this,
              child: childNode,
            );
          }

          return childNode;
        }
      },
    );
  }
}
