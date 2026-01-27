import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as _path;
import 'package:path/path.dart' as path;
import 'package:stepflow/common.dart';
import 'package:stepflow/platform/platform.dart' as stepflow;
import 'package:uuid/uuid.dart';

import '../modspec/compiler/clang.dart';

abstract class Application {
  final Executable executable;
  const Application(this.executable);
}

class ApplicationNotFoundException implements Exception {
  final String applicationName;
  late final String cause;
  ApplicationNotFoundException(this.applicationName)
      : cause = "Couldn't find the application $applicationName.";
}

class ExecutionResult {}

typedef ExecutionCallback = FutureOr<ExecutionResult> Function(
    List<String> arguments,
    [CommandLineInterfaceProcessOptions? options,
    ResponseCallback? onResponse]);

class Executable {
  final ExecutionCallback execute;

  const Executable(this.execute);

  static Executable environment(String name) {
    final List<String> pathEntries =
        Platform.environment["PATH"]?.split(Platform.isWindows ? ";" : ":") ??
            [];
    final File? executable = pathEntries
        .map((pathEntry) => File(
              _path.join(
                pathEntry,
                name + (Platform.isWindows ? ".exe" : ""),
              ),
            ))
        .firstWhereOrNull((file) => file.existsSync());
    if (executable == null) {
      throw ApplicationNotFoundException(name);
    }
    return file(executable);
  }

  static Executable file(File file) =>
      Executable((arguments, [options, stdout, stderr]) async {
        if (!(await file.exists())) return ExecutionResult();

        return ExecutionResult();
      });
}

/**
 * Manages a command line process, initiated by this application.
 */

class CommandLineInterfaceProcessOptions {
  /**
   * Either start the process with elevated privileges or as default.
   *
   * Whenever errors occur, ensure your platform supports the behaviour of implementation the approach of
   * [CommandLineInterfaceProcess] takes.
   */
  final bool runAsAdministrator;

  /**
   * If the program should be run in the systems command shell.
   */
  final bool runInShell;

  /**
   * The directory, the process will be started in.
   */
  final String? workingDirectory;

  const CommandLineInterfaceProcessOptions(
      {this.runAsAdministrator = false,
      this.runInShell = false,
      this.workingDirectory});
}

typedef CommandLineInterfaceProcessOutputCallback = FutureOr<void> Function(
    List<int> chars);

class CommandLineInterfaceProcess {
  /**
   * Path to the executable file, that should be interfaced for.
   * Make sure the file exists, [CommandLineInterfaceProcess] doesn't
   * check for.
   *
   * Either an absolute path or relative to [workingDirectory].
   */
  final String? executableFilePath;

  final CommandLineInterfaceProcessOptions? options;

  final Process process;

  final Uuid uuid;

  const CommandLineInterfaceProcess(this.process, this.uuid,
      [this.options, this.executableFilePath]);

  static CommandLineInterfaceProcess fromProcess(final Process process,
          {final CommandLineInterfaceProcessOptions? options,
          final String? executableFilePath}) =>
      CommandLineInterfaceProcess(
          process, const Uuid(), options, executableFilePath);
  /**
   * Creates a [CommandLineInterfaceProcess] by invocate a process.
   *
   * - [executablePath]: Path to the executable file,
   *   that should be interfaced for. Make sure the file exists,
   *   [CommandLineInterfaceProcess] doesn't check for.
   *
   *   Either an absolute path or relative to [workingDirectory].
   *
   * - [arguments]: The command line arguments that should be
   *   applied to the command invocation.
   *
   * - [options]: Options for the invocation of the process.
   *
   * - [onStdout] & [onStderr]: Listen for the output of the process.
   */
  static Future<CommandLineInterfaceProcess> createProcess(
      String executablePath, List<String> arguments,
      {final CommandLineInterfaceProcessOptions options =
          const CommandLineInterfaceProcessOptions(),
      final CommandLineInterfaceProcessOutputCallback? onStdout,
      final CommandLineInterfaceProcessOutputCallback? onStderr}) async {
    final Uuid uuid = const Uuid();

    final File processValidateFile =
        File(path.join(path.dirname(executablePath), ".$uuid"));

    if (options.runAsAdministrator) {
      executablePath = Platform.isWindows ? "powershell.exe" : "sudo";
      arguments = Platform.isWindows
          ? [
              "-Command",
              """
              \$targetFolder = "${options.workingDirectory}"
              \$command = "$executablePath"
              \$arguments = "${arguments.join(" ")}"
              
              # Relaunch as administrator
              Start-Process powershell -Verb runAs -wait -ArgumentList @(
                  "-NoProfile",
                  "-ExecutionPolicy Bypass",
                  "-Command `"Set-Location -Path '\$targetFolder'; & '\$command' \$arguments`""
              )
              
              New-Item -ItemType File -Path "${processValidateFile.path}"
              """,
            ]
          : [executablePath] + arguments;
    }
    final Process process = await Process.start(executablePath, arguments,
        workingDirectory: options.workingDirectory,
        environment: const {"stepflow_command_line_interface_process": "1"},
        includeParentEnvironment: true,
        mode: ProcessStartMode.normal,
        runInShell: options.runInShell);

    return CommandLineInterfaceProcess(process, uuid, options, executablePath);
  }

  void kill() {}
}

Future<void> main() async {
  final stepflow.Platform currentPlatform = stepflow.Platform.current();
  final Clang clang = Clang(Executable.environment("clang"));
  await runWorkflow(Chain(steps: [
    clang.analyzeFiles(inputFiles: [], options: ClangStaticAnalysisOptions()),
  ]));

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

  final Clang clang = Clang(Executable.environment("clang"));

  final compileStep = clang.compileFiles(
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
  final analyzeStep = clang.analyzeFiles(
    inputFiles: ["main.cpp"],
    options: const ClangStaticAnalysisOptions(
      outputFormat: ClangAnalysisOutputFormat.html,
    ),
  );
}
