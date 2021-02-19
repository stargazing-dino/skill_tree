// import 'package:flutter/material.dart';

// // TODO: This needs to be more customizable

// // I can make a superclass called DragNode and sub class named EmptyNode

// class DragNode extends StatefulWidget {
//   final Widget? child;

//   final int i;

//   final int j;

//   final void Function(DragNode current, DragNode other) onAccept;

//   final bool isEditable;

//   final WidgetBuilder? placeholderBuilder;

//   const DragNode({
//     Key? key,
//     required this.child,
//     required this.i,
//     required this.j,
//     required this.onAccept,
//     required this.isEditable,
//     this.placeholderBuilder,
//   }) : super(key: key);

//   @override
//   _DragNodeState createState() => _DragNodeState();
// }

// class _DragNodeState extends State<DragNode>
//     with SingleTickerProviderStateMixin {
//   var glowing = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final placeholder = widget.isEditable
//         ? Material(
//             shape: CircleBorder(),
//             elevation: glowing ? 10.0 : 0.0,
//             child: CircleAvatar(
//               backgroundColor: theme.accentColor,
//               child: Center(child: Icon(Icons.add_box_outlined)),
//             ),
//           )
//         : Container();

//     return DragTarget<DragNode>(
//       key: widget.key,
//       onAccept: (node) {
//         widget.onAccept(widget, node);
//         setState(() {
//           glowing = false;
//         });
//       },
//       onLeave: (_) {
//         setState(() {
//           glowing = false;
//         });
//       },
//       onWillAccept: (dragNode) {
//         setState(() {
//           glowing = true;
//         });

//         return true;
//       },
//       builder: (context, _, __) {
//         final childNode = widget.child;

//         if (childNode == null) {
//           // Simple drag target
//           return placeholder;
//         } else if (widget.i == -1 || widget.j == -1) {
//           // Keyless children
//           return Draggable<DragNode>(
//             dragAnchor: DragAnchor.child,
//             feedback: childNode,
//             childWhenDragging: Container(),
//             data: widget,
//             child: childNode,
//           );
//         } else {
//           if (widget.isEditable) {
//             return Draggable<DragNode>(
//               dragAnchor: DragAnchor.child,
//               feedback: childNode,
//               childWhenDragging: placeholder,
//               data: widget,
//               child: childNode,
//             );
//           }

//           return childNode;
//         }
//       },
//     );
//   }
// }
