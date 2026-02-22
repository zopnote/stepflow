final class ClangAnalyzerOutputType {
  final String value;
  const ClangAnalyzerOutputType(this.value);
  static const ClangAnalyzerOutputType html = ClangAnalyzerOutputType("html");
  static const ClangAnalyzerOutputType sarif = ClangAnalyzerOutputType("sarif");
  static const ClangAnalyzerOutputType plist = ClangAnalyzerOutputType("plist");
  static const ClangAnalyzerOutputType text = ClangAnalyzerOutputType("text");

  @override
  String toString() => value;
  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! ClangChecker) {
      return false;
    }
    return value == other.value;
  }
}