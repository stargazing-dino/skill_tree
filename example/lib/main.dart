import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';

void main() => runApp(const MyApp());

// Assets from https://opetngameart.org/content/random-rpg-icons-part-1

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            brightness: Brightness.dark,
            backgroundColor: theme.backgroundColor.withAlpha(40),
            title: const Text(
              'Skill Tree',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SkillTree<void, void>(
            layout: HierarchicLayout(),
            nodeBuilder: (node) {
              return Container(
                height: 100,
                width: 100,
                color: Colors.pink,
              );
            },
            edges: [
              SkillEdge(from: '0', to: '1'),
              SkillEdge(from: '0', to: '2'),
            ],
            nodes: [
              SkillNode(id: '0'),
              SkillNode(id: '2'),
              SkillNode(id: '1'),
            ],
          ),
        ),
      ],
    );
  }
}

// class Item extends StatelessWidget {
//   final int photoNumber;

//   const Item({Key key, this.photoNumber}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16.0),
//         border: Border.all(
//           color: Colors.grey,
//           width: 2.4,
//         ),
//         boxShadow: [
//           BoxShadow(
//             offset: const Offset(1.0, 2.0),
//             blurRadius: 4.0,
//             color: Colors.grey.shade600,
//           )
//         ],
//       ),
//       // clipBehavior: Clip.hardEdge,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16.0),
//         child: Image.asset(
//           'assets/icons_512x512/$photoNumber.png',
//           height: 64.0,
//           width: 64.0,
//         ),
//       ),
//     );
//   }
// }
