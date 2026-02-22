
/// Controls the high-level analyzer mode, which influences the default
/// settings for some of the lower-level config options (such as IPAMode).
final class ClangAnalyzerMode {
  /// The actual value in the command line interface of this mode;
  final String value;

  /// Controls the high-level analyzer mode, which influences the default
  /// settings for some of the lower-level config options (such as IPAMode).
  const ClangAnalyzerMode(this.value);

  /// Performs a deep analysis of the code.
  static const ClangAnalyzerMode deep = ClangAnalyzerMode("deep");

  /// Faster analysation time but not as deep.
  static const ClangAnalyzerMode shallow = ClangAnalyzerMode("shallow");
}