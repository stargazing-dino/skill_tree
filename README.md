# skill_tree

<p align="center">
  <img src="https://github.com/Nolence/skill_tree/blob/main/screenshots/border_lands_skill_tree.png?raw=true" width="40%"/>
  &nbsp; &nbsp; &nbsp; &nbsp;
  <img src="https://github.com/Nolence/skill_tree/blob/main/screenshots/wow_style_skill_tree.png?raw=true" width="40%"/>
</p>

A package to build skill trees. This lib differs from `graphview` as it only tries to provide users an interface to make a skill tree rather than a general purpose viewer.

## Simple usage

```dart
class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkillTree<void, void, String>.layered(
      delegate: LayeredTreeDelegate(
        mainAxisSpacing: 32.0,
        crossAxisSpacing: 48.0,
      ),
      graph: LayeredGraph(
        layout: [
          ['0', '1', '2', null],
          ['3', '4', '5', null],
          ['6', '7', '8', null],
          [null, '9', '10', null],
          ['11', '12', null, '13'],
          [null, null, '14', null],
          [null, '15', '16', null],
        ],
        edges: [
          Edge(from: '7', to: '9', data: null),
          Edge(from: '10', to: '14', data: null),
          Edge(from: '12', to: '15', data: null),
        ],
        nodes: [
          Node(id: '0', data: null),
          Node(id: '1', data: null),
          Node(id: '2', data: null),
          Node(id: '3', data: null),
          Node(id: '4', data: null),
          Node(id: '5', data: null),
          Node(id: '6', data: null),
          Node(id: '7', data: null),
          Node(id: '8', data: null),
          Node(id: '9', data: null),
          Node(id: '10', data: null),
          Node(id: '11', data: null),
          Node(id: '12', data: null),
          Node(id: '13', data: null),
          Node(id: '14', data: null),
          Node(id: '15', data: null),
          Node(id: '16', data: null),
        ],
      ),
    );
  }
}
```

This will create a top-down skill tree. `Edge` and `Node` are not widgets but rather plain, sealed classes. The data field on both can be used to store information specific to your application. No assumptions are made about unlockability, paths, or limits in order to be fully customizable.

Users get full access to the data they define in both `nodeBuilder` and `edgeBuilder`. The only job of this builder is to return an concrete Widget instance of `SkillNode` or `SkillEdge`. If you prefer to define them directly in the graph, you're free to do so. Note you will have to provide more fields in this way.

```dart
LayeredGraph(
  // ...
  edges: [
    SkillEdge(from: '7', to: '9', data: null, /*...*/),
  ],
  nodes: [
    SkillNode(id: '7', data: null, /*...*/),
    Node(id: '9', data: null), // You are free to mix types
    // ...
  ],
  // ...
),
```

# Type strictness

One of the reasons we've passed a data of `null` is that by default, the graph is strictly typed. Above, the type has been `Graph<EdgeType, NodeType, IdType>`. The `EdgeType` corresponds to the data on the edge. We haven't concerned ourselves with it so it has been implicitly typed to `void`. The same goes for the `NodeType`, which incidentally is the data on the node. The `IdType` refers to the type used to match up the ends of edges to nodes. Above, the types have been typed to `String`. Trying to use a `int`, for example, in either the edge or the node will be an error.

# Full Featured Skill Tree

To see a full feature skill graph similar to the one in World of Warcraft or Borderlands visit the example. Cursory information on individual tasks is given below:

## Unlockability

To define an unlockable node, we'll need to store information on the node. Namely, it's current level and its max level:

```dart
class MyNodeData {
  const NodeInfo({
    required this.value,
    required this.maxValue,
  });

  bool get isMaxedOut => value == maxValue;

  final int value;

  final int maxValue;
}
```

With this information, inside the `nodeBuilder`, we can decide whether that node is locked or unlocked.

```dart
nodeBuilder: (node, graph) {
  final canBeUnlocked = node.isMaxedOut;

  return SkillNode.fromNode(
    node: node,
    child: Item(
      canBeUnlocked: canBeUnlocked,
      node: node,
    ),
  );
},
```

Of course, this doesn't cover the fact that the node connected to this node is yet unlocked -- in which case we'd need to first check that node if it's unlocked and so on. For that, we would need to query all edges which have a `to` of our current node and retrieve the `from` -- doing this consecutively if that new node then has edges that meet the same criteria.

For this, there are helper functions defined on the `graph`.

## Reachable nodes

Reachability is defined by the graph type. Layered graphs have a concept of a `pointsPerLayer` system. That is, the user must get a minimum of that amount to move onto the next layer of the tree. Reachability logic is handled by the following code. This is just one use case however and you're free to make logic fit your application:

```dart
nodeBuilder: (node, graph) {
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

  return SkillNode.fromNode(
    node: node,
    child: Item(
      isReachable: isReachable,
      node: node,
    ),
  );
},
```

# Extra data

You can store anything in the node or edge data. the MP it costs to fire a skill for example.

```dart
nodeBuilder: (node) {
  return SkillNode.fromNode(
    node: node,
    child: Column(
      children: [
        Text(node.name),
        Text('MP cost: ${node.data.cost}'),
      ],
    ),
  );
},
```

# Edge drawing and routing

## EdgePathPainter

If no painter is provided, a default painter will be used that is just a simple `canvas.drawPath`. Currently, the signature for a edge painter is:

```dart
typedef EdgePathPainter = void Function({
  required Path path,
  required Canvas canvas,
});
```

where the path provided is the one constructed from the `EdgePathBuilder`.

## EdgePathBuilder

Custom edges can even be drawn by providing an `edgePathBuilder` to a `SkillEdge`. Drawing is a complex area of interest but you're free to use the default edgePainters and or provide your own. 

The current signature looks like this:

```dart
typedef EdgePathBuilder = Path Function({
  required Offset toNodeCenter,
  required Offset fromNodeCenter,
  required List<Rect> allNodeRects,
  required List<Offset> controlPointCenters,
});
```

It returns a path which is also used in the sizing of the edge. This is important as otherwise, complex beziers would overflow their bounding box.

# Contributing

Issues, PRs and discussions welcome

## TODO
- [ ] Radial tree layout
- [ ] Positioned layout
- [ ] Optional drag and drop behavior widgets
- [ ] toggleable GUI to add and edit nodes (onAddChild, onUpdate)
- [ ] animations
- [ ] unnattached nodes
- [ ] SkillTree.fromJson