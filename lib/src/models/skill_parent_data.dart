import 'package:flutter/rendering.dart';

/// This is the parent class of [SkillEdgeParentData] and [SkillNodeChildData].
/// It's an almost pointless class other than to provide a common base for
/// ParentDataWidget<T> which was not designed to work with mutliple types
/// of data.
class SkillParentData extends ContainerBoxParentData<RenderBox> {}
