import 'package:flutter/material.dart';
import 'package:skill_tree/src/tree_header.dart';

import 'button_group.dart';
import 'drag_node.dart';

class SkillTree extends StatefulWidget {
  final List<Widget> children;

  final List<List<String?>> layout;

  final VoidCallback onTap;

  final VoidCallback onAddChild;

  final EdgeInsets padding;

  final EdgeInsets tilePadding;

  final ValueChanged<List<List<String?>>> onUpdate;

  final bool isEditable;

  final bool ignoreMissingChild;

  final double headerHeight;

  final double editPadding;

  const SkillTree({
    required this.children,
    required this.onTap,
    required this.onAddChild,
    required this.onUpdate,
    this.layout = const [
      [null, null]
    ],
    this.padding = const EdgeInsets.all(12.0),
    this.tilePadding = const EdgeInsets.symmetric(vertical: 6.0),
    this.isEditable = true,
    this.ignoreMissingChild = false,
    this.headerHeight = 80.0,
    this.editPadding = 26.0,
  });

  @override
  _SkillTreeState createState() => _SkillTreeState();
}

class _SkillTreeState extends State<SkillTree> {
  late List<List<String?>> _layout;
  late List<List<Widget>> _nodes;
  late List<Widget> _keylessNodes;

  static const maxItems = 4;

  @override
  void initState() {
    _getNodes();
    super.initState();
  }

