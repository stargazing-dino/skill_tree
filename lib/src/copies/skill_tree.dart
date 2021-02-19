// import 'package:flutter/material.dart';
// import 'package:skill_tree/src/quantity_button.dart';
// import 'package:skill_tree/src/tree_header.dart';

// import '../drag_node.dart';

// class SkillTree<T> extends StatefulWidget {
//   final List<Widget> children;

//   final List<List<T?>> layout;

//   final VoidCallback onTap;

//   final VoidCallback onAddChild;

//   final EdgeInsets padding;

//   final EdgeInsets tilePadding;

//   final ValueChanged<List<List<T?>>> onUpdate;

//   final bool isEditable;

//   final bool ignoreMissingChildren;

//   final double headerHeight;

//   final double editPadding;

//   final int maxItems;

//   final double cardElevation;

//   const SkillTree({
//     required this.children,
//     required this.onTap,
//     required this.onAddChild,
//     required this.onUpdate,
//     required this.layout,
//     this.padding = const EdgeInsets.all(12.0),
//     this.tilePadding = const EdgeInsets.symmetric(vertical: 6.0),
//     this.isEditable = true,
//     this.ignoreMissingChildren = false,
//     this.headerHeight = 80.0,
//     this.editPadding = 26.0,
//     this.maxItems = 4,
//     this.cardElevation = 4.0,
//   });

//   @override
//   _SkillTreeState<T> createState() => _SkillTreeState<T>();
// }

// class _SkillTreeState<T> extends State<SkillTree<T>> {
//   late List<List<T?>> _layout;
//   late List<List<Widget>> _nodes;
//   late List<Widget> _keylessNodes;

//   @override
//   void initState() {
//     _layout = widget.layout;

//     final dragNodes = _getDragNodes(_layout);

//     _nodes = dragNodes.nodes;
//     _keylessNodes = dragNodes.keylessNodes;
//     super.initState();
//   }

//   @override
//   void didUpdateWidget(SkillTree<T> oldWidget) {
//     if (widget.layout != oldWidget.layout ||
//         widget.children != oldWidget.children) {
//       _getNodes();
//       setState(() {});
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final children = <Widget>[];

//     for (var i = 0; i < _nodes.length; i++) {
//       final row = _nodes[i];

