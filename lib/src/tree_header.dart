import 'package:flutter/material.dart';
import 'package:skill_tree/src/drag_node.dart';

class TreeHeader extends StatefulWidget {
  final List<Widget> keylessChildren;

  final VoidCallback onAdd;

  final void Function(DragNode other) onAccept;

  final double height;

  const TreeHeader({
    Key? key,
    required this.keylessChildren,
    required this.onAdd,
    required this.onAccept,
    required this.height,
  }) : super(key: key);

  @override
  _TreeHeaderState createState() => _TreeHeaderState();
}

class _TreeHeaderState extends State<TreeHeader> {
  // This needs to have it's own controller
  // https://stackoverflow.com/questions/52484710/flutter-scrollcontroller-attached-to-multiple-scroll-views
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: Card(
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: InkWell(
                onTap: widget.onAdd,
                child: Icon(Icons.add, size: 34),
              ),
            ),
            VerticalDivider(width: 0),
            Expanded(
              child: DragTarget<DragNode>(
                onAccept: widget.onAccept,
                builder: (context, _, __) {
                  return Scrollbar(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: GridView.count(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        controller: _controller,
                        shrinkWrap: true,
                        crossAxisSpacing: 16.0,
                        crossAxisCount: 3,
                        children: widget.keylessChildren,
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
