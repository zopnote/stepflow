import 'dart:io' show File, Directory;

import 'package:path/path.dart' as path;

import 'package:stepflow/io.dart';
import 'package:stepflow/core.dart';
import 'package:stepflow/platform.dart';

class ClangCompileTargetVendor {
  final String value;
  final Iterable<OperatingSystem> mapping;
  const ClangCompileTargetVendor(this.value, {this.mapping = const []});
  static const ClangCompileTargetVendor pc = ClangCompileTargetVendor(
    "pc",
    mapping: [OperatingSystem.linux, OperatingSystem.windows],
  );
  static const ClangCompileTargetVendor apple = ClangCompileTargetVendor(
    "apple",
    mapping: [OperatingSystem.ios, OperatingSystem.macos],
  );
  static const ClangCompileTargetVendor linux = ClangCompileTargetVendor(
    "linux",
    mapping: [OperatingSystem.android],
  );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangCompileTargetVendor) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;

}

class ClangCompileTargetEnvironment {
  final String value;
  final Iterable<OperatingSystem> mapping;
  const ClangCompileTargetEnvironment(this.value, {this.mapping = const []});
  static const ClangCompileTargetEnvironment macho =
      ClangCompileTargetEnvironment(
        "macho",
        mapping: [OperatingSystem.ios, OperatingSystem.macos],
      );
  static const ClangCompileTargetEnvironment elf =
      ClangCompileTargetEnvironment("elf", mapping: [OperatingSystem.linux]);
  static const ClangCompileTargetEnvironment android =
      ClangCompileTargetEnvironment(
        "android",
        mapping: [OperatingSystem.android],
      );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangCompileTargetEnvironment) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;

}

class ClangCompileTargetArchitecture {
  final String value;
  final Iterable<Architecture> mapping;
  const ClangCompileTargetArchitecture(this.value, {this.mapping = const []});
  static const ClangCompileTargetArchitecture x86_64 =
      ClangCompileTargetArchitecture("x86_64", mapping: [Architecture.amd64]);
  static const ClangCompileTargetArchitecture i386 =
      ClangCompileTargetArchitecture("i386", mapping: [Architecture.x86]);
  static const ClangCompileTargetArchitecture armv7a =
      ClangCompileTargetArchitecture("armv7a", mapping: [Architecture.arm]);
  static const ClangCompileTargetArchitecture armv8a =
      ClangCompileTargetArchitecture("armv8a", mapping: [Architecture.aarch64]);
  static const ClangCompileTargetArchitecture riscv32 =
      ClangCompileTargetArchitecture(
        "riscv32",
        mapping: [Architecture.riscv32],
      );
  static const ClangCompileTargetArchitecture riscv64 =
      ClangCompileTargetArchitecture(
        "riscv64",
        mapping: [Architecture.riscv64],
      );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangCompileTargetArchitecture) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;

}

class ClangCompileTargetABI {
  final String value;
  final Iterable<OperatingSystem> mapping;
  const ClangCompileTargetABI(this.value, {this.mapping = const []});
  static const ClangCompileTargetABI linux = ClangCompileTargetABI(
    "linux",
    mapping: [OperatingSystem.linux],
  );
  static const ClangCompileTargetABI androideabi = ClangCompileTargetABI(
    "androideabi",
    mapping: [OperatingSystem.android],
  );
  static const ClangCompileTargetABI msvc = ClangCompileTargetABI(
    "msvc",
    mapping: [OperatingSystem.windows],
  );
  static const ClangCompileTargetABI darwin = ClangCompileTargetABI(
    "darwin",
    mapping: [OperatingSystem.macos, OperatingSystem.ios],
  );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangCompileTargetABI) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;

}

class ClangCompileTarget {
  final ClangCompileTargetVendor vendor;
  final ClangCompileTargetEnvironment environment;
  final ClangCompileTargetArchitecture architecture;
  final ClangCompileTargetABI abi;

  const ClangCompileTarget({
    required this.vendor,
    required this.environment,
    required this.architecture,
    required this.abi,
  });

  String get tripple => "$architecture-$vendor-$abi-$environment";