//       children.add(
//         Padding(
//           key: ValueKey<String>('$i,${row.length}'),
//           padding: widget.tilePadding,
//           child: IntrinsicHeight(
//             child: Stack(
//               children: <Widget>[
//                 SizedBox.expand(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: row.toList(),
//                   ),
//                 ),
//                 if (widget.isEditable) ...[
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: QuantityButton(
//                       axis: Axis.vertical,
//                       onAdd: () => _onAdd(row: i, end: false),
//                       onRemove: () => _onRemove(row: i, end: false),
//                       elevation: widget.cardElevation,
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: QuantityButton(
//                       axis: Axis.vertical,
//                       onAdd: () => _onAdd(row: i, end: true),
//                       onRemove: () => _onRemove(row: i, end: true),
//                       elevation: widget.cardElevation,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     if (widget.isEditable) {
//       return Stack(
//         fit: StackFit.passthrough,
//         children: <Widget>[
//           GestureDetector(
//             // TODO:
//             // Is this onTap necessary?
//             onTap: widget.onTap.call,
//             // TODO: Await https://github.com/flutter/flutter/issues/41334
//             child: ListView(
//               cacheExtent: 600.0,
//               shrinkWrap: true,
//               children: children,
//               padding: widget.padding.copyWith(
//                 top: widget.headerHeight +
//                     widget.padding.top +
//                     widget.tilePadding.top,
//                 bottom: widget.padding.bottom + 32.0,
//               ),
//             ),
//           ),
//           Container(
//             padding: widget.padding,
//             alignment: Alignment.topCenter,
//             child: TreeHeader(
//               elevation: widget.cardElevation,
//               height: widget.headerHeight,
//               keylessChildren: _keylessNodes,
//               onAdd: widget.onAddChild,
//               onAccept: (other) {
//                 if (other.i == -1 && other.j == -1) {
//                   return;
//                 }

//                 setState(() => _layout[other.i][other.j] = null);
//                 widget.onUpdate.call(_layout);
//               },
//             ),
//           ),
//           Container(
//             alignment: Alignment.bottomCenter,
//             margin: EdgeInsets.only(bottom: widget.padding.bottom),
//             child: QuantityButton(
//               axis: Axis.horizontal,
//               elevation: widget.cardElevation,
//               onAdd: () {
//                 setState(() => _layout.add([null]));
//                 widget.onUpdate.call(_layout);
//               },
//               onRemove: () {
//                 setState(() => _layout.removeLast());
//                 widget.onUpdate.call(_layout);
//               },
//             ),
//           ),
//         ],
//       );
//     } else {
//       return GestureDetector(
//         onTap: widget.onTap.call,
//         child: ListView(
//           padding: widget.padding,
//           shrinkWrap: true,
//           children: children,
//         ),
//       );
//     }
//   }

//   void _onAdd({required int row, required bool end}) {
//     if (_layout[row].length > widget.maxItems - 1) {
//       return;
//     }
//     if (end) {
//       _layout[row].add(null);
//     } else {
//       _layout[row].insert(0, null);
//     }

//     setState(() {});
//     widget.onUpdate.call(_layout);
//   }

//   void _onRemove({required int row, required bool end}) {
//     if (_layout[row].length <= 1) {
//       _layout.removeAt(row);
//       setState(() {});
//       widget.onUpdate.call(_layout);
//     } else {
//       if (end) {
//         _layout[row].removeLast();
//       } else {
//         _layout[row].removeAt(0);
//       }

//       setState(() {});
//       widget.onUpdate.call(_layout);
//     }
//   }

//   void _getNodes() {
//     assert(widget.children.every((child) => child.key != null));

//     _layout = widget.layout;

//     final dragNodes = _getDragNodes(_layout);

//     _nodes = dragNodes.nodes;
//     _keylessNodes = dragNodes.keylessNodes;
//   }

//   _DragNodes _getDragNodes(List<List<T?>> layout) {
//     final _nodes = <List<DragNode>>[];
//     final _childrenCopy = [...widget.children];

//     for (var i = 0; i < layout.length; i++) {
//       _nodes.add([]);

//       for (var j = 0; j < layout[i].length; j++) {
//         // Placeholder
//         if (layout[i][j] == null) {
//           _nodes[i].insert(
//             j,
//             DragNode(
//               // I think even placeholder nodes need keys if we're going to do
//               // animations
//               key: null,
//               child: null,
//               i: i,
//               j: j,
//               onAccept: _swap,
//               isEditable: widget.isEditable,
//             ),
//           );
//           continue;
//         }

//         final childIndex = _childrenCopy.indexWhere((child) {
//           return (child.key as ValueKey<T?>).value == layout[i][j];
//         });

//         if (childIndex != -1) {
//           final key = ValueKey(layout[i][j]);

//           _nodes[i].insert(
//             j,
//             DragNode(
//               key: key,
//               child: _childrenCopy[childIndex],
//               i: i,
//               j: j,
//               onAccept: _swap,
//               isEditable: widget.isEditable,
//             ),
//           );
//           _childrenCopy.removeAt(childIndex);
//         } else {
//           if (widget.ignoreMissingChildren) {
//             continue;
//           } else {
//             throw 'No matching child found for key "${layout[i][j]}';
//           }
//         }
//       }
//     }

//     final _keylessChildren = _childrenCopy.map<DragNode>((child) {
//       return DragNode(
//         child: child,
//         i: -1,
//         j: -1,
//         key: child.key,
//         onAccept: _swap,
//         isEditable: widget.isEditable,
//       );
//     }).toList();

//     return _DragNodes(_keylessChildren, _nodes);
//   }

//   void onAccept(DragNode current, DragNode other) {
//     final otherKey = (other.key as ValueKey<T?>).value;

//     if (otherKey != null) {
//       setState(() {
//         _layout[current.i][current.j] = otherKey;
//       });
//       widget.onUpdate.call(_layout);
//     } else {
//       _swap(current, other);
//     }
//   }

//   void _swap(DragNode node, DragNode other) {
//     if (node.i == -1 && node.j == -1) {
//       return;
//     }

//     if (node.i == -1 || node.j == -1) {
//       final key = (node.key as ValueKey<T?>).value;

//       if (key == null) {
//         throw 'Node $node has no ValueKey';
//       }

//       setState(() {
//         _layout[other.i][other.j] = key;
//       });
//     } else if (other.i == -1 || other.j == -1) {
//       final key = (other.key as ValueKey<T?>).value;

//       if (key == null) {
//         throw 'Other node $node has no ValueKey';
//       }

//       setState(() {
//         _layout[node.i][node.j] = key;
//       });
//     } else {
//       final temp = _layout[node.i][node.j];

//       setState(() {
//         _layout[node.i][node.j] = _layout[other.i][other.j];
//         _layout[other.i][other.j] = temp;
//       });
//     }

//     widget.onUpdate.call(_layout);
//   }
// }

// class _DragNodes {
//   const _DragNodes(this.keylessNodes, this.nodes);

//   final List<Widget> keylessNodes;
//   final List<List<Widget>> nodes;
// }

// // child: ReorderableListView(
// //   padding: widget.padding,
// //   header: TreeHeader(
// //     keylessChildren: _keylessNodes,
// //     onAdd: widget.onAddChild,
// //     onAccept: (other) {
// //       setState(() => _layout[other.i][other.j] = null);
// //       widget.onUpdate?.call(_layout);
// //     },
// //   ),
// //   onReorder: (int oldIndex, int newIndex) {
// //     if (newIndex > oldIndex) newIndex -= 1;

// //     final item = _layout.removeAt(oldIndex);
// //     setState(() => _layout.insert(newIndex, item));
// //     widget.onUpdate?.call(_layout);
// //   },
// //   children: children,
// // ),
