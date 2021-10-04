import 'package:example/pages/layered_example_page.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:skill_tree/skill_tree.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.photoNumber,
    required this.seed,
    required this.node,
    required this.canUnlock,
    required this.isReachable,
    required this.onTap,
    required this.onSwap,
  }) : super(key: key);

  final int photoNumber;

  final int seed;

  final Node<NodeInfo, String> node;

  final bool canUnlock;

  final bool isReachable;

  final VoidCallback? onTap;

  final void Function(Node<NodeInfo, String> node) onSwap;

  @override
  Widget build(BuildContext context) {
    const totalNumberOfPhotos = 130;
    final _photoNumber = (photoNumber * seed) % (totalNumberOfPhotos - 1) + 1;
    final nodeInfo = node.data;
    final unlockableColor =
        canUnlock ? Colors.greenAccent.shade700 : Colors.grey.shade600;
    final unlockableAccentColor =
        canUnlock ? Colors.green.shade200 : Colors.grey.shade400;

    return JustTheTooltip(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 8),
              const SizedBox(height: 8),
              Text('Node Id: ${node.id}'),
              const SizedBox(height: 4),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                'Donec dictum mi sapien, ac laoreet leo blandit non. Etiam '
                'luctus erat ac ornare mollis.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      preferredDirection: AxisDirection.up,
      child: InkWell(
        onTap: onTap,
        child: DraggableNode(
          onSwapNode: onSwap,
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
              if (isReachable)
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
      ),
    );
  }
}
