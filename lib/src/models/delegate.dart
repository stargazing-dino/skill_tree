part of '../skill_tree.dart';

/// A delegate decides the layout to be used for the skill tree
///
/// This takes inspiration from but does not extend or implement
/// [MultiChildLayoutDelegate] as that class is specific to a
/// [CustomMultiChildLayout] does is not "delegated" any real work other
/// than holding layout config.
abstract class SkillTreeDelegate<EdgeType, NodeType, IdType extends Object,
    GraphType extends Graph<EdgeType, NodeType, IdType>> {
  /// Creates a layout delegate.
  ///
  /// The layout will update whenever [relayout] notifies its listeners.
  SkillTreeDelegate({Listenable? relayout}) : _relayout = relayout;

  final Listenable? _relayout;

  /// Returns information about the size and position of the nodes
  SkillNodeLayout<NodeType, IdType> layoutNodes(
    BoxConstraints constraints,
    GraphType graph,
    List<NodeDetails<NodeType, IdType>> nodeChildrenDetails,
  );

  /// We need to layout edges. However, an edge is not a direct RenderObject.
  /// Instead, it is a MultiChildRenderObject. Therefore, we must position
  /// the edges first based off the nodes.
  ///
  /// The positions and sizes of both edge terminals are needed to layout
  /// this edge.
  void layoutEdges(
    BoxConstraints constraints,
    SkillNodeLayout<NodeType, IdType> skillNodeLayout,
    GraphType graph,
    List<EdgeDetails<EdgeType, NodeType, IdType>> edgeChildrenDetails,
    List<NodeDetails<NodeType, IdType>> nodeChildrenDetails,
  ) {
    for (final edgeDetails in edgeChildrenDetails) {
      final edgeChild = edgeDetails.child;
      final edgeParentData = edgeDetails.parentData;
      final toDetails = nodeChildrenDetails.singleWhere((nodeDetails) {
        return nodeDetails.node.id == edgeDetails.edge.to;
      });
      final toChild = toDetails.child;
      final toParentData = toDetails.parentData;
      final toRect = toParentData.offset & toChild.size;
      final fromDetails = nodeChildrenDetails.singleWhere((nodeDetails) {
        return nodeDetails.node.id == edgeDetails.edge.from;
      });
      final fromChild = fromDetails.child;
      final fromParentData = fromDetails.parentData;
      final fromRect = fromParentData.offset & fromChild.size;

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
        toEdgeBox.shift(-edgeBoundingBox.topLeft),
      );
      fromEdgeChildParentData.addPositionData(
        fromEdgeBox.shift(-edgeBoundingBox.topLeft),
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

  /// Override this method to include additional information in the
  /// debugging data printed by [debugDumpRenderTree] and friends.
  ///
  /// By default, returns the [runtimeType] of the class.
  @override
  String toString() => objectRuntimeType(this, 'SkillTreeDelegae');
}

// TODO: Edges need to know the amount of space in the gutter available to
// them. Using that information, we can better constrain them when it comes
// to layout. I recommend we create a function template that takes in a node
// and returns the amount of space around it like so:
//  double getSpaceAroundNode(Node node) {
//    return node.spaceAround;
//  }

@immutable
class SkillNodeLayout<NodeType, IdType extends Object> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SkillNodeLayout({required this.size});

  // /// The minimum child index that intersects with (or is after) this scroll offset.
  // int getSpaceAroundForNode(Node<NodeType, IdType> node);

  // /// The maximum child index that intersects with (or is before) this scroll offset.
  // int getMaxChildIndexForScrollOffset(double scrollOffset);

  // /// The size and position of the child with the given index.
  // SliverGridGeometry getGeometryForChildIndex(int index);

  // /// The scroll extent needed to fully display all the tiles if there are
  // /// `childCount` children in total.
  // ///
  // /// The child count will never be null.
  // double computeMaxScrollOffset(int childCount);

  final Size size;
}
