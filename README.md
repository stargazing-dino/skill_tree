# skill_tree

A package to build skill trees of any kind.

## Simple usage

```dart
class Home extends StatelessWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkillTree(
      layout: HeirarchicLayout(),
      edges: [
        SkillEdge(from: '0', to: '1'),
        SkillEdge(from: '0', to: '2'),
      ],
      nodes: [
        SkillNode(id: '0'),
        SkillNode(id: '2'),
        SkillNode(id: '1'),
      ],
    );
  }
}
```

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
        SkillEdge(from: '0', to: '1'),
        SkillEdge(from: '0', to: '2'),
      ],
      nodes: [
        SkillNode(id: '0', data: MyData(4)),
        SkillNode(id: '2', data: MyData(4)),
        SkillNode(id: '1', data: MyData(4)),
      ],
    );
  }
}
```

Now that you have your MP on the node you can render it how you like by providing a nodeBuilder. It will receive the node and your data.

```dart
nodeBuilder: (SkillNode<MyData> node) {
  return Column(
    children: [
      Text(node.name),
      Text('MP cost: ${node.data}'),
    ],
  );
}
```

That's pretty shweet.


# TODO
- [] unnattachedNodes: const [],
- [] onAddChild: () {},
- [] onUpdate: