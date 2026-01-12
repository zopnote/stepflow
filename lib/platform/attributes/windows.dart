import '../platform.dart';

/**
 * Windows build numbers and versions.
 *
 * Whenever a newer Windows build is available then listed here,
 * just instantiate the wanted build version with the data from [here](https://learn.microsoft.com/de-de/windows/release-health/windows11-release-information).
 * Format the build number as patch version of the semantic version.
 */
class WindowsBuildVersion {
  /**
   * Creates an instance of [WindowsBuildVersion] with a specific [build] number and its
   * corresponding Windows OS [version].
   */
  const WindowsBuildVersion(this.build, this.version);

  /**
   * Windows 10 2022 Update (Build 19045)
   */
  static const WindowsBuildVersion win10_22H2 = WindowsBuildVersion(
    19045,
    Version(10, 0, 19045),
  );

  /**
   * Windows 11 (Build 22000)
   */
  static const WindowsBuildVersion win11_21H2 = WindowsBuildVersion(
    22000,
    Version(10, 0, 22000),
  );

  /**
   * Windows 11 2022 Update (Build 22621)
   */
  static const WindowsBuildVersion win11_22H2 = WindowsBuildVersion(
    22621,
    Version(10, 0, 22621),
  );

  /**
   * Windows 11 2023 Update (Build 22631)
   */
  static const WindowsBuildVersion win11_23H2 = WindowsBuildVersion(
    22631,
    Version(10, 0, 22631),
  );

  /**
   * Windows 11 2024 Update (Build 26100)
   */
  static const WindowsBuildVersion win11_24H2 = WindowsBuildVersion(
    26100,
    Version(10, 0, 26100),
  );

  /**
   * Windows Server 2016 (Build 14393)
   */
  static const WindowsBuildVersion server2016 = WindowsBuildVersion(
    14393,
    Version(10, 0, 14393),
  );

  /**
   * Windows Server 2019 (Build 17763)
   */
  static const WindowsBuildVersion server2019 = WindowsBuildVersion(
    17763,
    Version(10, 0, 17763),
  );

  /**
   * Windows Server 2022 (Build 20348)
   */
  static const WindowsBuildVersion server2022 = WindowsBuildVersion(
    20348,
    Version(10, 0, 20348),
  );

  /**
   * Windows Server 2025 (Build 26100)
   */
  static const WindowsBuildVersion server2025 = WindowsBuildVersion(
    26100,
    Version(10, 0, 26100),
  );

  /**
   * The Windows build number.
   */
  final int build;

  /**
   * The corresponding Windows operating system version.
   */
  final Version version;
}

/**
 * Architectures supported by Windows.
 */
enum WindowsArchitecture {
  /**
   * ARM64 Emulation Compatible (x64 on ARM64).
   */
  ARM64EC(Architecture.aarch64),

  /**
   * Native 64-bit ARM.
   */
  ARM64(Architecture.aarch64),

  /**
   * Native 32-bit ARM.
   */
  ARM(Architecture.arm),

  /**
   * 64-bit x86 (AMD64/Intel64).
   */
  x64(Architecture.amd64),

  /**
   * 32-bit x86.
   */
  x86(Architecture.x86);

  const WindowsArchitecture(this.architecture);

  /**
   * The underlying hardware architecture.
   */
  final Architecture architecture;
}

final class WindowsAttributes extends PlatformAttributes {
  WindowsAttributes({required this.architecture, required this.buildVersion})
    : super("windows", buildVersion.version);
  final WindowsBuildVersion buildVersion;
  final WindowsArchitecture architecture;
}
