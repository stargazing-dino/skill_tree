import 'package:example/pages/layered_example_page.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.photoNumber,
    required this.seed,
    required this.node,
    required this.canUnlock,
    required this.isUnreachable,
    required this.onTap,
  }) : super(key: key);

  final int photoNumber;

  final int seed;

  final Node<NodeInfo, String> node;

  final bool canUnlock;

  final bool isUnreachable;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const totalNumberOfPhotos = 130;
    final _photoNumber = (photoNumber * seed) % (totalNumberOfPhotos - 1) + 1;
    final nodeInfo = node.data;
    final unlockableColor =
        canUnlock ? Colors.greenAccent.shade700 : Colors.grey.shade600;
    final unlockableAccentColor =
        canUnlock ? Colors.green.shade200 : Colors.grey.shade400;

    return InkWell(
      onTap: onTap,
      child: DraggableNode(
        onSwapNode: (Node<NodeInfo, String> node) {
          // TODO: Swap with graph
        },
        node: node,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                border: Border.all(
                  color: unlockableColor,
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(1.0, 2.0),
                    blurRadius: 4.0,
                    color: unlockableColor,
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
                  color: !nodeInfo.isMaxedOut
                      ? Colors.grey.withOpacity(1.0)
                      : null,
                ),
              ),
            ),
            if (!isUnreachable)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.black,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.3,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3.0,
                    vertical: 1.0,
                  ),
                  child: Text(
                    '${nodeInfo.value}/${nodeInfo.maxValue}',
                    style: TextStyle(
                      color: unlockableAccentColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
