
import 'package:stepflow/platform.dart';

class ClangVendor {
  final String value;
  final Iterable<OperatingSystem> systems;
  const ClangVendor(this.value, {this.systems = const []});
  static const ClangVendor pc = ClangVendor(
    "pc",
    systems: [OperatingSystem.linux, OperatingSystem.windows],
  );
  static const ClangVendor apple = ClangVendor(
    "apple",
    systems: [OperatingSystem.ios, OperatingSystem.macos],
  );
  static const ClangVendor linux = ClangVendor(
    "linux",
    systems: [OperatingSystem.android],
  );

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangVendor) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;
}

class ClangEnvironment {
  final String value;
  final Iterable<OperatingSystem> systems;
  const ClangEnvironment(this.value, {this.systems = const []});
  static const ClangEnvironment macho = ClangEnvironment(
    "macho",
    systems: [OperatingSystem.ios, OperatingSystem.macos],
  );
  static const ClangEnvironment elf =
  ClangEnvironment("elf", systems: [OperatingSystem.linux]);
  static const ClangEnvironment android = ClangEnvironment(
    "android",
    systems: [OperatingSystem.android],
  );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangEnvironment) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;
}

class ClangArchitecture {
  final String value;
  final Iterable<Architecture> architectures;
  const ClangArchitecture(this.value, {this.architectures = const []});
  static const ClangArchitecture x86_64 =
  ClangArchitecture("x86_64", architectures: [Architecture.amd64]);
  static const ClangArchitecture i386 =
  ClangArchitecture("i386", architectures: [Architecture.x86]);
  static const ClangArchitecture armv7a =
  ClangArchitecture("armv7a", architectures: [Architecture.arm]);
  static const ClangArchitecture armv8a =
  ClangArchitecture("armv8a", architectures: [Architecture.aarch64]);
  static const ClangArchitecture riscv32 = ClangArchitecture(
    "riscv32",
    architectures: [Architecture.riscv32],
  );
  static const ClangArchitecture riscv64 = ClangArchitecture(
    "riscv64",
    architectures: [Architecture.riscv64],
  );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangArchitecture) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;
}

class ClangABI {
  final String value;
  final Iterable<OperatingSystem> systems;
  const ClangABI(this.value, {this.systems = const []});
  static const ClangABI linux = ClangABI(
    "linux",
    systems: [OperatingSystem.linux],
  );
  static const ClangABI androideabi = ClangABI(
    "androideabi",
    systems: [OperatingSystem.android],
  );
  static const ClangABI msvc = ClangABI(
    "msvc",
    systems: [OperatingSystem.windows],
  );
  static const ClangABI darwin = ClangABI(
    "darwin",
    systems: [OperatingSystem.macos, OperatingSystem.ios],
  );
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (other is! ClangABI) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => value.hashCode;
}

class ClangTarget {
  final ClangVendor vendor;
  final ClangEnvironment environment;
  final ClangArchitecture architecture;
  final ClangABI abi;

  const ClangTarget({
    required this.vendor,
    required this.environment,
    required this.architecture,
    required this.abi,
  });

  String get tripple => "$architecture-$vendor-$abi-$environment";

  @override
  String toString() => tripple;

  static ClangTarget from(Platform platform) {
    const Iterable<ClangArchitecture> architectures = [
      ClangArchitecture.riscv32,
      ClangArchitecture.riscv64,
      ClangArchitecture.armv7a,
      ClangArchitecture.armv8a,
      ClangArchitecture.i386,
      ClangArchitecture.x86_64,
    ];
    const Iterable<ClangVendor> vendors = [
      ClangVendor.linux,
      ClangVendor.apple,
      ClangVendor.pc,
    ];
    const Iterable<ClangEnvironment> environments = [
      ClangEnvironment.android,
      ClangEnvironment.elf,
      ClangEnvironment.macho,
    ];
    const Iterable<ClangABI> abis = [
      ClangABI.androideabi,
      ClangABI.linux,
      ClangABI.darwin,
      ClangABI.msvc,
    ];
    return ClangTarget(
      vendor: vendors.firstWhereOrNull(
            (vendor) => vendor.systems.contains(platform.os),
      ) ??
          const ClangVendor("unknown"),
      environment:
      environments.firstWhereOrNull((env) => env.systems.contains(platform.os)) ??
          const ClangEnvironment("unknown"),
      architecture: architectures.firstWhereOrNull(
            (arch) => arch.architectures.contains(platform.attributes.arch),
      ) ??
          const ClangArchitecture("unknown"),
      abi: abis.firstWhereOrNull((abi) => abi.systems.contains(platform.os)) ??
          const ClangABI("unknown"),
    );
  }
}