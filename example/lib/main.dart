import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skill_tree/skill_tree.dart';

void main() => runApp(MyApp());

// Assets from https://opetngameart.org/content/random-rpg-icons-part-1

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ),
        // brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // var _nodes = <Map<String, dynamic>>[
  //   {
  //     'key': 'house',
  //     'children': [],
  //     'data': 'mouse',
  //   },
  // ];

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
            title: Text(
              'Skill Tree',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SkillTree<String, int>(
            unnattachedNodes: const [],
            onAddChild: () {},
            onUpdate: (List<Map<String, dynamic>> nodes) {
              // setState(() {
              // _nodes = nodes;
              // });
            },
            nodeBuilder: (BuildContext context, int photoNumber) {
              return Item(photoNumber: photoNumber);
            },
            nodes: [
              SkillNode(
                key: 'mouse',
                data: 1,
                children: [
                  SkillNode(
                    key: 'house',
                    data: 2,
                    children: [
                      SkillNode(
                        key: 'Cheese',
                        data: 7,
                        children: [
                          SkillNode(
                            key: 'envy',
                            data: 58,
                            children: [],
                          )
                        ],
                      ),
                      SkillNode(
                        key: 'yep',
                        data: 10,
                        children: [],
                      ),
                    ],
                  ),
                ],
              ),
              EmptySkillNode(
                key: 'nice',
                children: [
                  SkillNode(
                    key: 'glut',
                    data: 70,
                    children: [],
                  )
                ],
              ),
            ],
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
            offset: Offset(1.0, 2.0),
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
