import 'package:stepflow/platform.dart';

enum LinuxArchitecture {
  aarch64(Architecture.aarch64),
  arm(Architecture.arm),
  x86(Architecture.x86),
  x86_64(Architecture.amd64),
  riscv(Architecture.riscv32),
  riscv64(Architecture.riscv64);

  const LinuxArchitecture(this.arch);
  final Architecture arch;
}

/** Base attributes for a Linux platform.
 *
 * Includes the [architecture] of the platform and a default [name].
 * Distribution-specific subclasses can extend this class to include
 * additional metadata such as version numbers.
 */
class LinuxAttributes extends PlatformAttributes {
  const LinuxAttributes({
    required this.architecture,
    String name = "linux",
    this.version = const Version(0, 0, 0),
  }) : super(name, version);
  final LinuxArchitecture architecture;
  final Version version;
  @override
  Architecture get arch => architecture.arch;
}

class UbuntuAttributes extends LinuxAttributes {
  const UbuntuAttributes({required super.architecture, required super.version})
    : super(name: "ubuntu");
}

class FedoraAttributes extends LinuxAttributes {
  const FedoraAttributes({required super.architecture, required super.version})
    : super(name: "fedora");
}

class ArchAttributes extends LinuxAttributes {
  const ArchAttributes({required super.architecture, required super.version})
    : super(name: "arch");
}

class DebianAttributes extends LinuxAttributes {
  const DebianAttributes({required super.architecture, required super.version})
    : super(name: "debian");
}
