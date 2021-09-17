import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.photoNumber,
    required this.seed,
  }) : super(key: key);

  final int photoNumber;

  final int seed;

  @override
  Widget build(BuildContext context) {
    const totalNumberOfPhotos = 130;
    final _photoNumber = (photoNumber * seed) % (totalNumberOfPhotos - 1) + 1;

    final child = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey,
          width: 2.4,
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(1.0, 2.0),
            blurRadius: 4.0,
            color: Colors.grey.shade600,
          )
        ],
      ),
      // clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.asset(
          'assets/icons_512x512/$_photoNumber.png',
          fit: BoxFit.cover,
          height: 64.0,
          width: 64.0,
        ),
      ),
    );

    return Draggable(
      feedback: Opacity(
        opacity: 0.5,
        child: child,
      ),
      child: child,
    );
  }
}
