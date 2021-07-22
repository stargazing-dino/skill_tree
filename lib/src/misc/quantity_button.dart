// import 'package:flutter/material.dart';

// // TODO: This should all be editable to the user from padding to icon
// class QuantityButton extends StatelessWidget {
//   final VoidCallback onAdd;

//   final VoidCallback onRemove;

//   final double elevation;

//   final Axis axis;

//   const QuantityButton({
//     Key? key,
//     required this.onAdd,
//     required this.onRemove,
//     required this.elevation,
//     required this.axis,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final verticalPadding = axis == Axis.horizontal ? 2.0 : 8.0;
//     final horizontalPadding = axis == Axis.horizontal ? 8.0 : 2.0;

//     final children = [
//       InkWell(
//         onTap: onRemove,
//         child: Padding(
//           child: const Icon(Icons.remove),
//           padding: EdgeInsets.symmetric(
//             vertical: verticalPadding,
//             horizontal: horizontalPadding,
//           ),
//         ),
//       ),
//       if (axis == Axis.horizontal)
//         const VerticalDivider(width: 0)
//       else
//         const Divider(height: 0),
//       InkWell(
//         onTap: onAdd,
//         child: Padding(
//           child: const Icon(Icons.add),
//           padding: EdgeInsets.symmetric(
//             vertical: verticalPadding,
//             horizontal: horizontalPadding,
//           ),
//         ),
//       ),
//     ];

//     return Card(
//       elevation: elevation,
//       clipBehavior: Clip.hardEdge,
//       child: axis == Axis.horizontal
//           ? IntrinsicHeight(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: children,
//               ),
//             )
//           : IntrinsicWidth(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: children,
//               ),
//             ),
//     );
//   }
// }
