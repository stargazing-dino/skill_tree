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

abstract class RootNode<T> extends Node<T> {
  RootNode({
    required String id,
    T? data,
    String? name,
  }) : super(id: id, data: data, name: name);
}
