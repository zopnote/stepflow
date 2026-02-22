import 'package:stepflow_clang/src/warning_level.dart';

class ClangReportSettings {
  final ClangWarningLevel warningLevel;
  final int messageLimit;
  final int? backtraceLimit;
  final bool analyzeExtensions;
  final bool analyzeSystemHeader;

  /// Turns the warnings into errors.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> warningsAsErrorsPerName;

  /// Turns warnings into warnings even if ``ClangWarningLevel.uncompromising`` is specified.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> excludeWarningsAsErrorsPerName;

  /// Enables the warnings per name.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> enableWarningsPerName;

  /// Disables the warnings per name.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> disableWarningsPerName;

  const ClangReportSettings({
    this.warningLevel = ClangWarningLevel.normal,
    this.messageLimit = 0,
    this.analyzeExtensions = false,
    this.analyzeSystemHeader = false,
    this.backtraceLimit,
    this.warningsAsErrorsPerName = const [],
    this.excludeWarningsAsErrorsPerName = const [],
    this.enableWarningsPerName = const [],
    this.disableWarningsPerName = const [],
  });
  Iterable<String> toFlags() => [
    "-${warningLevel.flag}",
    ...disableWarningsPerName.map((name) => "-Wno-$name"),
    ...enableWarningsPerName.map((name) => "-W$name"),
    ...excludeWarningsAsErrorsPerName.map((name) => "-Wno-error=$name"),
    ...warningsAsErrorsPerName.map((name) => "-Werror=$name"),
  ];
  bool get analyzeExtensionsAsErrors {
    if (warningLevel != ClangWarningLevel.uncompromising) {
      return false;
    }
    return analyzeExtensions;
  }
}