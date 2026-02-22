import 'dart:io' show File;

import 'package:stepflow/core.dart';
import 'package:stepflow_clang/clang.dart';

import 'clang_step.dart';
import 'library.dart';

class ClangAnalyzeSettings
    with StepWiser<Clang, ClangAnalyzeSettings, ClangAnalyze> {
  final List<File> input;
  final File? output;
  final List<NativeLibrary> libraries;
  final Map<String, String> macros;
  final ClangTarget? target;
  final ClangLanguage? language;
  final ClangReportSettings report;

  /// [List] of the Checkers, the analyzer should analyze for in the code.
  final List<ClangChecker> scope;

  /// Output type of the analysation.
  final ClangAnalyzerOutputType? outputType;

  /// Maximal iterations over the predicted values to inspect issues.
  final int maxLoopIteration;
  // TODO: -Xanalyzer -analyzer-max-loop

  /// Max recursion that is allowed to inspect.
  final int maxRecursion;
  // TODO: -Xanalyzer -analyzer-max-recursion

  /// Maximum count of nodes that are analyzed in sequence.
  final int maxNodes;
  // TODO: -Xanalyzer -analyzer-max-nodes=100000

  /// Whether the analysis will analyze across function calls.
  final bool acrossFunctions;
  // TODO: -Xanalyzer -analyzer-config interprocedural=true

  /// Whether the analysis should try to widen loops.
  final bool widenLoops;

  /// Whether the analysis should try to unroll loops with known bounds.
  final bool unrollLoops;

  /// Whether macros related to the bugpath should be expanded
  /// and included in the plist output.
  final bool expandMacros;

  /// Controls the high-level analyzer mode, which influences the default
  /// settings for some of the lower-level config options (such as IPAMode).
  final ClangAnalysationMode mode;

  const ClangAnalyzeSettings({
    required this.input,
    this.outputType = ClangAnalyzerOutputType.text,
    this.scope = const [ClangChecker.all],
    this.acrossFunctions = true,
    this.maxLoopIteration = 10,
    this.maxNodes = 1000,
    this.maxRecursion = 10,
    this.widenLoops = false,
    this.unrollLoops = false,
    this.expandMacros = false,
    this.mode = ClangAnalysationMode.shallow,
    this.target,
    this.output,
    this.libraries = const [],
    this.macros = const {},
    this.language,
    this.report = const ClangReportSettings(),
  });

  @override
  ClangAnalyze create() => ClangAnalyze();
}

class ClangAnalyze extends ClangStep<ClangAnalyzeSettings> {
  @override
  List<String> format() => List.empty(growable: true)
    ..add("--analyze")
    ..add("-Xanalyzer")
    ..add("-analyzer-checker=${wise.scope.join(",")}")
    ..add("-analyzer-output=${wise.outputType}")
    ..add("-analyzer-max-loop=${wise.maxLoopIteration}")
    ..add("-analyzer-max-recursion=${wise.maxRecursion}")
    ..add("-analyzer-max-nodes=${wise.maxNodes}");
}

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

/// Controls the high-level analyzer mode, which influences the default
/// settings for some of the lower-level config options (such as IPAMode).
final class ClangAnalysationMode {
  /// The actual value in the command line interface of this mode;
  final String value;

  /// Controls the high-level analyzer mode, which influences the default
  /// settings for some of the lower-level config options (such as IPAMode).
  const ClangAnalysationMode(this.value);

  /// Performs a deep analysis of the code.
  static const ClangAnalysationMode deep = ClangAnalysationMode("deep");

  /// Faster analysation time but not as deep.
  static const ClangAnalysationMode shallow = ClangAnalysationMode("shallow");
}

/// The analyzer performs checks that are categorized into families or
/// “checkers”.
///
/// The default set of checkers covers a variety of checks targeted at
/// finding security and API usage bugs, dead code, and other logic errors.
/// In addition to these, the analyzer contains a number of Experimental
/// Checkers (aka alpha checkers). These checkers are under development and
/// are switched off by default. They may crash or emit a higher number of
/// false positives.
final class ClangChecker {
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
  const ClangChecker(this.value);

  /// Not really all checkers but all that are suitable.
  static const ClangChecker all = ClangChecker("all");

  /// Models core language features and contains general-purpose
  /// checkers such as division by zero, null pointer dereference,
  /// usage of uninitialized values, etc.
  ///
  /// These checkers must be always switched on as other checker rely on them.
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#core).
  static const ClangChecker core = ClangChecker("core");

  /// POSIX/Unix checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#unix).
  static const ClangChecker posix = ClangChecker("unix");

  /// Apple darwin checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#osx).
  static const ClangChecker apple = ClangChecker("osx");

  /// Checkers related to C++.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#id53).
  static const ClangChecker cxx = ClangChecker("cplusplus");

  /// Dead Code Checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#id63).
  static const ClangChecker deadCode = ClangChecker("deadcode");

  /// Checkers (mostly Objective C) that
  /// warn for null pointer passing and dereferencing errors.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#nullability).
  static const ClangChecker nullability = ClangChecker("nullability");

  /// Security related checkers.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#security).
  static const ClangChecker security = ClangChecker("security");

  /// Checkers for portability, performance, optional security and coding
  /// style specific rules.
  ///
  /// Reference to [here](https://clang.llvm.org/docs/analyzer/checkers.html#optin).
  static const ClangChecker optin = ClangChecker("optin");

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
