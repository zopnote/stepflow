

/// The analyzer performs checks that are categorized into families or
/// “checkers”.
///
/// The default set of checkers covers a variety of checks targeted at
/// finding security and API usage bugs, dead code, and other logic errors.
/// In addition to these, the analyzer contains a number of Experimental
/// Checkers (aka alpha checkers). These checkers are under development and
/// are switched off by default. They may crash or emit a higher number of
/// false positives.
final class ClangAnalyzerChecker {
  /// The actual value in the command line interface of this checker;
  final String value;

  /// The analyzer performs checks that are categorized into families or
  /// “checkers”.
  ///
  /// The default set of checkers covers a variety of checks targeted at
  /// finding security and API usage bugs, dead code, and other logic errors.
  /// In addition to these, the analyzer contains a number of Experimental
  /// Checkers (aka alpha checkers). These checkers are under development and
  /// are switched off by default. They may crash or emit a higher number of
  /// false positives.
  ///
  /// If you want to specify Checker e.g.
  /// [cplusplus.ArrayDelete](https://clang.llvm.org/docs/analyzer/checkers.html#id54)
  /// or [optin.core.EnumCastOutOfRange](https://clang.llvm.org/docs/analyzer/checkers.html#id72)
  /// you can always instantiate ClangAnalysation, just with their names.
  ///
  /// All checkers are available [here](https://clang.llvm.org/docs/analyzer/checkers.html).
  const ClangAnalyzerChecker(this.value);

  /// Not really all checkers but all that are suitable.
  static const ClangAnalyzerChecker all = ClangAnalyzerChecker("all");

  /// Models core language features and contains general-purpose
  /// checkers such as division by zero, null pointer dereference,
  /// usage of uninitialized values, etc.
  ///
  /// These checkers must be always switched on as other checker rely on them.
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#core).
  static const ClangAnalyzerChecker core = ClangAnalyzerChecker("core");

  /// POSIX/Unix checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#unix).
  static const ClangAnalyzerChecker posix = ClangAnalyzerChecker("unix");

  /// Apple darwin checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#osx).
  static const ClangAnalyzerChecker apple = ClangAnalyzerChecker("osx");

  /// Checkers related to C++.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#id53).
  static const ClangAnalyzerChecker cxx = ClangAnalyzerChecker("cplusplus");

  /// Dead Code Checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#id63).
  static const ClangAnalyzerChecker deadCode = ClangAnalyzerChecker("deadcode");

  /// Checkers (mostly Objective C) that
  /// warn for null pointer passing and dereferencing errors.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#nullability).
  static const ClangAnalyzerChecker nullability = ClangAnalyzerChecker("nullability");

  /// Security related checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#security).
  static const ClangAnalyzerChecker security = ClangAnalyzerChecker("security");

  /// Checkers for portability, performance, optional security and coding
  /// style specific rules.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#optin).
  static const ClangAnalyzerChecker optin = ClangAnalyzerChecker("optin");

  @override
  String toString() => value;
  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! ClangAnalyzerChecker) {
      return false;
    }
    return value == other.value;
  }
}
