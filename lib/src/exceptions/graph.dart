/// Thrown when a graph exception occurs
class GraphException implements Exception {
  /// Description of the cause of the layout exception.
  final String? message;

  GraphException(this.message);

  @override
  String toString() {
    String result = "GraphException: $message";
    return result;
  }
}
