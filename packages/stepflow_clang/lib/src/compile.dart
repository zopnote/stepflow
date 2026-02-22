import 'dart:io' show File;

import 'package:path/path.dart';
import 'package:stepflow/core.dart';
import 'package:stepflow/platform.dart' show Platform;
import 'package:stepflow_clang/clang.dart';

import 'clang_step.dart';
import 'library.dart';

class ClangCompileSettings
    with StepWiser<Clang, ClangCompileSettings, ClangCompile> {
  final List<File> input;
  final File output;
  final List<NativeLibrary> libraries;
  final Map<String, String> macros;
  final ClangTarget? target;
  final ClangLanguage? language;
  final bool generateDebugInfo;
  final ClangTargetProcessor? targetProcessor;
  final ClangOptimization optimization;
  final ClangReportSettings report;
  final ClangBuildType buildType;

  const ClangCompileSettings({
    required this.input,
    required this.output,
    this.libraries = const [],
    this.macros = const {},
    this.target,
    this.language,
    this.generateDebugInfo = false,
    this.targetProcessor,
    this.optimization = ClangOptimization.moderate,
    this.report = const ClangReportSettings(),
    this.buildType = ClangBuildType.executable,
  });

  @override
  ClangCompile create() => ClangCompile();
}

class ClangCompile extends ClangStep<ClangCompileSettings> {
  @override
  List<String> format() => List.empty(growable: true)
    ..add("-O${wise.optimization.value}")
    ..addIf(wise.generateDebugInfo, "-g")
    ..addAll(wise.macros.macro((key, value) => "-D$key${value.fmtMacro()}"))
    ..addNotNull(wise.language, (v) => "-std=${v.standard}")
    ..addNotNull(wise.targetProcessor, (v) => "-march=${v.march}")
    ..addNotNull(wise.targetProcessor, (v) => "-mcpu=${v.mcpu}")
    ..add("-target=${wise.target ?? ClangTarget.from(Platform.current())}")
    ..addAll(wise.libraries.map((lib) => "-l${lib.binary}"))
    ..addAll(wise.libraries.map((lib) => "-I${lib.header}"))
    ..addAll(wise.libraries.map((l) => "-L${dirname(l.binary.path)}"))
    ..addAll(wise.report.toFlags())
    ..addIf(wise.report.analyzeExtensionsAsErrors, "--pedantic-errors")
    ..addIf(wise.report.analyzeExtensions, "--pedantic")
    ..addIf(wise.report.analyzeSystemHeader, "-Wsystem-header")
    ..addNotNull(
      wise.report.backtraceLimit,
      (v) => "--ftemplate-backtrace-limit=$v",
    )
    ..add("--ferror-limit=${wise.report.messageLimit}");
}