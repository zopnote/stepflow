import 'dart:io';
import 'package:test/test.dart';
import 'package:stepflow/core.dart';
import 'package:stepflow/io.dart';

void main() {
  group('Shell Step', () {
    test('Shell step executes a program and completes in a workflow', () async {
      final isWindows = Platform.isWindows;
      final program = isWindows ? 'cmd' : 'sh';
      final args = isWindows ? ['/c', 'echo', 'test'] : ['-c', 'echo test'];

      final shell = Shell(
        program: program,
        arguments: args,
      );

      final response = await runWorkflow(shell);
      expect(response, isNotNull);
    });

    test('Shell step captures stdout via onStdout', () async {
      final List<int> output = [];
      final isWindows = Platform.isWindows;
      final program = isWindows ? 'cmd' : 'sh';
      final args = isWindows ? ['/c', 'echo', 'Dart'] : ['-c', 'echo Dart'];

      final shell = Shell(
        program: program,
        arguments: args,
        onStdout: (context, data) {
          output.addAll(data);
        },
      );

      await runWorkflow(shell);
      
      expect(output, isNotEmpty);
      expect(String.fromCharCodes(output), contains('Dart'));
    });

    test('Shell step respects workingDirectory', () async {
      final tempDir = Directory.systemTemp.createTempSync('stepflow_test');
      try {
        final testFile = File('${tempDir.path}/test_file.txt');
        testFile.writeAsStringSync('hello');

        // On Windows 'dir', on others 'ls'
        final isWindows = Platform.isWindows;
        final program = isWindows ? 'cmd' : 'ls';
        final args = isWindows ? ['/c', 'dir', 'test_file.txt'] : ['test_file.txt'];

        bool foundFile = false;
        final shell = Shell(
          program: program,
          arguments: args,
          options: ProcessInterfaceOptions(
            workingDirectory: tempDir.path,
            runInShell: isWindows,
          ),
          onStdout: (context, data) {
            if (String.fromCharCodes(data).contains('test_file.txt')) {
              foundFile = true;
            }
          },
        );

        await runWorkflow(shell);
        expect(foundFile, isTrue, reason: 'Should find the test file in the working directory');
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Shell step can be part of a Chain', () async {
      int completedSteps = 0;
      final isWindows = Platform.isWindows;
      final program = isWindows ? 'cmd' : 'sh';
      final args = isWindows ? ['/c', 'echo', 'test'] : ['-c', 'echo test'];

      final workflow = Chain(steps: [
        Runnable((context) {
          completedSteps++;
        }),
        Shell(
          program: program,
          arguments: args,
        ),
        Runnable((context) {
          completedSteps++;
        }),
      ]);

      await runWorkflow(workflow);
      expect(completedSteps, 2);
    });
  });
}
