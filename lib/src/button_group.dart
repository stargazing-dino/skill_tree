import 'package:flutter/material.dart';

// TODO: This should all be editable to the user from padding to icon

class ButtonGroup extends StatelessWidget {
  final VoidCallback onAdd;

  final VoidCallback onRemove;

  const ButtonGroup({
    Key? key,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: onRemove,
              child: const Padding(
                child: const Icon(Icons.remove),
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 2.0,
                ),
              ),
            ),
            const Divider(height: 0),
            InkWell(
              onTap: onAdd,
              child: const Padding(
                child: const Icon(Icons.add),
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 2.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
