import 'package:skill_tree/src/models/delegate.dart';

class LayeredTreeDelegate extends SkillTreeDelegate {
  LayeredTreeDelegate({
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
  });

  final double crossAxisSpacing;

  final double mainAxisSpacing;
}
