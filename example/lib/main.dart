import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skill_tree/skill_tree.dart';

void main() => runApp(const MyApp());

/// Assets from https://opetngameart.org/content/random-rpg-icons-part-1
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

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
                crossAxisSpacing: 16.0,
                layout: [
                  ['0', '1', null],
                  ['2', null, '3'],
                  ['4', '5', '6'],
                ],
              ),
              nodeBuilder: (node) {
                final photoId = int.parse(node.id) + 1;

                // return SkillNode.fromNode(
                //   node: node,
                //   child: const SizedBox(
                //     height: 48.0,
                //     child: Placeholder(),
                //   ),
                // );

                return SkillNode.fromNode(
                  node: node,
                  child: Item(photoNumber: photoId),
                );
              },
              edges: [
                Edge(from: '0', to: '1'),
                Edge(from: '0', to: '2'),
              ],
              nodes: [
                Node(id: '0'),
                Node(id: '1'),
                Node(id: '2'),
                Node(id: '3'),
                Node(id: '4'),
                Node(id: '5'),
                Node(id: '6'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Item extends StatelessWidget {
  final int photoNumber;

  const Item({Key key, this.photoNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          'assets/icons_512x512/$photoNumber.png',
          height: 64.0,
          width: 64.0,
        ),
      ),
    );
  }
}
