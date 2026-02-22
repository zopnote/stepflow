import 'dart:io' show Directory, File;

import 'package:stepflow/core.dart';
import 'package:stepflow/io.dart';
import 'package:stepflow_clang/src/analyze.dart';
import 'package:stepflow_clang/src/compile.dart';
import 'package:stepflow_clang/src/format.dart';
import 'package:stepflow_clang/src/report_settings.dart';

export 'package:stepflow_clang/src/build_type.dart';
export 'package:stepflow_clang/src/language.dart';
export 'package:stepflow_clang/src/optimization.dart';
export 'package:stepflow_clang/src/processor.dart';
export 'package:stepflow_clang/src/report_settings.dart';
export 'package:stepflow_clang/src/target.dart';

class Clang extends CollectionStep<Clang> {
  final File executable;
  final Directory workingDirectory;
  const Clang({required this.executable, required this.workingDirectory});

  Step compile(final ClangCompileSettings settings) =>
      stepwise<ClangCompile, ClangCompileSettings>(settings);

  Step analyze(final ClangAnalyzeSettings settings) =>
      stepwise<ClangAnalyze, ClangAnalyzeSettings>(settings);
  Step format(final ClangFormatSettings settings) =>
      stepwise<ClangFormat, ClangFormatSettings>(settings);
}

void test() {

  clang.compile(
    ClangCompileSettings(
      input: [],
      output: File("program.exe"),
      language: .c23,
      report: ClangReportSettings(warningLevel: .all),
      buildType: .executable,
      optimization: .high,
      targetProcessor: .x86_64,
    ),
  );

  Shell(program: "echo", arguments: ["Hello world!"])();

  Clang(executable: File(""), workingDirectory: Directory("")).analyze(
    ClangAnalyzeSettings(
      input: [],
      report: ClangReportSettings(warningLevel: .all),
      language: .c23,
      mode: .deep,
      outputType: .text,
    ),
  )();
}
