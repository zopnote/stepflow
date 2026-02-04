import 'dart:async';
import 'package:stepflow/cli.dart';
import 'package:stepflow/common.dart';

/**
 * Executes a program in the systems command line.
 */
final class Shell extends ConfigureStep {
  /**
   * Directory where the command line will be started from.
   */
  final String? workingDirectory;

  /**
   * If the program should be ran with elevated privileges.
   */
  final bool? runAsAdministrator;

  /**
   * If the program should be run in the systems command shell.
   */
  final bool? runInShell;

  /**
   * The name of the executable that should be invoked.
   * Can be relative to the [workingDirectory] or available in the systems
   * path variable.
   */
  final String program;

  /**
   * Function that will be executed every time the process' stdout receives text.
   */
  final FutureOr<void> Function(FlowContext context, List<int> chars)? onStdout;

  /**
   * Function that will be executed every time the process' stderr receives text.
   */
  final FutureOr<void> Function(FlowContext context, List<int> chars)? onStderr;

  /**
   * The command line arguments that should be applied to the command invocation.
   */
  final List<String> arguments;

  /**
   * Configuration options for the process invocation.
   */
  final ProcessInterfaceOptions options;

  /**
   * Tag describing whatever this [Shell] does.
   */
  final String? name;

  /**
   * Default const constructor.
   *
   * The default values of [runAsAdministrator] and [runInShell] are [false].
   */
  const Shell({
    @Deprecated("Will be removed in the next major version.") this.name,
    required this.program,
    required this.arguments,
    this.options = const ProcessInterfaceOptions(),
    this.onStdout,
    this.onStderr,
    @Deprecated("Will be removed in the next major version. "
        "Switch over to Shell.options to specify if the program should be run as admin.")
    this.runAsAdministrator,
    @Deprecated("Will be removed in the next major version. "
        "Switch over to Shell.options to specify if the program should be run in shell.")
    this.runInShell,
    @Deprecated("Will be removed in the next major version. "
        "Switch over to Shell.options to specify the working directory.")
    this.workingDirectory,
  });

  @override
  Step configure() => Runnable(name: name, (context) async {
        final ProcessInterface process = await ProcessInterface.fromEnvironment(
            program, arguments,
            options: ProcessInterfaceOptions(
                runAsAdministrator:
                    runAsAdministrator ?? options.runAsAdministrator,
                runInShell: runInShell ?? options.runInShell,
                workingDirectory: workingDirectory ?? options.workingDirectory),
            onStdout: (c) => onStdout?.call(context, c),
            onStderr: (c) => onStderr?.call(context, c));
        await process.waitForExit();
      });
}
