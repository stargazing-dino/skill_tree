/// A delegate decides the layout to be used for the skill tree
///
/// This takes inspiration from but does not extend or implement
/// [MultiChildLayoutDelegate] as that class is specific to a
/// [CustomMultiChildLayout] does is not "delegated" any real work other
/// than holding layout config.
abstract class SkillTreeDelegate<IdType extends Object> {
  const SkillTreeDelegate();
}
