import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/delegate.dart';

// TODO: We need to decide the origin of the plane so our offsets can be
// calculated.

/// A skill tree that lays out its nodes free hand based off the relative
/// offsets of the nodes.
class PositionedTreeDelegate<IdType extends Object>
    extends SkillTreeDelegate<IdType> {
  PositionedTreeDelegate({
    required this.positions,
  });

  final Map<IdType?, Offset> positions;
}
