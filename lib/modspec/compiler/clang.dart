import 'package:stepflow/cli/program.dart';
import 'package:stepflow/cli/steps/shell.dart';
import 'package:stepflow/common/steps/atomics.dart';
import 'package:stepflow/platform/platform.dart' as stepflow;


class Clang extends Application {
  const Clang(String executable) : super("clang", executable);

  Step analyzeFiles({
    required List<String> inputFiles,
    ClangStaticAnalysisOptions options = const ClangStaticAnalysisOptions(),
  }) {
    final arguments = <String>["--analyze"];

    arguments.addAll(inputFiles);

    if (options.outputFormat != null) {
      arguments.add("-Xanalyzer");
      arguments.add("-analyzer-output=${options.outputFormat!.format}");
    }

    for (final checker in options.enabledCheckers) {
      arguments.add("-Xanalyzer");
      arguments.add("-analyzer-checker=$checker");
    }

    for (final checker in options.disabledCheckers) {
      arguments.add("-Xanalyzer");
      arguments.add("-analyzer-disable-checker=$checker");
    }

    if (options.analyzeHeaders) {
      arguments.add("-Xanalyzer");
      arguments.add("-analyzer-opt-analyze-headers");
    }

    for (final dir in options.includeDirectories) {
      arguments.add("-I$dir");
    }

    for (final macro in options.macros) {
      arguments.add("-D$macro");
    }

    arguments.addAll(options.additionalArguments);

    return Shell(
      name: "Static analysis with Clang",
      program: name,
      arguments: arguments,
    );
  }

  Step compileFiles({
    required List<String> inputFiles,
    required String outputFile,
    required stepflow.Platform targetPlatform,
    Iterable<ClangLibrary> libraries = const [],
    ClangTargetArchitecture? overrideTargetArchitecture,
    ClangCompilationOptions options = const ClangCompilationOptions(),
  }) => ClangCompile();
}

class ClangCompile extends ConfigureStep {
  final String executable;
  const ClangCompile(this.executable);
  @override
  Step configure() {
    final List<String> arguments = [];
    arguments.addAll(inputFiles);
    arguments.add("-o");
    arguments.add(outputFile);

    switch (options.warnings) {
      case ClangShowWarnings.none:
        arguments.add("-w");
        break;
      case ClangShowWarnings.all:
        arguments.add("-Wall");
        break;
      case ClangShowWarnings.extra:
        arguments.add("-Wall");
        arguments.add("-Wextra");
        break;
      case ClangShowWarnings.asError:
        arguments.add("-Werror");
        break;
    }

    if (options.targetArchitecture != null) {
      arguments.add("-march=${options.targetArchitecture!.march}");
    }

    if (options.language != null) {
      arguments.add("-std=${options.language!.standard}");
    }

    arguments.add("-O${options.optimization.level}");

    for (final ClangLibrary library in libraries) {
      arguments.add("-l${library.name}");
      arguments.add("-I${library.include}");
      arguments.add("-L${library.path}");
    }

    if (options.generateDebugInfo) {
      arguments.add("-g");
    }

    for (final macro in options.macros) {
      arguments.add("-D$macro");
    }

    arguments.addAll(options.additionalArguments);

    return Shell(
      name: "Compiling ${inputFiles.join(", ")} with Clang into $outputFile.",
      program: this.name,
      arguments: arguments,
    );
  }
}
enum ClangShowWarnings {
  none("w"),
  all("Wall"),
  extra("Wextra"),
  asError("Werror");

  const ClangShowWarnings(this.flag);
  final String flag;
}

enum ClangOptimization {
  none("0"),
  moderate("1"),
  full("2"),
  aggressive("3"),
  size("s"),
  fast("fast");

  const ClangOptimization(this.level);
  final String level;
}

/**
 * Represents the target architecture for Clang compilation (-march).
 *
 * This class uses static constants to represent common architectures,
 * but allows users to define their own by creating new instances.
 */
class ClangTargetArchitecture {
  /**
   * Optimizes the code for the host machine's CPU.
   */
  static const ClangTargetArchitecture native =
  ClangTargetArchitecture("native");

  /**
   * Generic x86-64 architecture.
   */
  static const ClangTargetArchitecture x86_64 =
  ClangTargetArchitecture("x86-64");

  /**
   * x86-64 with CMPXCHG16B, LAHF-SAHF, POPCNT, SSE3, SSE4.1, SSE4.2, and SSSE3.
   */
  static const ClangTargetArchitecture x86_64_v2 =
  ClangTargetArchitecture("x86-64-v2");

  /**
   * x86-64-v2 with AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, and MOVBE.
   */
  static const ClangTargetArchitecture x86_64_v3 =
  ClangTargetArchitecture("x86-64-v3");

  /**
   * x86-64-v3 with AVX512F, AVX512BW, AVX512CD, AVX512DQ, and AVX512VL.
   */
  static const ClangTargetArchitecture x86_64_v4 =
  ClangTargetArchitecture("x86-64-v4");

  /**
   * Generic ARMv7 architecture.
   */
  static const ClangTargetArchitecture arm_v7 =
  ClangTargetArchitecture("armv7");

  /**
   * ARMv7-A architecture (e.g., Cortex-A series).
   */
  static const ClangTargetArchitecture arm_v7a =
  ClangTargetArchitecture("armv7-a");

  /**
   * ARMv8-A architecture (e.g., Cortex-A53, A57).
   */
  static const ClangTargetArchitecture arm_v8a =
  ClangTargetArchitecture("armv8-a");

  /**
   * ARMv8.1-A architecture.
   */
  static const ClangTargetArchitecture arm_v8_1a =
  ClangTargetArchitecture("armv8.1-a");

