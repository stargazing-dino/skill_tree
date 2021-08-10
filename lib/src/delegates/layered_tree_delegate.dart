import 'package:skill_tree/src/models/delegate.dart';

class LayeredTreeDelegate<IdType extends Object>
    extends SkillTreeDelegate<IdType> {
  LayeredTreeDelegate({
    required this.layout,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  });

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final List<List<IdType?>> layout;
}
