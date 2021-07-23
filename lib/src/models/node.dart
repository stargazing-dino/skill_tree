import 'package:meta/meta.dart';

/// A [Node] is a node in the [SkillTree]. Parent and child information is
/// not stored here but in the edges. This is done to keep cyclic graphs
/// possible.
@sealed
class Node<T> {
  Node({
    required this.id,
    this.data,
    this.name,
  });

  /// The data associated with the skill node. If you want to restore this
  /// information from the json representation, ensure you use a `withConverter`
  /// function to convert the json representation to the data type on the
  /// [SkillTree].
  final T? data;

  /// The id of the skill node.
  final String id;

  /// The optional semantic name of the skill node.
  final String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Node<T> &&
        other.data == data &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return data.hashCode ^ id.hashCode ^ name.hashCode;
  }
}

// TODO: This stuff would be internal to the graph and we'd need another Node
// type for a user provided node. We would transform all of those user provided
// nodes to one of these types and that would help us better work with nodes.
// The same could be safe of edges. We could have a self-referential edge and
// all that.

// class RootNode<T> extends Node<T> {
//   RootNode({
//     required String id,
//     T? data,
//     String? name,
//   }) : super(id: id, data: data, name: name);
// }

// class LeafNode<T> extends Node<T> {
//   LeafNode({
//     required String id,
//     T? data,
//     String? name,
//   }) : super(id: id, data: data, name: name);
// }

// a node with at least one child.
// class InternalNode<T> extends Node<T> {
//   InternalNode({
//     required String id,
//     T? data,
//     String? name,
//   }) : super(id: id, data: data, name: name);
// }
