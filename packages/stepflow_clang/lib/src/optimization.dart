class ClangOptimization {
  final String value;
  const ClangOptimization(this.value);
  static const ClangOptimization tiny = ClangOptimization("s");
  static const ClangOptimization aggressive = ClangOptimization("fast");
  static const ClangOptimization high = ClangOptimization("3");
  static const ClangOptimization moderate = ClangOptimization("2");
  static const ClangOptimization low = ClangOptimization("1");
  static const ClangOptimization none = ClangOptimization("0");

  @override
  bool operator ==(Object other) {
    if (other is! ClangOptimization) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}