import 'package:collection/collection.dart';
import 'package:skill_tree/src/models/delegate.dart';

// TODO: I think I can get the centered behavior if I don't care about
// square layouts...

class LayeredTreeDelegate<IdType extends Object>
    extends SkillTreeDelegate<IdType> {
  LayeredTreeDelegate({
    required this.layout,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  }) {
    assert(debugCheckLayout(layout));
  }

  final equality = const DeepCollectionEquality();

  /// Returns true if the layout is empty or if the layout is NxM
  /// dimensional. That is, every row must contain exactly M elements.
  bool debugCheckLayout(List<List<IdType?>> layout) {
    if (layout.isEmpty) return true;

    final firstLayerSize = layout.first.length;

    return layout.every((layer) => layer.length == firstLayerSize);
  }

  final List<List<IdType?>> layout;

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  @override
  bool operator ==(other) =>
      other is LayeredTreeDelegate<IdType> &&
      equality.equals(layout, other.layout) &&
      crossAxisSpacing == other.crossAxisSpacing &&
      mainAxisSpacing == other.mainAxisSpacing;

  @override
  int get hashCode =>
      layout.hashCode ^ crossAxisSpacing.hashCode ^ mainAxisSpacing.hashCode;
}
