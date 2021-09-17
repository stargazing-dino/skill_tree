import 'package:example/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skill_tree/skill_tree.dart';

class LayeredExamplePage extends StatelessWidget {
  const LayeredExamplePage({Key? key}) : super(key: key);

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
            child: SkillTree<void, void, String>(
              delegate: LayeredTreeDelegate(
                mainAxisSpacing: 32.0,
                crossAxisSpacing: 48.0,
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
              nodeBuilder: (node) {
                final photoId = int.parse(node.id) + 1;

                return SkillNode.fromNode(
                  node: node,
                  child: Center(
                    child: Item(photoNumber: photoId),
                  ),
                );
              },
              edges: const [
                Edge(from: '7', to: '9'),
                Edge(from: '10', to: '14'),
                Edge(from: '12', to: '15'),
              ],
              nodes: const [
                Node(id: '0'),
                Node(id: '1'),
                Node(id: '2'),
                Node(id: '3'),
                Node(id: '4'),
                Node(id: '5'),
                Node(id: '6'),
                Node(id: '7'),
                Node(id: '8'),
                Node(id: '9'),
                Node(id: '10'),
                Node(id: '11'),
                Node(id: '12'),
                Node(id: '13'),
                Node(id: '14'),
                Node(id: '15'),
                Node(id: '16'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
