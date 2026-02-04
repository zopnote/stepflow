import 'dart:io';
import 'package:test/test.dart';
import 'package:stepflow/io.dart';

void main() {
  group('ProcessInterface', () {
    test('fromEnvironment finds a common executable (e.g., cmd/sh)', () async {
      final exe = Platform.isWindows ? 'cmd' : 'sh';
      final process = await ProcessInterface.fromEnvironment(exe, []);
      expect(process, isNotNull);
      expect(process.executableFilePath, contains(exe));
      process.kill();
    });

    test('fromEnvironment throws ApplicationNotFoundException for non-existent app', () {
      expect(
        () => ProcessInterface.fromEnvironment('this_app_should_not_exist_12345', []),
        throwsA(isA<ApplicationNotFoundException>()),
      );
    });

    test('fromFilepath starts a process and waits for exit', () async {
      // Use 'dart' as it's definitely available and in a known location
      final dartExe = Platform.executable;
      final process = await ProcessInterface.fromFilepath(dartExe, ['--version']);
      
      expect(process.isManaged, isTrue);
      final exitCode = await process.waitForExit();
      expect(exitCode, 0);
    });

    test('onStdout callback receives data', () async {
      final dartExe = Platform.executable;
      final List<int> output = [];
      
      final process = await ProcessInterface.fromFilepath(
        dartExe, 
        ['--version'],
        onStdout: (data) => output.addAll(data),
      );
      
      await process.waitForExit();
      expect(output, isNotEmpty);
      // Dart version output is usually on stdout (or stderr sometimes, but --version should be stdout)
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
