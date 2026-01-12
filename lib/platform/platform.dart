import 'dart:io' as io show Platform;

import 'attributes/baremetal.dart';
import 'attributes/ios.dart';
import 'attributes/macos.dart';
import 'attributes/android.dart';
import 'attributes/linux.dart';
import 'attributes/windows.dart';

export 'attributes/baremetal.dart';
export 'attributes/ios.dart';
export 'attributes/macos.dart';
export 'attributes/android.dart';
export 'attributes/linux.dart';
export 'attributes/windows.dart';


extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/**
 * Represents a software version using semantic versioning,
 * which is a widely adopted versioning format.
 *
 * - **Major** version (first number): Incremented for incompatible API changes
 *   or major rewrites. Users should expect breaking changes.
 * - **Minor** version (second number): Incremented for new features that
 *   are backward-compatible. Existing functionality remains valid.
 * - **Patch** version (third number): Incremented for bug fixes or
 *   small improvements that do not add new features or break compatibility.
 */
class Version {
  final int major;

  final int minor;

  /**
   * The patch version number (also called revision or bugfix level).
   */
  final int patch;

  const Version(this.major, this.minor, this.patch);

  /**
   * Parses a version string into a [Version] instance.
   * Expects a format like "major.minor.patch" or "major.minor".
   * If patch is missing, it defaults to 0.
   */
  static Version parse(String versionString) {
    final segments =
        versionString.split(RegExp(r'\D')).where((s) => s.isNotEmpty).toList();
    final major = segments.length > 0 ? int.tryParse(segments[0]) ?? 0 : 0;
    final minor = segments.length > 1 ? int.tryParse(segments[1]) ?? 0 : 0;
    final patch = segments.length > 2 ? int.tryParse(segments[2]) ?? 0 : 0;
    return Version(major, minor, patch);
  }
}

/**
 * Superordinate architectures across platform representation.
 *
 * Used in conjunction with [Platform] to define the hardware
 * on which a build, deployment, or runtime environment will run.
 */
enum Architecture {
  /// 64-bit x86 (Intel/AMD)
  amd64,

  /// 32-bit x86 (Intel/AMD)
  x86,

  /// 64-bit ARM (AArch64)
  aarch64,

  /// 32-bit ARM
  arm,

  /// 32-bit RISC-V
  riscv32,

  /// 64-bit RISC-V
  riscv64,
}

/**
 * Represents the operating system of a target platform.
 *
 * Used with [Platform] to define the software environment
 * for which a build or deployment is intended.
 */
enum OperatingSystem {
  /// Microsoft Windows (desktop, server), regardless of version.
  windows,

  /// Linux (desktop, server, embedded distributions), regardless of version and distribution.
  linux,

  /// Apple macOS (desktop/laptop)
  macos,

  /// Apple iOS (iPhone/iPad)
  ios,

  /// Google Android (phones, tablets, embedded devices)
  android,
  /**
   * No operating system (bare-metal targets)
   *
   * Used for microcontrollers, firmware, or single-board computers
   * without a full OS, that provides os abi.
   */
  none,

  /// Generic operating system without further description.
  generic,
}

/**
 * Metadata base [class] for type-safe access to platform
 * specific attributes.
 */
abstract class PlatformAttributes {
  final String name;
  final Version version;
  const PlatformAttributes(this.name, this.version);
}

/**
 * Represents a target platform for a build, deployment, or runtime environment.
 *
 * The [Platform] class encapsulates both the operating system and
 * platform-specific attributes, allowing type-safe access to OS-specific
 * configuration such as architecture, distribution, API level, or processor.
 *
 * This class is generic over [Attributes], which must extend [PlatformAttributes].
 * This ensures that each platform instance carries the appropriate
 * metadata for the target operating system.
 */
class Platform<Attributes extends PlatformAttributes> {
  /**
   * Creates a platform instance with the given [os] and platform-specific [attributes].
   */
  const Platform({required this.os, required this.attributes});

  /**
   * The operating system of this platform.
   */
  final OperatingSystem os;

  /**
   * Platform-specific attributes, e.g., architecture, distribution, ABI, or processor.
   */
  final Attributes attributes;

