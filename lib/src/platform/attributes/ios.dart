import 'package:stepflow/platform.dart';



/**
 * Attributes for representation purposes of the iOS platform.
 */
final class iOSAttributes extends PlatformAttributes {
  const iOSAttributes({required this.sdkVersion}) : super("ios", sdkVersion);

  /**
   * The version of the iOS SDK used for building or targeting.
   */
  final Version sdkVersion;

  /**
   * The hardware architecture of the iOS device.
   * For modern iOS devices, this is typically [Architecture.aarch64].
   */
  final Architecture arch = Architecture.aarch64;
}
