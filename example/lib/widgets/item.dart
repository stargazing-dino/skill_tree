import 'package:example/pages/layered_example_page.dart';
import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.photoNumber,
    required this.seed,
    required this.nodeInfo,
    required this.isUnlockable,
  }) : super(key: key);

  final int photoNumber;

  final int seed;

  final NodeInfo nodeInfo;

  final bool isUnlockable;

  @override
  Widget build(BuildContext context) {
    const totalNumberOfPhotos = 130;
    final _photoNumber = (photoNumber * seed) % (totalNumberOfPhotos - 1) + 1;

    final child = Stack(
      fit: StackFit.passthrough,
      children: [
        Container(
          margin: const EdgeInsets.all(4.0),
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
              colorBlendMode: BlendMode.saturation,
              color: !nodeInfo.isUnlocked ? Colors.grey.withOpacity(1.0) : null,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.black,
              border: Border.all(
                color: Colors.yellow.shade600,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
            child: Text(
              '${nodeInfo.value}/${nodeInfo.maxValue}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
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
