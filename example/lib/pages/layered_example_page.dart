import 'dart:math';

import 'package:example/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skill_tree/skill_tree.dart';

class LayeredExamplePage extends StatefulWidget {
  const LayeredExamplePage({Key? key}) : super(key: key);

  @override
  State<LayeredExamplePage> createState() => _LayeredExamplePageState();
}

class _LayeredExamplePageState extends State<LayeredExamplePage> {
  final seed = Random().nextInt(5000);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Image.asset(
          'assets/ruined_city.png',
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: theme.primaryColor.withAlpha(20),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: const Text(
              'Skill Tree',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkillTree<void, NodeInfo, String>(
              // I feel like layout should somehow be apart of graph...
              delegate: LayeredTreeDelegate(
                mainAxisSpacing: 28.0,
                crossAxisSpacing: 12.0,
                layout: [
                  ['0', '1', '2', null],
                  ['3', '4', '5', null],
                  ['6', '7', '8', null],
                  [null, '9', '10', null],
                  ['11', '12', null, '13'],
                  [null, null, '14', null],
                  [null, '15', '16', null],
                ],
              ),
              nodeBuilder: (node, graph) {
                final edges = graph.edgesForNode(node);
                final fromNodes = edges
                    .map((edge) => graph.getNodeFromIdType(edge.from))
                    .toList();
                final isUnlockable = fromNodes.every((node) {
                  return node.data.isUnlocked;
                });

                final photoId = int.parse(node.id) + 1;

                return SkillNode.fromNode(
                  node: node,
                  child: Item(
                    isUnlockable: isUnlockable,
                    nodeInfo: node.data,
                    photoNumber: photoId,
                    seed: seed,
                  ),
                );
              },
              edges: [
                // Edge(from: '9', to: '14', data: null),
                // Edge(from: '6', to: '11', data: null),
                // Edge(from: '6', to: '13', data: null),
                // Edge(from: '7', to: '9', data: null),
                SkillEdge<void, NodeInfo, String>(
                  from: '10',
                  to: '13',
                  data: null,
                  id: '10-13',
                  toAlignment: Alignment.centerLeft,
                  fromAlignment: Alignment.topLeft,
                  name: '',
                  fromChild: Container(
                    height: 20.0,
                    width: 20.0,
                    color: Colors.pink,
                    child: const Placeholder(),
                  ),
                  edgePainter: SkillTree.defaultEdgePainter,
                  toChild: Container(
                    height: 20.0,
                    width: 20.0,
                    color: Colors.blue,
                    child: const Placeholder(),
                  ),
                  // toAlignment: Alignment.topCenter,
                  // fromAlignment: Alignment.bottomCenter,
                ),
                // Edge(from: '10', to: '14', data: null),
                // Edge(from: '12', to: '15', data: null),
                // Edge(from: '12', to: '13', data: null),
              ],
              nodes: const [
                Node(id: '0', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '1', data: NodeInfo(value: 5, maxValue: 5)),
                Node(id: '2', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '3', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '4', data: NodeInfo(value: 5, maxValue: 5)),
                Node(id: '5', data: NodeInfo(value: 2, maxValue: 2)),
                Node(id: '6', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '7', data: NodeInfo(value: 2, maxValue: 5)),
                Node(id: '8', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '9', data: NodeInfo(value: 0, maxValue: 1)),
                Node(id: '10', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '11', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '12', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '13', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '14', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '15', data: NodeInfo(value: 0, maxValue: 5)),
                Node(id: '16', data: NodeInfo(value: 0, maxValue: 5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// TODO: Although I don't want to force this model on users, I think it's good
/// default to provide. Probably as an abstract class they can implement or a
/// mixin.
class NodeInfo {
  const NodeInfo({
    required this.value,
    required this.maxValue,
  })  : assert(value >= 0),
        assert(maxValue >= 0),
        assert(value <= maxValue);

  bool get isUnlocked => value == maxValue;

  final int value;

  final int maxValue;
}
