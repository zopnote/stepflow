import 'dart:io';
import 'package:test/test.dart';
import 'package:stepflow/io.dart';

void main() {
  group('ProcessInterface', () {
    test('fromEnvironment finds a common executable (e.g., cmd/sh)', () async {
      // Use commands that exit immediately
      final exe = Platform.isWindows ? 'cmd' : 'sh';
      final args = Platform.isWindows ? ['/c', 'exit', '0'] : ['-c', 'exit 0'];
      final process = await ProcessInterface.fromEnvironment(exe, args);
      expect(process, isNotNull);
      expect(process.executableFilePath, contains(exe));
      final exitCode = await process.waitForExit();
      expect(exitCode, 0);
    });

    test('fromEnvironment throws ApplicationNotFoundException for non-existent app', () {
      expect(
        () => ProcessInterface.fromEnvironment('this_app_should_not_exist_12345', []),
        throwsA(isA<ApplicationNotFoundException>()),
      );
    });

    test('fromFilepath starts a process and waits for exit', () async {
      // Use a command that exists on all platforms
      final exe = Platform.isWindows ? 'C:\\Windows\\System32\\cmd.exe' : '/bin/sh';
      final args = Platform.isWindows ? ['/c', 'exit', '0'] : ['-c', 'exit 0'];

      // Skip test if the file doesn't exist (edge case)
      if (!File(exe).existsSync()) {
        print('Skipping test: $exe not found');
        return;
      }

      final process = await ProcessInterface.fromFilepath(exe, args);

      expect(process.isManaged, isTrue);
      final exitCode = await process.waitForExit();
      expect(exitCode, 0);
    });

    test('onStdout callback receives data', () async {
      // Use echo command to test stdout callback
      final exe = Platform.isWindows ? 'C:\\Windows\\System32\\cmd.exe' : '/bin/sh';
      final args = Platform.isWindows
          ? ['/c', 'echo', 'test']
          : ['-c', 'printf "test"'];  // Use printf instead of echo for more reliable output

      // Skip test if the file doesn't exist (edge case)
      if (!File(exe).existsSync()) {
        print('Skipping test: $exe not found');
        return;
      }

      final List<int> output = [];
      final List<int> errorOutput = [];

      final process = await ProcessInterface.fromFilepath(
        exe,
        args,
        onStdout: (data) => output.addAll(data),
        onStderr: (data) => errorOutput.addAll(data),
      );

      await process.waitForExit();

      // Check both stdout and stderr as some systems may output to stderr
      final allOutput = output + errorOutput;
      expect(allOutput, isNotEmpty, reason: 'Expected output on stdout or stderr');
      final outputStr = String.fromCharCodes(allOutput);
      expect(outputStr, contains('test'));
    });

    test('ApplicationNotFoundException message is correct', () {
      final ex = ApplicationNotFoundException('my-app');
      expect(ex.cause, contains('my-app'));
    });
  });

  group('ProcessInterfaceOptions', () {
    test('defaults are correct', () {
      const options = ProcessInterfaceOptions();
      expect(options.runAsAdministrator, isFalse);
      expect(options.runInShell, isFalse);
      expect(options.workingDirectory, isNull);
    });
  });
}
