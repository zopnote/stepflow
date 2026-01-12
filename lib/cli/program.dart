import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:stepflow/common.dart';
import 'package:stepflow/cli/steps/shell.dart' show Shell;
import 'package:stepflow/platform/platform.dart' as stepflow;

final List<String> _pathEntries =
    Platform.environment["PATH"]?.split(Platform.isWindows ? ";" : ":") ?? [];

class ApplicationNotFoundException implements Exception {
  final String applicationName;
  late final String cause;
  ApplicationNotFoundException(this.applicationName)
      : cause = "Couldn't find the application $applicationName.";
}

final class Program<T extends Application> {
  const Program(this.executable, this.app);
  final File executable;
  final T app;
  factory Program.fromEnvironment([String? overrideName]) {
    final File? executable = _pathEntries
        .map((pathEntry) => File(
              path.join(
                pathEntry,
                (overrideName ?? application.name) +
                    (Platform.isWindows ? ".exe" : ""),
              ),
            ))
        .firstWhereOrNull((file) => file.existsSync());

    if (executable == null) {
      throw ApplicationNotFoundException(application.name);
    }
    return Program(executable, application);
  }
}

abstract class Application {
  final String name;
  final String executable;
  static Application new() {

  }
  const Application(this.name, this.executable);
}



void main() {
  stepflow.Platform.ios(sdkVersion: stepflow.Version(26, 2, 0));
  stepflow.Platform.macos(
    processor: stepflow.MacOSProcessor.applesilicon,
    sdkVersion: stepflow.Version(26, 2, 0),
  );
  stepflow.Platform.android(
      apiLevel: stepflow.AndroidAPI.tiramisu,
      abi: stepflow.AndroidABI.arm64_v8a);
  stepflow.Platform.linux(architecture: stepflow.LinuxArchitecture.x86_64);
  stepflow.Platform.windows(
      architecture: stepflow.WindowsArchitecture.x64,
      buildVersion: stepflow.WindowsBuildVersion.win11_24H2);
  final currentPlatform = stepflow.Platform.current();
  final clang = Program.fromEnvironment(Clang());

  final compileStep = clang.app.compileFiles(
    inputFiles: ["main.cpp"],
    outputFile: "main.exe",
    targetPlatform: currentPlatform,
    options: const ClangCompilationOptions(
      warnings: ClangShowWarnings.none,
      language: ClangLanguage.cxx23,
      optimization: ClangOptimization.full,
      targetArchitecture: ClangTargetArchitecture.native,
    ),
  );
  final analyzeStep = clang.app.analyzeFiles(
    inputFiles: ["main.cpp"],
    options: const ClangStaticAnalysisOptions(
      outputFormat: ClangAnalysisOutputFormat.html,
    ),
  );
}