  @override
  void didUpdateWidget(SkillTree oldWidget) {
    if (widget.layout != oldWidget.layout ||
        widget.children != oldWidget.children) {
      _getNodes();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final children = _nodes
        .asMap()
        .map(
          (int rowIndex, nodeRow) {
            return MapEntry(
              rowIndex,
              Padding(
                key: ValueKey('$rowIndex,${nodeRow.length}'),
                padding: widget.tilePadding,
                child: IntrinsicHeight(
                  child: Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: nodeRow.toList(),
                      ),
                      if (widget.isEditable) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ButtonGroup(
                            onAdd: () => _onAdd(rowIndex, false),
                            onRemove: () => _onRemove(rowIndex, false),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ButtonGroup(
                            onAdd: () => _onAdd(rowIndex),
                            onRemove: () => _onRemove(rowIndex),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        )
        .values
        .toList();

    if (widget.isEditable) {
      return Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          GestureDetector(
            onTap: widget.onTap.call,
            // TODO: Await https://github.com/flutter/flutter/issues/41334
            child: ListView(
              cacheExtent: 600.0,
              shrinkWrap: true,
              children: children,
              padding: widget.padding.copyWith(
                top: widget.headerHeight +
                    widget.padding.top +
                    widget.tilePadding.top,
                bottom: widget.padding.bottom + 32.0,
              ),
            ),
            // child: ReorderableListView(
            //   padding: widget.padding,
            //   header: TreeHeader(
            //     keylessChildren: _keylessNodes,
            //     onAdd: widget.onAddChild,
            //     onAccept: (other) {
            //       setState(() => _layout[other.i][other.j] = null);
            //       widget.onUpdate?.call(_layout);
            //     },
            //   ),
            //   onReorder: (int oldIndex, int newIndex) {
            //     if (newIndex > oldIndex) newIndex -= 1;

            //     final item = _layout.removeAt(oldIndex);
            //     setState(() => _layout.insert(newIndex, item));
            //     widget.onUpdate?.call(_layout);
            //   },
            //   children: children,
            // ),
          ),
          Container(
            padding: widget.padding,
            alignment: Alignment.topCenter,
            child: TreeHeader(
              height: widget.headerHeight,
              keylessChildren: _keylessNodes,
              onAdd: widget.onAddChild,
              onAccept: (other) {
                if (other.i == -1 && other.j == -1) {
                  return;
                }

                setState(() => _layout[other.i][other.j] = null);
                widget.onUpdate.call(_layout);
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: widget.padding.bottom),
            child: Card(
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() => _layout.removeLast());
                        widget.onUpdate.call(_layout);
                      },
                      child: Padding(
                        child: const Icon(Icons.remove),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0,
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 0),
                    InkWell(
                      onTap: () {
                        setState(() => _layout.add([null]));
                        widget.onUpdate.call(_layout);
                      },
                      child: Padding(
                        child: const Icon(Icons.add),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: widget.onTap.call,
        child: ListView(
          padding: widget.padding,
          shrinkWrap: true,
          children: children,
        ),
      );
    }
  }

  void _onAdd(int rowIndex, [end = true]) {
    if (_layout[rowIndex].length > maxItems - 1) {
      return;
    }
    if (end) {
      _layout[rowIndex].add(null);
    } else {
      _layout[rowIndex].insert(0, null);
    }

    setState(() {});
    widget.onUpdate.call(_layout);
  }

  void _onRemove(int rowIndex, [end = true]) {
    if (_layout[rowIndex].length <= 1) {
      _layout.removeAt(rowIndex);
      setState(() {});
      widget.onUpdate.call(_layout);
    } else {
      if (end) {
        _layout[rowIndex].removeLast();
      } else {
        _layout[rowIndex].removeAt(0);
      }

      setState(() {});
      widget.onUpdate.call(_layout);
    }
  }

  void _getNodes() {
    assert(widget.children.every((child) => child.key != null));

    final dragNodes = _getDragNodes(_layout);

    _layout = widget.layout;
    _nodes = dragNodes.nodes;
    _keylessNodes = dragNodes.keylessNodes;
  }

  _DragNodes _getDragNodes(List<List<String?>> layout) {
    final _nodes = <List<DragNode>>[];
    final _childrenCopy = [...widget.children];

    for (var i = 0; i < layout.length; i++) {
      _nodes.add([]);
      for (var j = 0; j < layout[i].length; j++) {
        // Placeholder
        if (layout[i][j] == null) {
          _nodes[i].insert(
            j,
            DragNode(
              key: null,
              child: null,
              i: i,
              j: j,
              onAccept: _swap,
              isEditable: widget.isEditable,
            ),
          );
          continue;
        }

        final childIndex = _childrenCopy.indexWhere((child) {
          return (child.key as ValueKey).value == layout[i][j];
        });

        if (childIndex != -1) {
          final key = ValueKey(layout[i][j]);
          _nodes[i].insert(
            j,
            DragNode(
              key: key,
              child: _childrenCopy[childIndex],
              i: i,
              j: j,
              onAccept: _swap,
              isEditable: widget.isEditable,
            ),
          );
          _childrenCopy.removeAt(childIndex);
        } else {
          if (widget.ignoreMissingChild) {
            continue;
          } else {
            debugPrint('No matching course found for key "${layout[i][j]}"');
          }
        }
      }
    }

    final _keylessChildren = _childrenCopy.map<DragNode>((child) {
      return DragNode(
        child: child,
        i: -1,
        j: -1,
        key: ValueKey(child.key),
        onAccept: _swap,
        isEditable: widget.isEditable,
      );
    }).toList();

    return _DragNodes(_keylessChildren, _nodes);
  }

  void onAccept(DragNode current, DragNode other) {
    if (other.key != null) {
      setState(() {
        _layout[current.i][current.j] = other.key.toString();
      });
      widget.onUpdate.call(_layout);
    } else {
      _swap(current, other);
    }
  }

  void _swap(DragNode node, DragNode other) {
    if (node.i == -1 && node.j == -1) {
      return;
    }

    // TODO: possibly a smarter way to add these two if cases together
    if (node.i == -1 || node.j == -1) {
      // I have no clue why this is this picky
      final key = ((node.key as ValueKey<Key>).value as ValueKey<String>);

      setState(() {
        _layout[other.i][other.j] = key.value;
      });
    } else if (other.i == -1 || other.j == -1) {
      final key = ((other.key as ValueKey<Key>).value as ValueKey<String>);

      setState(() {
        _layout[node.i][node.j] = key.value;
      });
    } else {
      final temp = _layout[node.i][node.j];

      setState(() {
        _layout[node.i][node.j] = _layout[other.i][other.j];
        _layout[other.i][other.j] = temp;
      });
    }

    widget.onUpdate.call(_layout);
  }
}

class _DragNodes {
  const _DragNodes(this.keylessNodes, this.nodes);

  final List<Widget> keylessNodes;
  final List<List<Widget>> nodes;
}
