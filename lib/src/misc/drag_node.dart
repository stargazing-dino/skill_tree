// import 'package:flutter/material.dart';
// import 'package:skill_tree/skill_tree.dart';
// import 'package:skill_tree/src/node_view.dart';

// // TODO: This needs to be more customizable

// // I can make a superclass called DragNode and sub class named EmptyNode

// typedef AcceptCallback = void Function(DragNode current, DragNode other);

// class DragNode<T> extends StatefulWidget {
//   final SkillNode<T> node;

//   final Widget child;

//   final int depth;

//   final int column;

//   final AcceptCallback onAccept;

//   final bool isEditable;

//   final Widget placeholder;

//   const DragNode({
//     Key? key,
//     required this.child,
//     required this.node,
//     required this.depth,
//     required this.column,
//     required this.onAccept,
//     required this.isEditable,
//     required this.placeholder,
//   }) : super(key: key);

//   factory DragNode.unnatached({
//     Key? key,
//     required Widget child,
//     required EmptySkillNode<T> node,
//     required AcceptCallback onAccept,
//     required bool isEditable,
//     required Widget placeholder,
//   }) {
//     return DragNode<T>(
//       child: child,
//       node: node,
//       depth: -1,
//       column: -1,
//       onAccept: onAccept,
//       isEditable: isEditable,
//       placeholder: placeholder,
//     );
//   }

//   factory DragNode.empty({
//     Key? key,
//     required Widget child,
//     required EmptySkillNode<T> node,
//     required AcceptCallback onAccept,
//     required int depth,
//     required int column,
//     required bool isEditable,
//     required Widget placeholder,
//   }) {
//     return DragNode<T>(
//       child: child,
//       node: node,
//       depth: depth,
//       column: column,
//       onAccept: onAccept,
//       isEditable: isEditable,
//       placeholder: placeholder,
//     );
//   }

//   @override
//   _DragNodeState createState() => _DragNodeState();
// }

// // TODO: This is stateful so I can change the drag node in some way when it's
// // being hovered over etc.
// class _DragNodeState extends State<DragNode> {
//   @override
//   Widget build(BuildContext context) {
//     return DragTarget<DragNode>(
//       key: ValueKey(widget.node.key),
//       onAccept: (node) {
//         widget.onAccept(widget, node);
//       },
//       builder: (context, _, __) {
//         if (widget.isEditable) {
//           return Draggable<DragNode>(
//             dragAnchorStrategy: (context, _, __) {
//               return Offset.zero;
//             },
//             feedback: widget.child,
//             childWhenDragging: widget.placeholder,
//             data: widget,
//             child: widget.child,
//           );
//         }

//         return widget.child;

//         // if (widget.depth == -1 || widget.column == -1) {
//         // Keyless children
//         // return Draggable<DragNode>(
//         //   dragAnchor: DragAnchor.child,
//         //   feedback: childNode,
//         //   childWhenDragging: Container(),
//         //   data: widget,
//         //   child: childNode,
//         // );
//         // } else {}
//       },
//     );
//   }
// }
