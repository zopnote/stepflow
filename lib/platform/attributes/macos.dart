import 'package:stepflow/platform/platform.dart';

/**
 * Common processors for macOS devices.
 */
enum MacOSProcessor {
  /**
   * Intel-based Macs (x86_64).
   */
  intel(Architecture.amd64),

  /**
   * Apple Silicon (M1, M2, M3, etc.) based Macs (ARM64).
   */
  applesilicon(Architecture.aarch64);

  const MacOSProcessor(this.architecture);

  /**
   * The underlying hardware architecture.
   */
  final Architecture architecture;
}

/**
 * Attributes for representation purposes of the macOS platform.
 */
final class MacOSAttributes extends PlatformAttributes {
  const MacOSAttributes({
    required this.processor,
    required this.sdkVersion,
  }) : super("macos", sdkVersion);

  final MacOSProcessor processor;

  /**
   * The version of the macOS SDK used for building or targeting.
   */
  final Version sdkVersion;
}
