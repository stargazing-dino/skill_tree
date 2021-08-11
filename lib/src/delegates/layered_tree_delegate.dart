import 'package:skill_tree/src/models/delegate.dart';

class LayeredTreeDelegate<IdType extends Object>
    extends SkillTreeDelegate<IdType> {
  LayeredTreeDelegate({
    required this.layout,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  }) {
    assert(debugCheckLayout(layout));
  }

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
      layout == other.layout &&
      crossAxisSpacing == other.crossAxisSpacing &&
      mainAxisSpacing == other.mainAxisSpacing;

  @override
  int get hashCode =>
      layout.hashCode ^ crossAxisSpacing.hashCode ^ mainAxisSpacing.hashCode;
}
