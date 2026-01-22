import 'package:test/test.dart';
import 'package:stepflow/platform/platform.dart' as _;
import 'package:stepflow/modspec/compiler/clang.dart';

void main() {
  group('Clang Target Triple Generation', () {
    test('Windows x64', () {
      final platform = _.Platform.windows(
        architecture: _.WindowsArchitecture.x64,
        buildVersion: _.WindowsBuildVersion(19041, _.Version(10, 0, 0)),
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('x86_64-pc-windows-msvc'));
    });

    test('Linux ARM (gnueabihf)', () {
      final platform = _.Platform.linux(
        architecture: _.LinuxArchitecture.arm,
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('arm-pc-linux-gnueabihf'));
    });

    test('Linux x86_64 (gnu)', () {
      final platform = _.Platform.linux(
        architecture: _.LinuxArchitecture.x86_64,
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('x86_64-pc-linux-gnu'));
    });

    test('macOS Apple Silicon', () {
      final platform = _.Platform.macos(
        processor: _.MacOSProcessor.applesilicon,
        sdkVersion: _.Version(11, 0, 0),
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('aarch64-apple-macos-darwin'));
    });

    test('Android arm64-v8a', () {
      final platform = _.Platform.android(
        apiLevel: _.AndroidAPI.tiramisu,
        abi: _.AndroidABI.arm64_v8a,
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('aarch64-linux-android-android'));
    });

    test('Baremetal RISC-V 32', () {
      final platform = _.Platform.bareMetal(
        architecture: _.Architecture.riscv32,
      );
      expect(ClangCompile.getTargetTriple(targetPlatform: platform), 
             equals('riscv32-unknown-none-eabi'));
    });
  });
}
