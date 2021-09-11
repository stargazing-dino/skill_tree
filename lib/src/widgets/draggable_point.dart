import 'package:flutter/material.dart';

// TODO: Allow for builder to be passed in instead of this
class DraggablePoint extends StatelessWidget {
  const DraggablePoint({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: const SizedBox(),
      child: Container(
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.white,
        ),
      ),
    );
  }
}
