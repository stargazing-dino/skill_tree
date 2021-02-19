import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'quantity_button.dart';

typedef QuantityUpdate = void Function({required int index, required bool end});

class SkillRow extends StatelessWidget {
  final EdgeInsets tilePadding;

  final int index;

  final int depth;

  final double cardElevation;

  final List<Widget> children;

  final bool isEditable;

  final QuantityUpdate onAdd;

  final QuantityUpdate onRemove;

  const SkillRow({
    Key? key,
    required this.tilePadding,
    required this.index,
    required this.depth,
    required this.cardElevation,
    required this.children,
    required this.isEditable,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: tilePadding,
      child: IntrinsicHeight(
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
            if (isEditable) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: QuantityButton(
                  axis: Axis.vertical,
                  onAdd: () => onAdd(index: index, end: false),
                  onRemove: () => onRemove(index: index, end: false),
                  elevation: cardElevation,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: QuantityButton(
                  axis: Axis.vertical,
                  onAdd: () => onAdd(index: index, end: true),
                  onRemove: () => onRemove(index: index, end: true),
                  elevation: cardElevation,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