  static ClangCompileTarget from(Platform platform) {
    const Iterable<ClangCompileTargetArchitecture> archs = [
      ClangCompileTargetArchitecture.riscv32,
      ClangCompileTargetArchitecture.riscv64,
      ClangCompileTargetArchitecture.armv7a,
      ClangCompileTargetArchitecture.armv8a,
      ClangCompileTargetArchitecture.i386,
      ClangCompileTargetArchitecture.x86_64,
    ];
    const Iterable<ClangCompileTargetVendor> vens = [
      ClangCompileTargetVendor.linux,
      ClangCompileTargetVendor.apple,
      ClangCompileTargetVendor.pc,
    ];
    const Iterable<ClangCompileTargetEnvironment> envs = [
      ClangCompileTargetEnvironment.android,
      ClangCompileTargetEnvironment.elf,
      ClangCompileTargetEnvironment.macho,
    ];
    const Iterable<ClangCompileTargetABI> abis = [
      ClangCompileTargetABI.androideabi,
      ClangCompileTargetABI.linux,
      ClangCompileTargetABI.darwin,
      ClangCompileTargetABI.msvc,
    ];
    return ClangCompileTarget(
      vendor:
          vens.firstWhereOrNull(
            (vendor) => vendor.mapping.contains(platform.os),
          ) ??
          const ClangCompileTargetVendor("unknown"),
      environment:
          envs.firstWhereOrNull((env) => env.mapping.contains(platform.os)) ??
          const ClangCompileTargetEnvironment("unknown"),
      architecture:
          archs.firstWhereOrNull(
            (arch) => arch.mapping.contains(platform.attributes.arch),
          ) ??
          const ClangCompileTargetArchitecture("unknown"),
      abi:
          abis.firstWhereOrNull((abi) => abi.mapping.contains(platform.os)) ??
          const ClangCompileTargetABI("unknown"),
    );
  }
}

class ClangCompiler {
  final String _name;
  const ClangCompiler(this._name);

  Step compile({
    required final List<File> input,
    required final File output,
    final List<NativeLibrary> libraries = const [],
    final Map<String, String> macros = const {},
    ClangCompileTarget? target,
    final ClangLanguage? language,
    final bool generateDebugInfo = false,
    final ClangTargetProcessor? targetProcessor,
    final ClangOptimization optimization = ClangOptimization.moderate,
    final ClangReportSettings reportSettings = const ClangReportSettings(),
    final ClangBuildType buildType = ClangBuildType.executable,
  }) {
    target ??= ClangCompileTarget.from(Platform.current());
    final List<String> arguments = [];
    arguments.add("-O${optimization.value}");
    arguments.add("-${reportSettings.warningLevel.flag}");
    if (generateDebugInfo) {
      arguments.add("-g");
    }
    for (final NativeLibrary library in libraries) {
      arguments.add("-l${library.binary}");
      arguments.add("-I${library.header}");
      arguments.add("-L${path.dirname(library.binary.path)}");
    }
    for (final macro in macros) {
      arguments.add("-D$macro");
    }
    if (reportSettings.analyzeLanguageExtensionsAsErrors) {
      arguments.add("-pedantic-errors");
    } else if (reportSettings.analyzeLanguageExtensions) {
      arguments.add("pedantic");
    }
    if (reportSettings.analyzeSystemHeader) {
      arguments.add("-Wsystem-header");
    }
    if (language != null) {
      arguments.add("-std=${language.standard}");
    }
    arguments.add("-ferror-limit=${reportSettings.messageLimit}");
    if (reportSettings.cxxTemplateBacktraceLimit != null) {
      arguments.add("-ftemplate-backtrace-limit=${reportSettings.cxxTemplateBacktraceLimit}");
    }
    for (String name in reportSettings.disableWarningsPerName) {
      arguments.add("-Wno-$name");
    }
    for (String name in reportSettings.enableWarningsPerName) {
      arguments.add("-W$name");
    }
    for (String name in reportSettings.excludeWarningsAsErrorsPerName) {
      arguments.add("-Wno-error=$name");
    }
    for (String name in reportSettings.warningsAsErrorsPerName) {
      arguments.add("-Werror=$name");
    }
    arguments.add(target.tripple);
    if (targetProcessor != null) {
      arguments.add("-march=${targetProcessor.march}");
      arguments.add("-mcpu=${targetProcessor.mcpu}");
    }

    return Shell(program: _name, arguments: arguments);
  }
}


/// Represents the target architecture and processor for Clang compilation (-march, -mcpu).
///
/// This class uses static constants to represent common architectures,
/// but allows users to define their own by creating new instances.
class ClangTargetProcessor {
  /// Optimizes the code for the host machine's CPU.
  static const ClangTargetProcessor native =
  ClangTargetProcessor("native", "native");

  /// Generic x86-64 architecture.
  static const ClangTargetProcessor x86_64 =
  ClangTargetProcessor("x86-64", "x86-64");

  /// x86-64 with CMPXCHG16B, LAHF-SAHF, POPCNT, SSE3, SSE4.1, SSE4.2, and SSSE3.
  static const ClangTargetProcessor x86_64v2 =
  ClangTargetProcessor("x86-64-v2", "x86-64");

