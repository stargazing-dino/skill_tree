import 'package:skill_tree/src/models/base_node.dart';
import 'package:skill_tree/src/models/parent_children.dart';

/// Returns a list of children at depth N where N is decided by the count on the
/// generator.
Iterable<List<BaseNode<T>>> depthFirstSearch<T extends Object>(
  List<BaseNode<T>> nodes,
) sync* {
  if (nodes.isNotEmpty) {
    yield nodes;

    final nextNodes = nodes.fold<List<BaseNode<T>>>(
      [],
      (previousValue, node) => [...previousValue, ...node.children],
    );

    if (nextNodes.isNotEmpty) {
      yield* depthFirstSearch(nextNodes);
    }
  }
}

/// Travels through the tree left-to-right and returns the parent and children
/// at a tree intersection.
Iterable<ParentChildren<BaseNode<T>>> traverseByLineage<T extends Object>(
  BaseNode<T> node,
) sync* {
  if (node.children.isNotEmpty) {
    yield ParentChildren(parent: node, children: node.children);

    for (final childNode in node.children) {
      yield* traverseByLineage(childNode);
    }
  }
}
