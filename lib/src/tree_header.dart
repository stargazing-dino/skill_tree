import 'package:flutter/material.dart';
import 'package:skill_tree/src/drag_node.dart';

// If this breaks because "multiple scroll controllers attached" then just
// create a controller here and pass it Gridview
// https://stackoverflow.com/questions/52484710/flutter-scrollcontroller-attached-to-multiple-scroll-views

class TreeHeader extends StatelessWidget {
  final List<Widget> unnattachedChildren;

  final VoidCallback onAdd;

  final void Function(DragNode other) onAccept;

  final double height;

  final double elevation;

  const TreeHeader({
    Key? key,
    required this.unnattachedChildren,
    required this.onAdd,
    required this.onAccept,
    required this.height,
    required this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        elevation: elevation,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: InkWell(
                onTap: onAdd,
                child: Icon(Icons.add, size: 34),
              ),
            ),
            const VerticalDivider(width: 0),
            Expanded(
              child: DragTarget<DragNode>(
                onAccept: onAccept,
                builder: (context, _, __) {
                  return Scrollbar(
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisSpacing: 16.0,
                      crossAxisCount: 3,
                      children: unnattachedChildren,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
