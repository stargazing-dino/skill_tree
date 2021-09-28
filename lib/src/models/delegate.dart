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
      // Get the necessary information of the nodes and edge data
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
      /// the point).
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
      final fromCenter = fromAlignment.withinRect(fromRect);
      final toCenter = toAlignment.withinRect(toRect);

      // Laying out the individual points in the edge line
      Rect edgeBoundingBox = Rect.fromPoints(fromCenter, toCenter);
      final children = edgeChild.getChildrenAsList();

      final toEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillPointToParentData;
      });
      final toEdgeChildParentData =
          toEdgeChild.parentData as SkillPointParentData;
      // TODO: I shouldn't use getDryLayout here as it has some issues.
      // Do same as tooltip package.
      final toEdgeSize = toEdgeChild.getDryLayout(constraints);
      final toEdgeBox = toCenter.translate(
            -toEdgeSize.width / 2,
            -toEdgeSize.height / 2,
          ) &
          toEdgeSize;

      toEdgeChildParentData.rect = toEdgeBox.shift(-edgeBoundingBox.topLeft);

      final fromEdgeChild = children.singleWhere((child) {
        return child.parentData is SkillPointFromParentData;
      });
      final fromEdgeChildParentData =
          fromEdgeChild.parentData as SkillPointParentData;
      final fromEdgeSize = fromEdgeChild.getDryLayout(constraints);
      final fromEdgeBox = fromCenter.translate(
            -fromEdgeSize.width / 2,
            -fromEdgeSize.height / 2,
          ) &
          fromEdgeSize;

      fromEdgeChildParentData.rect = fromEdgeBox.shift(
        -edgeBoundingBox.topLeft,
      );

      edgeBoundingBox = edgeBoundingBox.expandToInclude(fromEdgeBox);

      edgeParentData.fromCenter = fromCenter - edgeBoundingBox.topLeft;
      edgeParentData.toCenter = toCenter - edgeBoundingBox.topLeft;

      // TODO: We'll add control point sizes here
      // for (final controlPoint in controlPoints) {
      //   edgeBoundingBox.expandToInclude(fromEdgeBox);
      // }

      edgeParentData.offset = edgeBoundingBox.topLeft;

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

  // TODO:
  // int getSpaceAroundForNode(Node<NodeType, IdType> node);

  final Size size;
}
