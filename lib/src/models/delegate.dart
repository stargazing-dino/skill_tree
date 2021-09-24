import 'package:flutter/material.dart';
import 'package:skill_tree/src/models/graph.dart';
import 'package:skill_tree/src/skill_edge.dart';
import 'package:skill_tree/src/skill_tree.dart';
import 'package:skill_tree/src/widgets/edge_line.dart';
import 'package:skill_tree/src/widgets/skill_vertex.dart';

/// A delegate decides the layout to be used for the skill tree
///
/// This takes inspiration from but does not extend or implement
/// [MultiChildLayoutDelegate] as that class is specific to a
/// [CustomMultiChildLayout] does is not "delegated" any real work other
/// than holding layout config.
abstract class SkillTreeDelegate<EdgeType, NodeType, IdType extends Object,
    GraphType extends Graph<EdgeType, NodeType, IdType>> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SkillTreeDelegate();

  /// Returns information about the size and position of the tiles in the grid.
  SkillNodeLayout layoutNodes(
    BoxConstraints constraints,
    GraphType graph,
  );

  /// We need to layout edges. However, an edge is not a direct RenderObject.
  /// Instead, it is a MultiChildRenderObject. Therefore, we must position
  /// the edges first based off the nodes.
  ///
  /// The positions and sizes of both edge terminals are needed to layout
  /// this edge.
  void layoutEdges(
    BoxConstraints constraints,
    SkillNodeLayout skillNodeLayout,
    GraphType graph,
  ) {
    for (final edge in graph.edges) {
      final edgeChild =
          childForEdge(edge) as RenderEdgeLine<EdgeType, NodeType, IdType>;
      final edgeParentData =
          edgeChild.parentData as SkillEdgeParentData<EdgeType, IdType>;
      final to = childForNode(graph.getNodeFromIdType(edge.to));
      final toParentData = to.parentData as SkillParentData;
      final toRect = toParentData.offset & to.size;
      final from = childForNode(graph.getNodeFromIdType(edge.from));
      final fromParentData = from.parentData as SkillParentData;
      final fromRect = fromParentData.offset & from.size;

      assert(
        toRect.intersect(fromRect).isEmpty,
        'Two nodes must not intersect one another.',
      );

      /// Specify in a 2d space where the "to" Node is relative to the "from"
      /// node. (This will be used to orient the edge line and better draw
      /// the vertex).
      ///
      /// We get a vector moving from "from" to "to" and get the direction of the
      /// vector.
      final _toAlignment = edgeParentData.toAlignment ?? Alignment.center;
      final _fromAlignment = edgeParentData.fromAlignment ?? Alignment.center;
      final angle = (_toAlignment.withinRect(fromRect) -
              _fromAlignment.withinRect(toRect))
          .direction;
      final toAlignment =
          (edgeParentData.toAlignment ?? getAlignmentForAngle(angle));
      final fromAlignment = edgeParentData.fromAlignment ?? (toAlignment * -1);

      final children = edgeChild.getChildrenAsList();
      final toEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillVertexToParentData;
      });
      final toEdgeChildParentData =
          toEdgeChild.parentData as SkillVertexParentData;
      final fromEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillVertexFromParentData;
      });
      final fromEdgeChildParentData =
          fromEdgeChild.parentData as SkillVertexParentData;

      // TODO: I shouldn't use getDryLayout here as it has some issues.
      // Do same as tooltip package.
      final toEdgeSize = toEdgeChild.getDryLayout(constraints);
      final fromEdgeSize = fromEdgeChild.getDryLayout(constraints);
      final fromEdgeBox = fromAlignment
              .withinRect(fromRect)
              .translate(-fromEdgeSize.width / 2, -fromEdgeSize.height / 2) &
          fromEdgeSize;
      final toEdgeBox = toAlignment
              .withinRect(toRect)
              .translate(-toEdgeSize.width / 2, -toEdgeSize.height / 2) &
          toEdgeSize;
      final edgeBoundingBox = fromEdgeBox.expandToInclude(toEdgeBox);

      edgeParentData.offset = edgeBoundingBox.topLeft;

      toEdgeChildParentData.addPositionData(
        fromEdgeBox.shift(-edgeBoundingBox.topLeft),
      );
      fromEdgeChildParentData.addPositionData(
        toEdgeBox.shift(-edgeBoundingBox.topLeft),
      );

      // TODO: I'm not setting the constraints properly yet because the current
      // boundingRect does not account for the gutter spacing. Gutter spacing
      // seems dependent on layout type too...
      // draggableEdgeChild.layout(BoxConstraints.tight(boundingRect.size));
      // TODO: Prev todo might not be correct when dragging. A draggable should
      // not have constraints so it can reach even the furthest nodes.
      edgeChild.layout(constraints);
    }
  }

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(
    covariant SkillTreeDelegate<EdgeType, NodeType, IdType, GraphType>
        oldDelegate,
  );
}

// TODO: Edges need to know the amount of space in the gutter available to
// them. Using that information, we can better constrain them when it comes
// to layout. I recommend we create a function template that takes in a node
// and returns the amount of space around it like so:
//  double getSpaceAroundNode(Node node) {
//    return node.spaceAround;
//  }

@immutable
abstract class SkillNodeLayout {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SkillNodeLayout();

  // /// The minimum child index that intersects with (or is after) this scroll offset.
  // int getMinChildIndexForScrollOffset(double scrollOffset);

  // /// The maximum child index that intersects with (or is before) this scroll offset.
  // int getMaxChildIndexForScrollOffset(double scrollOffset);

  // /// The size and position of the child with the given index.
  // SliverGridGeometry getGeometryForChildIndex(int index);

  // /// The scroll extent needed to fully display all the tiles if there are
  // /// `childCount` children in total.
  // ///
  // /// The child count will never be null.
  // double computeMaxScrollOffset(int childCount);
}
