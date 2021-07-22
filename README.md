# skill_tree

A package to build skill trees of any kind.

## Simple usage

```dart
class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkillTree<void, void>(
      layout: HeirarchicLayout(),
      edges: [
        Edge(from: '0', to: '1'),
        Edge(from: '0', to: '2'),
      ],
      nodes: [
        Node(id: '0'),
        Node(id: '2'),
        Node(id: '1'),
      ],
    );
  }
}
```

> Why not `Map<Node, Set<Node>> edges`?

__Answer: it's easier to serialize and deserialize this way... I think -- also, that way you can attach data to edges__

Say you want to store information on the node that is specific to your application. For example, the MP it costs to fire that skill. For this, you can provide a map or data class to hold your custom data. To do this, you'll also need to provide a custom serializer and deserializer. 

```dart
class MyData {
  const MyData(this.cost);

  final int cost;
}

class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The first data type is the type of the edge. The second is
    // of the node
    return SkillTree<dynamic, MyData>(
      layout: HeirarchicLayout(),
      serializeNode: (MyData myData) {
        return myData.toJson(myData);
      },
      deserializeNode: (Map<String, dynamic> json) {
        return myData.fromJson(json);
      },
      edges: [
        Edge(from: '0', to: '1'),
        Edge(from: '0', to: '2'),
      ],
      nodes: [
        Node(id: '0', data: MyData(4)),
        Node(id: '2', data: MyData(4)),
        Node(id: '1', data: MyData(4)),
      ],
    );
  }
}
```

Now that you have your MP on the node you can render it how you like by providing a nodeBuilder. It will receive the node and your data.

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

That's pretty shweet right? Notice the `SkillNode` though? That's because you have the option to insert `SkillNode`s inside of the nodes field directly and define your children that way.

```dart
SkillTree<void, void>(
  nodes: [
    SkillNode(id: '0', child: Container()),
    // ...
  ],
),
```

The same is possible with `SkillEdge`.

# But muh customizability !

`skill_tree` provides a theme called `SkillTreeThemeData` that you can modify as you like. If none is provided, a default is created that takes values from your app's default `ThemeData`.

Custom edges can even be drawn by providing an `edgePainter` to either a `SkillTree` or a `SkillEdge`.

TODO:

# Questions

> __Q:__ Can I use a Adjacency Matrix to store my data like this ?

```
  a b c d e
a 1 1 - - -
b - - 1 - -
c - - - 1 -
d - 1 1 - -
```

> __A:__ What the hell is even that? But no really, if you can help me create other serialization methods that'd be cool.

# TODO
- [] unnattachedNodes
- [] onAddChild
- [] onUpdate