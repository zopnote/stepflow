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
  final List<ClangAnalyzerChecker> scope;

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
    this.scope = const [ClangAnalyzerChecker.all],
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