  /// x86-64-v2 with AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, and MOVBE.
  static const ClangTargetProcessor x86_64v3 =
  ClangTargetProcessor("x86-64-v3", "x86-64");

  /// x86-64-v3 with AVX512F, AVX512BW, AVX512CD, AVX512DQ, and AVX512VL.
  static const ClangTargetProcessor x86_64v4 =
  ClangTargetProcessor("x86-64-v4", "x86-64");

  /// Generic ARMv7 architecture.
  static const ClangTargetProcessor armv7 =
  ClangTargetProcessor("armv7", "generic");

  /// ARMv7-A architecture (e.g., Cortex-A series).
  static const ClangTargetProcessor armv7a =
  ClangTargetProcessor("armv7-a", "generic");

  static const ClangTargetProcessor cortexA15 =
  ClangTargetProcessor("armv7-a", "cortex-a15");

  static const ClangTargetProcessor cortexA76 =
  ClangTargetProcessor("armv8.2-a", "cortex-a76");

  static const ClangTargetProcessor cortexX2 =
  ClangTargetProcessor("armv9-a", "cortex-x2");

  /// ARMv8-A architecture (e.g., Cortex-A53, A57).
  static const ClangTargetProcessor armv8a =
  ClangTargetProcessor("armv8-a", "generic");

  /// ARMv8.1-A architecture.
  static const ClangTargetProcessor armv81a =
  ClangTargetProcessor("armv8.1-a", "generic");

  /// ARMv8.2-A architecture.
  static const ClangTargetProcessor armv82a =
  ClangTargetProcessor("armv8.2-a", "generic");

  /// ARMv9-A architecture.
  static const ClangTargetProcessor armv9a =
  ClangTargetProcessor("armv9-a", "generic");

  /// Generic 64-bit ARM architecture.
  static const ClangTargetProcessor aarch64 =
  ClangTargetProcessor("aarch64", "generic");

  /// Intel Skylake (6th Gen Core) architecture.
  static const ClangTargetProcessor intelSkylake =
  ClangTargetProcessor("skylake", "skylake");

  /// Intel Cannon Lake (8th Gen Core) architecture.
  static const ClangTargetProcessor intelCannonlake =
  ClangTargetProcessor("cannonlake", "cannonlake");

  /// Intel Ice Lake (Client) architecture.
  static const ClangTargetProcessor intelIcelakeClient =
  ClangTargetProcessor("icelake-client", "icelake-client");

  /// Intel Ice Lake (Server) architecture.
  static const ClangTargetProcessor intelIcelakeServer =
  ClangTargetProcessor("icelake-server", "icelake-server");

  /// Intel Cascade Lake architecture.
  static const ClangTargetProcessor intelCascadelake =
  ClangTargetProcessor("cascadelake", "cascadelake");

  /// Intel Cooper Lake architecture.
  static const ClangTargetProcessor intelCooperlake =
  ClangTargetProcessor("cooperlake", "cooperlake");

  /// Intel Tiger Lake (11th Gen Core) architecture.
  static const ClangTargetProcessor intelTigerlake =
  ClangTargetProcessor("tigerlake", "tigerlake");

  /// Intel Sapphire Rapids architecture.
  static const ClangTargetProcessor intelSapphirerapids =
  ClangTargetProcessor("sapphirerapids", "sapphirerapids");

  /// Intel Alder Lake (12th Gen Core) architecture.
  static const ClangTargetProcessor intelAlderlake =
  ClangTargetProcessor("alderlake", "alderlake");

  /// Intel Rocket Lake (11th Gen Core Desktop) architecture.
  static const ClangTargetProcessor intelRocketlake =
  ClangTargetProcessor("rocketlake", "rocketlake");

  /// AMD Zen 1 architecture.
  static const ClangTargetProcessor amdZen1 =
  ClangTargetProcessor("znver1", "znver1");

  /// AMD Zen 2 architecture.
  static const ClangTargetProcessor amdZen2 =
  ClangTargetProcessor("znver2", "znver2");

  /// AMD Zen 3 architecture.
  static const ClangTargetProcessor amdZen3 =
  ClangTargetProcessor("znver3", "znver3");

  /// AMD Zen 4 architecture.
  static const ClangTargetProcessor amdZen4 =
  ClangTargetProcessor("znver4", "znver4");

  /// Apple M1 (ARM64) architecture.
  static const ClangTargetProcessor appleM1 =
  ClangTargetProcessor("apple-m1", "apple-m1");

  /// Apple M2 (ARM64) architecture.
  static const ClangTargetProcessor appleM2 =
  ClangTargetProcessor("apple-m2", "apple-m2");

