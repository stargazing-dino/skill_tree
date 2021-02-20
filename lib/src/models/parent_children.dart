class ParentChildren<T> {
  final T parent;

  final Iterable<T> children;

  const ParentChildren({required this.parent, required this.children});
}
