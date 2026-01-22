import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as _path;
import 'package:stepflow/common.dart';
import 'package:stepflow/cli/steps/shell.dart' show Shell;
import 'package:stepflow/platform/platform.dart' as stepflow;
import 'package:uuid/uuid.dart';

import '../modspec/compiler/clang.dart';

final List<String> _pathEntries =
    Platform.environment["PATH"]?.split(Platform.isWindows ? ";" : ":") ?? [];

class ApplicationNotFoundException implements Exception {
  final String applicationName;
  late final String cause;
  ApplicationNotFoundException(this.applicationName)
      : cause = "Couldn't find the application $applicationName.";
}

class ExecutionOptions {
  /**
   * If the program should be ran with elevated privileges.
   */
  final bool runAsAdministrator;

  /**
   * If the program should be run in the systems command shell.
   */
  final bool runInShell;

  const ExecutionOptions(
      {this.runAsAdministrator = false, this.runInShell = false});
}

class ExecutionResult {}

typedef ExecutionStdout = FutureOr<void> Function(List<int> chars);
typedef ExecutionCallback = FutureOr<ExecutionResult> Function(
    List<String> arguments,
    [ExecutionOptions? options,
    ExecutionStdout? onStdout,
    ExecutionStdout? onStderr]);

class Executable {
  /**
   * UUID of the executable for exact representation.
   */
  final Uuid uuid = const Uuid();

  final ExecutionCallback execute;

  const Executable(this.execute);

  static Executable environment(String name) {
    final File? executable = _pathEntries
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
    return file(executable, true);
  }

  /**
   * Returns formatted arguments.
   *
   * On windows the powershell is required to acquire elevated privileges.
   */
  static List<String> _createCLIExecutionArguments(
      final bool runAsAdministrator,
      final String processFilePath,
      final String program,
      final List<String> arguments,
      final String workingDirectory) {
    if (runAsAdministrator) {
      return Platform.isWindows
          ? [
              "-Command",
              """
              # Set variables
              \$targetFolder = "${workingDirectory ?? "./"}"
              \$command = "$program"
              \$arguments = "${arguments.join(" ")}"
              
              # Relaunch as administrator
              Start-Process powershell -Verb runAs -wait -ArgumentList @(
                  "-NoProfile",
                  "-ExecutionPolicy Bypass",
                  "-Command `"Set-Location -Path '\$targetFolder'; & '\$command' \$arguments`""
              )
              
              New-Item -ItemType File -Path "${processFilePath}"
              """,
            ]
          : [program] + arguments;
    }
    return arguments;
  }

  /**
   * It is necessary to detect the creation of a placeholder
   * file, to wait for the Powershell process to finish.
   */
  static Future<void> _windowsWaitForPowershell(final String processFilePath) {
    final Completer completer = Completer();
    late final void Function() check;
    check = () {
      if (File(processFilePath).existsSync()) {
        File(processFilePath).deleteSync();
        completer.complete();
      }
      Timer(const Duration(seconds: 1), check);
    };
    check();
    return completer.future;
  }

  /**
   * Receives the command's first argument. (The program's name)
   */
  static String _createCLIProgram(
      final bool runAsAdministrator, final String fallback) {
    if (runAsAdministrator) {
      return Platform.isWindows ? "powershell.exe" : "sudo";
    }
    return fallback;
  }

  /**
   * Returns the composed process that will be started.
   */
  Future<Process> _createCLIProcess(
          final bool runAsAdministrator,
          final String processFilePath,
          final String workingDirectory,
          final String program,
          final List<String> arguments,
          final bool runInShell) =>
      Process.start(
        _createCLIProgram(runAsAdministrator, program),
        _createCLIExecutionArguments(runAsAdministrator, processFilePath,
            program, arguments, workingDirectory),
        workingDirectory: workingDirectory,
        environment: {},
        includeParentEnvironment: true,
        mode: ProcessStartMode.normal,
        runInShell: runInShell,
      );
  static Executable file(File file, [bool skipCheck = false]) {
    if (!skipCheck && !file.existsSync()) {
      throw FileSystemException(
          "File \"${file.path}\" can't be found. Ensure it's availability to proceed.");
    }
    return Executable((arguments, [options, stdout, stderr]) async {
      final process = await _createCLIProcess();
      /*
     * We have to await both futures at once with the list.
     */
      final List<Future<void>> futures = [];
      process.stdout.listen((chars) {
        if (stdout != null) {
          futures.add(Future.value(stdout(chars)));
        }
      });
      /*
     * A full string is built for the response.
     */
      String fullStderr = "";
      process.stderr.listen((chars) {
        if (stderr != null) {
          futures.add(Future.value(stderr(chars)));
        }
        fullStderr += "\n${String.fromCharCodes(chars)}";
      });

      /*
     * Await the process to be completed.
     * Then awaits only the futures (The actions of the stdout & stderr are already done).
     */
      await process.exitCode;
      await Future.wait(futures);

      if (runAsAdministrator && Platform.isWindows) {
        await _windowsWaitForPowershell();
      }
      context.send(
        Response(
          fullStderr.isNotEmpty
              ? "An error occurred in the process: $fullStderr"
              : "Shell step executed without any issues.",
          Level.verbose,
        ),
      );
      return ExecutionResult();
    });
  }
}

abstract class Application {
  final String name;
  final Executable executable;
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
