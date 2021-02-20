import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';
import 'package:skill_tree/src/models/base_node.dart';
import 'package:skill_tree/src/models/empty_skill_node.dart';
import 'package:skill_tree/src/skill_row.dart';
import 'package:skill_tree/src/tree_header.dart';
import 'package:skill_tree/src/tree_painter.dart';

import 'drag_node.dart';
import 'quantity_button.dart';

enum LineType { curved, angle, straight }

class SkillTree<T extends Object, R extends Object> extends StatefulWidget {
  final List<BaseNode<T>>? nodes;

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

class _SkillTreeState<T extends Object, R extends Object>
    extends State<SkillTree<T, R>> {
  late List<BaseNode<T>> nodes;

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
            child: Padding(
              child: Builder(
                builder: (context) {
                  return CustomPaint(
                    painter: TreePainter(context: context, nodes: nodes),
                    child: Column(children: children),
                  );
                },
              ),
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
                  key: node.globalKey,
                  child: widget.nodeBuilder(context, node.data),
                  onAccept: _swap,
                  isEditable: widget.isEditable,
                  node: node as EmptySkillNode<T>,
                  placeholder: widget.placeholderBuilder(context),
                );
              }).toList(),
              onAdd: widget.onAddChild,
              onAccept: (other) {
                // TODO:
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
                // TODO:
              },
              onRemove: () {
                // TODO:
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
  Iterable<List<BaseNode<T>>> _depthFirstSearch(
    List<BaseNode<T>> nodes,
  ) sync* {
    if (nodes.isNotEmpty) {
      yield nodes;

      final nextNodes = nodes.fold<List<BaseNode<T>>>(
        [],
        (previousValue, node) => [...previousValue, ...node.children],
      );

      if (nextNodes.isNotEmpty) {
        yield* _depthFirstSearch(nextNodes);
      }
    }
  }

  List<Widget> _parseChildren(List<BaseNode<T>> nodes) {
    final children = <Widget>[];

    var depth = 0;

    for (final nodeLayer in _depthFirstSearch(nodes)) {
      var index = 0;
      final rowChildren = <Widget>[];

      for (final node in nodeLayer) {
        if (node is EmptySkillNode<T>) {
          rowChildren.add(
            DragNode.empty(
              key: node.globalKey,
              child: widget.placeholderBuilder(context),
              onAccept: _swap,
              isEditable: widget.isEditable,
              node: node,
              column: index,
              depth: depth,
              placeholder: widget.placeholderBuilder(context),
            ),
          );
        } else if (node is SkillNode<T, R>) {
          rowChildren.add(
            DragNode(
              key: node.globalKey,
              child: widget.nodeBuilder(context, node.data),
              onAccept: _swap,
              isEditable: widget.isEditable,
              depth: depth,
              column: index,
              node: node,
              placeholder: widget.placeholderBuilder(context),
            ),
          );
        } else {
          throw UnsupportedError('Node $node is of unsupported type');
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

  List<BaseNode<T>> _parseLayout(List<Map<String, dynamic>> layout) {
    return layout.map((obj) => BaseNode<T>.fromMap(obj)).toList();
  }

  void _onAdd({required int index, required bool end}) {
    // TODO:
  }

  void _onRemove({required int index, required bool end}) {
    //  TODO:
  }

  void onAccept(DragNode current, DragNode other) {
    // TODO:
    // Check types of second node
    // if it's an empty slot, just place current there
    // If it's another node, swap
  }

  void _swap(DragNode node, DragNode other) {
    // TODO:
  }
}

// class SkillColumn extends StatelessWidget {
//   final List<BaseNode<T>> nodes;

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: TreePainter(context: context, nodes: nodes),
//       child: Column(children: children),
//     );
//   }
// }
