import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/delegate.dart';

class LayeredTreeDelegate<IdType extends Object>
    extends SkillTreeDelegate<IdType> {
  const LayeredTreeDelegate({
    required this.layout,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<List<IdType?>> layout;

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final CrossAxisAlignment crossAxisAlignment;

  final equality = const DeepCollectionEquality();

  @override
  bool operator ==(other) =>
      other is LayeredTreeDelegate<IdType> &&
      equality.equals(layout, other.layout) &&
      crossAxisSpacing == other.crossAxisSpacing &&
      mainAxisSpacing == other.mainAxisSpacing &&
      crossAxisAlignment == other.crossAxisAlignment;

  @override
  int get hashCode =>
      layout.hashCode ^
      crossAxisSpacing.hashCode ^
      mainAxisSpacing.hashCode ^
      crossAxisAlignment.hashCode;
}
