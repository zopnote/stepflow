import 'package:stepflow/platform/platform.dart';



/**
 * Attributes for representation purposes of the iOS platform.
 */
final class iOSAttributes extends PlatformAttributes {
  const iOSAttributes({required Version version, this.sdkVersion}) : super("ios", version);

  /**
   * The version of the iOS SDK used for building or targeting.
   */
  final Version? sdkVersion;

  /**
   * The hardware architecture of the iOS device.
   * For modern iOS devices, this is typically [Architecture.aarch64].
   */
  final Architecture architecture = Architecture.aarch64;
}
