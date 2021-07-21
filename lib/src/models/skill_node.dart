/// A SkillNode is a node in the [SkillTree]. Parent and child information is
/// not stored here but in the edges. This is done to keep cyclic graphs
/// possible.
class SkillNode<T> {
  /// The data associated with the skill node. If you want to restore this
  /// information from the json representation, ensure you use a `withConverter`
  /// function to convert the json representation to the data type on the
  /// [SkillTree].
  final T? data;

  /// The id of the skill node.
  final String id;

  /// The label of the skill node. This is used when the node is hovered or
  /// long-pressed to show a tooltip.
  final String? label;

  /// The optional semantic name of the skill node.
  final String? name;

  SkillNode({
    required this.id,
    this.data,
    this.label,
    this.name,
  });
}