  /**
   * ARMv8.2-A architecture.
   */
  static const ClangTargetArchitecture arm_v8_2a =
  ClangTargetArchitecture("armv8.2-a");

  /**
   * ARMv9-A architecture.
   */
  static const ClangTargetArchitecture arm_v9a =
  ClangTargetArchitecture("armv9-a");

  /**
   * Generic 64-bit ARM architecture.
   */
  static const ClangTargetArchitecture aarch64 =
  ClangTargetArchitecture("aarch64");

  /**
   * Intel Skylake (6th Gen Core) architecture.
   */
  static const ClangTargetArchitecture intel_skylake =
  ClangTargetArchitecture("skylake");

  /**
   * Intel Cannon Lake (8th Gen Core) architecture.
   */
  static const ClangTargetArchitecture intel_cannonlake =
  ClangTargetArchitecture("cannonlake");

  /**
   * Intel Ice Lake (Client) architecture.
   */
  static const ClangTargetArchitecture intel_icelake_client =
  ClangTargetArchitecture("icelake-client");

  /**
   * Intel Ice Lake (Server) architecture.
   */
  static const ClangTargetArchitecture intel_icelake_server =
  ClangTargetArchitecture("icelake-server");

  /**
   * Intel Cascade Lake architecture.
   */
  static const ClangTargetArchitecture intel_cascadelake =
  ClangTargetArchitecture("cascadelake");

  /**
   * Intel Cooper Lake architecture.
   */
  static const ClangTargetArchitecture intel_cooperlake =
  ClangTargetArchitecture("cooperlake");

  /**
   * Intel Tiger Lake (11th Gen Core) architecture.
   */
  static const ClangTargetArchitecture intel_tigerlake =
  ClangTargetArchitecture("tigerlake");

  /**
   * Intel Sapphire Rapids architecture.
   */
  static const ClangTargetArchitecture intel_sapphirerapids =
  ClangTargetArchitecture("sapphirerapids");

  /**
   * Intel Alder Lake (12th Gen Core) architecture.
   */
  static const ClangTargetArchitecture intel_alderlake =
  ClangTargetArchitecture("alderlake");

  /**
   * Intel Rocket Lake (11th Gen Core Desktop) architecture.
   */
  static const ClangTargetArchitecture intel_rocketlake =
  ClangTargetArchitecture("rocketlake");

  /**
   * AMD Zen 1 architecture.
   */
  static const ClangTargetArchitecture amd_zen1 =
  ClangTargetArchitecture("znver1");

  /**
   * AMD Zen 2 architecture.
   */
  static const ClangTargetArchitecture amd_zen2 =
  ClangTargetArchitecture("znver2");

  /**
   * AMD Zen 3 architecture.
   */
  static const ClangTargetArchitecture amd_zen3 =
  ClangTargetArchitecture("znver3");

  /**
   * AMD Zen 4 architecture.
   */
  static const ClangTargetArchitecture amd_zen4 =
  ClangTargetArchitecture("znver4");

  /**
   * Apple M1 (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_m1 =
  ClangTargetArchitecture("apple-m1");

  /**
   * Apple M2 (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_m2 =
  ClangTargetArchitecture("apple-m2");

  /**
   * Apple M3 (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_m3 =
  ClangTargetArchitecture("apple-m3");

  /**
   * Apple A14 Bionic (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_a14 =
  ClangTargetArchitecture("apple-a14");

  /**
   * Apple A15 Bionic (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_a15 =
  ClangTargetArchitecture("apple-a15");

  /**
   * Apple A16 Bionic (ARM64) architecture.
   */
  static const ClangTargetArchitecture apple_a16 =
  ClangTargetArchitecture("apple-a16");

  const ClangTargetArchitecture(this.march);
  final String march;
}

class ClangCompilationOptions {
  final ClangTargetArchitecture? targetArchitecture;
  final ClangLanguage? language;
  final ClangOptimization optimization;
  final List<String> libraries;
  final bool generateDebugInfo;
  final List<String> macros;
  final List<String> additionalArguments;
  final ClangShowWarnings warnings;
  final bool legacySupport;

  const ClangCompilationOptions({
    this.targetArchitecture,
    this.language,
    this.warnings = ClangShowWarnings.all,
    this.optimization = ClangOptimization.none,
    this.libraries = const [],
    this.legacySupport = false,
    this.generateDebugInfo = false,
    this.macros = const [],
    this.additionalArguments = const [],
  });
}

enum ClangAnalysisOutputFormat {
  html("html"),
  plist("plist"),
  text("text"),
  sarif("sarif");

  const ClangAnalysisOutputFormat(this.format);
  final String format;
}

final class ClangStaticAnalysisOptions {
  final List<String> enabledCheckers;
  final List<String> disabledCheckers;
  final ClangAnalysisOutputFormat? outputFormat;
  final bool analyzeHeaders;
  final List<String> includeDirectories;
  final List<String> macros;
  final List<String> additionalArguments;

  const ClangStaticAnalysisOptions({
    this.enabledCheckers = const [],
    this.disabledCheckers = const [],
    this.outputFormat,
    this.analyzeHeaders = false,
    this.includeDirectories = const [],
    this.macros = const [],
    this.additionalArguments = const [],
  });
}

class ClangLibrary {
  final String name;
  final String path;
  final String include;
  const ClangLibrary(this.name, this.path, this.include);
}

enum ClangLanguage {
  cxx11("c++", "c++11"),
  cxx14("c++", "c++14"),
  cxx17("c++", "c++17"),
  cxx23("c++", "c++23"),
  c99("c", "c99"),
  c11("c", "c11"),
  c17("c", "c17"),
  c23("c", "c2x");

  const ClangLanguage(this.language, this.standard);
  final String language;
  final String standard;
}