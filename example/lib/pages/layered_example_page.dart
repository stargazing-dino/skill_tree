import 'dart:math';

import 'package:example/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart' as clip;
import 'package:skill_tree/skill_tree.dart';

class LayeredExamplePage extends StatefulWidget {
  const LayeredExamplePage({Key? key}) : super(key: key);

  @override
  State<LayeredExamplePage> createState() => _LayeredExamplePageState();
}

class _LayeredExamplePageState extends State<LayeredExamplePage> {
  final seed = Random().nextInt(5000);
  int avaialablePoints = 20;

  var graph = const LayeredGraph<void, NodeInfo, String>(
    layout: [
      ['0', '1', '2', null],
      ['3', '4', '5', null],
      ['6', '7', '8', null],
      [null, '9', '10', null],
      ['11', '12', null, '13'],
      [null, null, '14', null],
      [null, '15', '16', null],
    ],
    nodes: [
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
    edges: [
      Edge(from: '7', to: '9', data: null),
      Edge(from: '10', to: '14', data: null),
      Edge(from: '12', to: '15', data: null),
    ],
  );

  @override
  Widget build(BuildContext context) {
    const pointsPerLayer = 5;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Image.asset('assets/ruined_city.png', fit: BoxFit.cover),
        Scaffold(
          floatingActionButton: SkillPoints(avaialablePoints),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: const Text(
              'Skill Tree',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkillTree<void, NodeInfo, String>.layered(
              delegate: LayeredTreeDelegate(
                mainAxisSpacing: 18.0,
                crossAxisSpacing: 12.0,
              ),
              nodeBuilder: (node, _) {
                assert(avaialablePoints >= 0);
                final hasAvailablePoints = avaialablePoints != 0;

                // Graph specific. The edges leading to this node must all be
                // maxed out.
                final fromNodes = graph.allFromNodes(node);
                final previousNodesAreMaxed = fromNodes.every((_node) {
                  return _node.data.isMaxedOut;
                });

                // Layered graph logic. Layers each have a required amount of
                // points to be considered completed.
                final ancestorLayers = graph.ancestorLayersForNode(node);
                final layerOfNode = graph.layerForNode(node);
                final pointsToUnlock = pointsPerLayer * layerOfNode;
                final pointsInAncestorLayers = ancestorLayers.fold<int>(
                  0,
                  (acc, layer) {
                    acc += layer.fold<int>(0, (acc, id) {
                      if (id != null) {
                        final node = graph.getNodeFromIdType(id);
                        acc += node.data.value;
                      }

                      return acc;
                    });
                    return acc;
                  },
                );

                /// The user is able to reach this node if they have the
                /// necessary points.
                final isReachable = previousNodesAreMaxed &&
                    pointsToUnlock <= pointsInAncestorLayers;

                /// The user is able to unlock this node because it is
                /// reachable, they have points and the node is not maxed out.
                final canBeUnlocked =
                    isReachable && hasAvailablePoints && !node.data.isMaxedOut;

                final photoId = int.parse(node.id) + 1;

                return SkillNode.fromNode(
                  node: node,
                  child: Item(
                    onSwap: (_node) {
                      setState(() {
                        graph = graph.swap(_node.id, node.id);
                      });
                    },
                    onTap: canBeUnlocked
                        ? () {
                            setState(() {
                              graph = graph.updateNode(
                                node,
                                (node) => node.copyWith(
                                  data: node.data.copyWith(
                                    value: node.data.value + 1,
                                  ),
                                ),
                              );

                              avaialablePoints--;
                            });
                          }
                        : null,
                    canUnlock: canBeUnlocked,
                    isReachable: isReachable,
                    node: node,
                    photoNumber: photoId,
                    seed: seed,
                  ),
                );
              },
              edgeBuilder: (edge, graph) {
                return SkillEdge(
                  edgePathBuilder: defaultEdgePathBuilder,
                  edgePathPainter: defaultEdgePathPainter,
                  fromChild: const SizedBox.shrink(),
                  toChild: ClipPath(
                    clipper: clip.TriangleClipper(),
                    child: Container(
                      color: Colors.grey,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  name: edge.name,
                  data: null,
                  id: edge.id,
                  from: edge.from,
                  to: edge.to,
                );
              },
              graph: graph,
            ),
          ),
        ),
      ],
    );
  }
}

class SkillPoints extends StatelessWidget {
  const SkillPoints(this.avaialablePoints, {Key? key}) : super(key: key);

  final int avaialablePoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.green[900],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Text(
          avaialablePoints.toString(),
          style: theme.textTheme.headline6,
        ),
      ),
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

  bool get isMaxedOut => value == maxValue;

  final int value;

  final int maxValue;

  NodeInfo copyWith({
    int? value,
    int? maxValue,
  }) {
    return NodeInfo(
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NodeInfo &&
        other.value == value &&
        other.maxValue == maxValue;
  }

  @override
  int get hashCode => value.hashCode ^ maxValue.hashCode;

  @override
  String toString() => 'NodeInfo(value: $value, maxValue: $maxValue)';
}
