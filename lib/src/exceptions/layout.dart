/// Thrown when a layout exception occurs. This can be do from invalid `depth`,
/// an impossible layout or any other reason.
class LayoutException implements Exception {
  /// Description of the cause of the layout exception.
  final String? message;

  LayoutException(this.message);

  @override
  String toString() {
    String result = "LayoutException: $message";
    return result;
  }
}