  /**
   * Returns a representation of the current dart virtual machine platform abi.
   */
  static Platform current() {
    final String architectureName =
        io.Platform.version.split("\"")[1].split("_")[0];

    if (io.Platform.isWindows) {
      final WindowsArchitecture architecture = switch (architectureName) {
        "x64" => WindowsArchitecture.x64,
        "ia32" => WindowsArchitecture.x86,
        "arm" => WindowsArchitecture.ARM,
        "arm64" => WindowsArchitecture.ARM64,
        _ => WindowsArchitecture.x64,
      };

      final String osVersionString = io.Platform.operatingSystemVersion.split("\"").last;
      final RegExpMatch? buildMatch = RegExp(r'Build (\d+)')
          .firstMatch(osVersionString);
      final int buildNumber =
          buildMatch != null ? int.tryParse(buildMatch.group(1)!) ?? 0 : 0;
      final version = Version.parse(osVersionString);

      return Platform.windows(
        architecture: architecture,
        buildVersion: WindowsBuildVersion(buildNumber, version),
      );
    }

    if (io.Platform.isLinux) {
      final LinuxArchitecture architecture = switch (architectureName) {
        "x64" => LinuxArchitecture.x86_64,
        "ia32" => LinuxArchitecture.x86,
        "arm" => LinuxArchitecture.arm,
        "arm64" => LinuxArchitecture.aarch64,
        "riscv" => LinuxArchitecture.riscv,
        "riscv64" => LinuxArchitecture.riscv64,
        _ => LinuxArchitecture.x86_64,
      };

      return Platform.linux(architecture: architecture);
    }

    if (io.Platform.isMacOS) {
      final MacOSProcessor processor = switch (architectureName) {
        "x64" => MacOSProcessor.intel,
        "arm64" => MacOSProcessor.applesilicon,
        _ => MacOSProcessor.intel,
      };

      return Platform.macos(
        processor: processor,
        sdkVersion: Version.parse(io.Platform.operatingSystemVersion),
      );
    }

    if (io.Platform.isAndroid) {
      final AndroidABI abi = switch (architectureName) {
        "x64" => AndroidABI.x86_64,
        "ia32" => AndroidABI.x86,
        "arm" => AndroidABI.armeabi_v7a,
        "arm64" => AndroidABI.arm64_v8a,
        _ => AndroidABI.arm64_v8a,
      };

      return Platform.android(
        apiLevel:
            AndroidAPI(0, Version.parse(io.Platform.operatingSystemVersion)),
        abi: abi,
      );
    }

    if (io.Platform.isIOS) {
      return Platform.ios(
          sdkVersion: Version.parse(io.Platform.operatingSystemVersion));
    }

    return Platform.bareMetal(
      architecture: switch (architectureName) {
        "x64" => Architecture.amd64,
        "ia32" => Architecture.x86,
        "arm" => Architecture.arm,
        "arm64" => Architecture.aarch64,
        "riscv" => Architecture.riscv32,
        "riscv64" => Architecture.riscv64,
        _ => Architecture.amd64,
      },
    );
  }

  /**
   * Creates a Windows platform with the specified [architecture].
   */
  static Platform<WindowsAttributes> windows({
    required WindowsArchitecture architecture,
    required WindowsBuildVersion buildVersion,
  }) => Platform(
    os: OperatingSystem.windows,
    attributes: WindowsAttributes(
      architecture: architecture,
      buildVersion: buildVersion,
    ),
  );

  /**
   * Creates a Linux platform with the specified [architecture] and optional [distribution].
   * If [distribution] is not provided, defaults to [LinuxDistribution.unspecified].
   */
  static Platform<LinuxAttributes> linux({
    required LinuxArchitecture architecture,
  }) => Platform(
    os: OperatingSystem.linux,
    attributes: LinuxAttributes(architecture: architecture),
  );

  /**
   * Creates an Android platform with the specified [apiLevel] and [abi].
   */
  static Platform<AndroidAttributes> android({
    required AndroidAPI apiLevel,
    required AndroidABI abi,
  }) => Platform(
    os: OperatingSystem.android,
    attributes: AndroidAttributes(apiLevel: apiLevel, abi: abi),
  );

  /**
   * Creates a macOS platform targeting the specified [processor], [version] and [sdkVersion].
   */
  static Platform<MacOSAttributes> macos({
    required MacOSProcessor processor,
    required Version sdkVersion,
  }) => Platform(
    os: OperatingSystem.macos,
    attributes: MacOSAttributes(
      processor: processor,
      sdkVersion: sdkVersion,
    ),
  );

  /**
   * Creates an iOS platform for the specified [version] and [sdkVersion].
   */
  static Platform<iOSAttributes> ios({
    required sdkVersion,
  }) => Platform(
    os: OperatingSystem.ios,
    attributes: iOSAttributes(sdkVersion: sdkVersion),
  );

  /**
   * Creates a bare-metal platform with the specified CPU [architecture].
   *
   * Used for systems without an operating system (e.g., microcontrollers,
   * single-board computers, or firmware targets).
   */
  static Platform<BareMetalAttributes> bareMetal({
    required Architecture architecture,
  }) => Platform(
    os: OperatingSystem.none,
    attributes: BareMetalAttributes(architecture: architecture),
  );
}