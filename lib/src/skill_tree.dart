import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/models/empty_skill_node.dart';
import 'package:skill_tree/src/skill_row.dart';
import 'package:skill_tree/src/tree_header.dart';

import 'drag_node.dart';
import 'quantity_button.dart';

class SkillTree<T, R extends Object> extends StatefulWidget {
  final List<SkillNode<T, R>>? nodes;

  final List<Map<String, dynamic>>? layout;

  final List<SkillNode<T, R>> unnattachedNodes;

  final Widget Function(BuildContext context, R data) nodeBuilder;

  final VoidCallback onTap;

  final VoidCallback onAddChild;

  final EdgeInsets padding;

  final EdgeInsets tilePadding;

  final WidgetBuilder placeholderBuilder;

  final ValueChanged<List<Map<String, dynamic>>> onUpdate;

  final bool isEditable;

  final bool ignoreMissingChildren;

  final double headerHeight;

  final double editPadding;

  final int maxItems;

  final double cardElevation;

  static Widget defaultPlaceHolderBuilder(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      elevation: 10.0,
      child: CircleAvatar(
        child: Center(child: Icon(Icons.add_box_outlined)),
      ),
    );
  }

  const SkillTree({
    this.nodes,
    this.layout,
    this.unnattachedNodes = const [],
    required this.nodeBuilder,
    required this.onTap,
    required this.onAddChild,
    required this.onUpdate,
    this.placeholderBuilder = defaultPlaceHolderBuilder,
    this.padding = const EdgeInsets.all(12.0),
    this.tilePadding = const EdgeInsets.symmetric(vertical: 6.0),
    this.isEditable = true,
    this.ignoreMissingChildren = false,
    this.headerHeight = 80.0,
    this.editPadding = 26.0,
    this.maxItems = 4,
    this.cardElevation = 4.0,
  }) : assert((nodes != null && layout == null) ||
            layout != null && nodes == null);

  @override
  _SkillTreeState<T, R> createState() => _SkillTreeState<T, R>();
}

class _SkillTreeState<T, R extends Object> extends State<SkillTree<T, R>> {
  late List<SkillNode<T, R>> nodes;

