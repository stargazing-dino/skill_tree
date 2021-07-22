# skill_tree

A package to build skill trees of any kind. This package differs from `graphview` as it only tries to provide users an interface to make a skill tree rather than a general purpose graph viewer.

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
>
>__Answer: it's easier to serialize and deserialize this way... I think -- also, this way you can attach data to edges__

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
    // The first data type is the data type of the edge. The second is
    // of the node
    return SkillTree<void, MyData>(
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

That's pretty shweet right? Notice the `SkillNode` though? That's because you have the option to insert `SkillNode`s inside of the nodes field directly and define your children that way. The same is possible with `SkillEdge`.

```dart
SkillTree<void, void>(
  nodes: [
    SkillNode(id: '0', child: Container()),
    // ...
  ],
),
```

Another feature users usually want with their skill trees are points and points to acqure functionality. A node usually has a `cost` associated with it to unlock. For that, you can provide a `requirement` to your `SkillNode` and a `value` to your `SkillTree`. Note, everything defined on a `SkillTree` is automatically deserialized for you excluding the `data`. With that information, you can decide on whether your node is locked or unlocked.

```dart
class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkillTree<void, void>(
      value: 5,
      maxValue: 20,
      layout: HeirarchicLayout(),
      edges: [
        Edge(from: '0', to: '1'),
        Edge(from: '0', to: '2'),
      ],
      nodes: [
        // TODO: I need an assertion in the graph that checks a SkillNode has a
        // smaller requirement than its descendant. Throw [GraphException].
        SkillNode(id: '0', child: MyChild(), requirement: 1),
        SkillNode(id: '1', child: MyChild(), requirement: 10),
        SkillNode(id: '2', child: MyChild(), requirement: 15),
      ],
    );
  }
}
```

# But muh customizability !

`skill_tree` provides a theme called `SkillTreeThemeData` that you can modify as you like. If none is provided, a default is created that takes values from your app's default `ThemeData`.

Custom edges can even be drawn by providing an `edgePainter` to either a `SkillTree` or a `SkillEdge`.

# Help me

I'm not very good with graphs. I'd love to have fancy algorithms that draw both the nodes and edges but I think I'll need support for that.

How you can help:

- [ ] Open an issue with an example of a skill tree and a rough sketch of how it'd be accomplished. We can start with two things. How the `graph` representation would look like and how a `layout` algorithm would roughly work. You don't have to be exact.
- [ ] Improve on my definition of a graph and its subtypes.
- [ ] Provide a better interface for managing the graph. This could be writing me some generic algorithms like depthFirstSearh or whatever.
- [ ] Every TODO: is free game but are likely related to low level Flutter rendering


# TODO
- [ ] toggleable GUI to add and edit nodes (onAddChild, onUpdate)
- [ ] animations
- [ ] unnattached nodes
- [ ] SkillTree.fromJson
- [ ] Other serialization options (adjacency matrix?)