  /// Apple M3 (ARM64) architecture.
  static const ClangTargetProcessor appleM3 =
  ClangTargetProcessor("apple-m3", "apple-m3");

  /// Apple M4 (ARM64) architecture.
  static const ClangTargetProcessor appleM4 =
  ClangTargetProcessor("apple-m4", "apple-m4");

  /// Apple M5 (ARM64) architecture.
  static const ClangTargetProcessor appleM5 =
  ClangTargetProcessor("apple-m5", "apple-m5");

  /// Apple A14 Bionic (ARM64) architecture.
  static const ClangTargetProcessor appleA14 =
  ClangTargetProcessor("apple-a14", "apple-a14");

  /// Apple A15 Bionic (ARM64) architecture.
  static const ClangTargetProcessor appleA15 =
  ClangTargetProcessor("apple-a15", "apple-a15");

  /// Apple A16 Bionic (ARM64) architecture.
  static const ClangTargetProcessor appleA16 =
  ClangTargetProcessor("apple-a16", "apple-a16");

  /// Apple A17 Bionic (ARM64) architecture.
  static const ClangTargetProcessor appleA17 =
  ClangTargetProcessor("apple-a17", "apple-a17");

  /// Apple A18 Bionic (ARM64) architecture.
  static const ClangTargetProcessor appleA18 =
  ClangTargetProcessor("apple-a18", "apple-a18");

  const ClangTargetProcessor(this.march, this.mcpu);
  final String march;
  final String mcpu;
}


/// Windows:
/// - Static library
/// - Shared library
///
/// Linux:
/// - Static library
/// - Shared library
///
/// macOS:
/// - Dynamic library
/// - Static library
enum ClangBuildType { executable, static, shared }

class ClangOptimization {
  final String value;
  const ClangOptimization(this.value);
  static const ClangOptimization tiny = ClangOptimization("s");
  static const ClangOptimization aggressive = ClangOptimization("fast");
  static const ClangOptimization high = ClangOptimization("3");
  static const ClangOptimization moderate = ClangOptimization("2");
  static const ClangOptimization low = ClangOptimization("1");
  static const ClangOptimization none = ClangOptimization("0");

  @override
  bool operator ==(Object other) {
    if (other is! ClangOptimization) {
      return false;
    }
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class ClangReportSettings {
  final ClangWarningLevel warningLevel;
  final int messageLimit;
  final int? cxxTemplateBacktraceLimit;
  final bool analyzeLanguageExtensions;
  final bool analyzeSystemHeader;

  /// Turns the warnings into errors.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> warningsAsErrorsPerName;

  /// Turns warnings into warnings even if ``ClangWarningLevel.uncompromising`` is specified.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> excludeWarningsAsErrorsPerName;

  /// Enables the warnings per name.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> enableWarningsPerName;

  /// Disables the warnings per name.
  ///
  /// List of all warnings in the clang documentation under [here](https://clang.llvm.org/docs/DiagnosticsReference.html).
  final List<String> disableWarningsPerName;

  const ClangReportSettings({
    this.warningLevel = ClangWarningLevel.normal,
    this.messageLimit = 0,
    this.analyzeLanguageExtensions = false,
    this.analyzeSystemHeader = false,
    this.cxxTemplateBacktraceLimit,
    this.warningsAsErrorsPerName = const [],
    this.excludeWarningsAsErrorsPerName = const [],
    this.enableWarningsPerName = const [],
    this.disableWarningsPerName = const [],
  });

  bool get analyzeLanguageExtensionsAsErrors {
    if (warningLevel != ClangWarningLevel.uncompromising) {
      return false;
    }
    return analyzeLanguageExtensions;
  }
}

void main() {
  ClangCompiler("").compile(
    input: [],
    output: File(""),
    language: ClangLanguage.c23,
    buildType: ClangBuildType.executable,
    macros: [
      "SYSTEMD"
    ],
    libraries: [
      NativeLibrary(header: header, binary: binary)
    ],
    target: ClangCompileTarget.from(Platform.current()),
  );
}

class ClangWarningLevel {
  final String flag;
  const ClangWarningLevel(this.flag);
  static const ClangWarningLevel none = ClangWarningLevel("w");
  static const ClangWarningLevel normal = ClangWarningLevel("");
  static const ClangWarningLevel all = ClangWarningLevel("Weverything");
  static const ClangWarningLevel uncompromising = ClangWarningLevel("Werror");
}

class NativeLibrary {
  final File binary;
  final Directory header;
  const NativeLibrary({required this.header, required this.binary});
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