  @override
  void initState() {
    nodes = widget.nodes ?? _parseLayout(widget.layout!);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SkillTree<T, R> oldWidget) {
    if (listEquals(oldWidget.nodes, widget.nodes) ||
        listEquals(oldWidget.layout, widget.layout)) {
      setState(() {
        nodes = widget.nodes ?? _parseLayout(widget.layout!);
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final children = _parseChildren(nodes);

    if (widget.isEditable) {
      return Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          GestureDetector(
            // TODO:
            // Is this onTap necessary?
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
          ),
          Container(
            padding: widget.padding,
            alignment: Alignment.topCenter,
            child: TreeHeader(
              elevation: widget.cardElevation,
              height: widget.headerHeight,
              unnattachedChildren: widget.unnattachedNodes.map((node) {
                return DragNode.unnatached(
                  key: node.key,
                  child: widget.nodeBuilder(context, node.data),
                  onAccept: _swap,
                  isEditable: widget.isEditable,
                  node: node as EmptySkillNode<T>,
                  placeholder: widget.placeholderBuilder(context),
                );
              }).toList(),
              onAdd: widget.onAddChild,
              onAccept: (other) {
                // if (other.column == -1 && other.depth == -1) {
                //   return;
                // }

                // setState(() => _layout[other.column][other.depth] = null);
                // widget.onUpdate.call(_layout);
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(bottom: widget.padding.bottom),
            child: QuantityButton(
              axis: Axis.horizontal,
              elevation: widget.cardElevation,
              onAdd: () {
                // setState(() => _layout.add([null]));
                // widget.onUpdate.call(_layout);
              },
              onRemove: () {
                // setState(() => _layout.removeLast());
                // widget.onUpdate.call(_layout);
              },
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

  /// Returns a list of children at depth N. N is not descibed as this is a
  /// generator. TODO: This can be made generic
  Iterable<List<SkillNode<T, R>>> _depthFirstSearch(
    List<SkillNode<T, R>> nodes,
  ) sync* {
    if (nodes.isNotEmpty) {
      yield nodes;

      final nextNodes = nodes.fold<List<SkillNode<T, R>>>(
        [],
        (previousValue, node) => [...previousValue, ...node.children],
      );

      if (nextNodes.isNotEmpty) {
        yield* _depthFirstSearch(nextNodes);
      }
    }
  }

  List<Widget> _parseChildren(List<SkillNode<T, R>> nodes) {
    final children = <Widget>[];

    var depth = 0;

    for (final nodeLayer in _depthFirstSearch(nodes)) {
      var index = 0;
      final rowChildren = <Widget>[];

      for (final node in nodeLayer) {
        if (node is EmptySkillNode<T>) {
          rowChildren.add(
            DragNode.empty(
              key: node.key,
              child: widget.placeholderBuilder(context),
              onAccept: _swap,
              isEditable: widget.isEditable,
              node: node as EmptySkillNode<T>,
              column: index,
              depth: depth,
              placeholder: widget.placeholderBuilder(context),
            ),
          );
        } else {
          rowChildren.add(
            DragNode(
              key: node.key,
              child: widget.nodeBuilder(context, node.data),
              onAccept: _swap,
              isEditable: widget.isEditable,
              depth: depth,
              column: index,
              node: node,
              placeholder: widget.placeholderBuilder(context),
            ),
          );
        }

        index++;
      }

      children.add(
        SkillRow(
          key: ValueKey('$index,$depth'),
          tilePadding: widget.tilePadding,
          index: index,
          depth: depth,
          cardElevation: widget.cardElevation,
          children: rowChildren,
          isEditable: widget.isEditable,
          onAdd: _onAdd,
          onRemove: _onRemove,
        ),
      );

      depth++;
    }

    return children;
  }

  List<SkillNode<T, R>> _parseLayout(List<Map<String, dynamic>> layout) {
    return layout.map((obj) => SkillNode<T, R>.fromMap(obj)).toList();
  }

  void _onAdd({required int index, required bool end}) {
    // if (_layout[row].length > widget.maxItems - 1) {
    //   return;
    // }
    // if (end) {
    //   _layout[row].add(null);
    // } else {
    //   _layout[row].insert(0, null);
    // }

    // setState(() {});
    // widget.onUpdate.call(_layout);
  }

  void _onRemove({required int index, required bool end}) {
    // if (_layout[row].length <= 1) {
    //   _layout.removeAt(row);
    //   setState(() {});
    //   widget.onUpdate.call(_layout);
    // } else {
    //   if (end) {
    //     _layout[row].removeLast();
    //   } else {
    //     _layout[row].removeAt(0);
    //   }

    //   setState(() {});
    //   widget.onUpdate.call(_layout);
    // }
  }

  // void _getNodes() {
  //   assert(widget.children.every((child) => child.key != null));

  //   _layout = widget.layout;

  //   final dragNodes = _getDragNodes(_layout);

  //   _nodes = dragNodes.nodes;
  //   _keylessNodes = dragNodes.keylessNodes;
  // }

  // _DragNodes _getDragNodes(List<List<T?>> layout) {
  //   final _nodes = <List<DragNode>>[];
  //   final _childrenCopy = [...widget.children];

  //   for (var i = 0; i < layout.length; i++) {
  //     _nodes.add([]);

  //     for (var j = 0; j < layout[i].length; j++) {
  //       // Placeholder
  //       if (layout[i][j] == null) {
  //         _nodes[i].insert(
  //           j,
  //           DragNode(
  //             // I think even placeholder nodes need keys if we're going to do
  //             // animations
  //             key: null,
  //             child: null,
  //             i: i,
  //             j: j,
  //             onAccept: _swap,
  //             isEditable: widget.isEditable,
  //           ),
  //         );
  //         continue;
  //       }

  //       final childIndex = _childrenCopy.indexWhere((child) {
  //         return (child.key as ValueKey<T?>).value == layout[i][j];
  //       });

  //       if (childIndex != -1) {
  //         final key = ValueKey(layout[i][j]);

  //         _nodes[i].insert(
  //           j,
  //           DragNode(
  //             key: key,
  //             child: _childrenCopy[childIndex],
  //             i: i,
  //             j: j,
  //             onAccept: _swap,
  //             isEditable: widget.isEditable,
  //           ),
  //         );
  //         _childrenCopy.removeAt(childIndex);
  //       } else {
  //         if (widget.ignoreMissingChildren) {
  //           continue;
  //         } else {
  //           throw 'No matching child found for key "${layout[i][j]}';
  //         }
  //       }
  //     }
  //   }

  //   final _keylessChildren = _childrenCopy.map<DragNode>((child) {
  //     return DragNode(
  //       child: child,
  //       i: -1,
  //       j: -1,
  //       key: child.key,
  //       onAccept: _swap,
  //       isEditable: widget.isEditable,
  //     );
  //   }).toList();

  //   return _DragNodes(_keylessChildren, _nodes);
  // }

  void onAccept(DragNode current, DragNode other) {
    // final otherKey = (other.key as ValueKey<T?>).value;

    // if (otherKey != null) {
    //   setState(() {
    //     _layout[current.i][current.j] = otherKey;
    //   });
    //   widget.onUpdate.call(_layout);
    // } else {
    //   _swap(current, other);
    // }
  }

  void _swap(DragNode node, DragNode other) {
    // if (node.i == -1 && node.j == -1) {
    //   return;
    // }

    // if (node.i == -1 || node.j == -1) {
    //   final key = (node.key as ValueKey<T?>).value;

    //   if (key == null) {
    //     throw 'Node $node has no ValueKey';
    //   }

    //   setState(() {
    //     _layout[other.i][other.j] = key;
    //   });
    // } else if (other.i == -1 || other.j == -1) {
    //   final key = (other.key as ValueKey<T?>).value;

    //   if (key == null) {
    //     throw 'Other node $node has no ValueKey';
    //   }

    //   setState(() {
    //     _layout[node.i][node.j] = key;
    //   });
    // } else {
    //   final temp = _layout[node.i][node.j];

    //   setState(() {
    //     _layout[node.i][node.j] = _layout[other.i][other.j];
    //     _layout[other.i][other.j] = temp;
    //   });
    // }

    // widget.onUpdate.call(_layout);
  }
}
// class _DragNodes {
//   const _DragNodes(this.keylessNodes, this.nodes);

//   final List<Widget> keylessNodes;
//   final List<List<Widget>> nodes;
// }

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
