import '../platform.dart';

/**
 * There are several API level of an android application.
 * The API level refers to the android version and the available
 * features. Check for the required feature set,
 * to decide the right level for your application.
 */
class AndroidAPI {
  /**
   * Creates an instance of [AndroidAPI] with a specific [level] and its
   * corresponding Android OS [version].
   */
  const AndroidAPI(this.level, this.version);

  /**
   * Android 5.1 Lollipop (API level 22)
   */
  static const AndroidAPI lollipop = AndroidAPI(22, Version(5, 1, 0));

  /**
   * Android 6.0 Marshmallow (API level 23)
   */
  static const AndroidAPI marshmallow = AndroidAPI(23, Version(6, 0, 0));

  /**
   * Android 7.1 Nougat (API level 25)
   */
  static const AndroidAPI nougat = AndroidAPI(25, Version(7, 1, 0));

  /**
   * Android 8.1 Oreo (API level 27)
   */
  static const AndroidAPI oreo = AndroidAPI(27, Version(8, 1, 0));

  /**
   * Android 9.0 Pie (API level 28)
   */
  static const AndroidAPI pie = AndroidAPI(28, Version(9, 0, 0));

  /**
   * Android 10.0 Quince Tart (API level 29)
   */
  static const AndroidAPI quincetart = AndroidAPI(29, Version(10, 0, 0));

  /**
   * Android 11.0 Velvet Cake (API level 30)
   */
  static const AndroidAPI velvetcake = AndroidAPI(30, Version(11, 0, 0));

  /**
   * Android 12.1/12L Snow Cone (API level 32)
   */
  static const AndroidAPI snowcone = AndroidAPI(32, Version(12, 1, 0));

  /**
   * Android 13.0 Tiramisu (API level 33)
   */
  static const AndroidAPI tiramisu = AndroidAPI(33, Version(13, 0, 0));

  /**
   * Android 14.0 Upside Down Cake (API level 34)
   */
  static const AndroidAPI upsidedowncake = AndroidAPI(34, Version(14, 0, 0));

  /**
   * The integer API level.
   */
  final int level;

  /**
   * The corresponding Android operating system version.
   */
  final Version version;
}

/**
 * Different Android devices use different CPUs,
 * which in turn support different instruction sets.
 * Each combination of CPU and instruction set has its
 * own Application Binary Interface (ABI).
 *
 * More information about the android ABIs can be found inside the [NDK documentation](https://developer.android.com/ndk/guides/abis?hl=de)
 */
enum AndroidABI {
  armeabi_v7a(Architecture.arm),
  arm64_v8a(Architecture.aarch64),
  x86(Architecture.x86),
  x86_64(Architecture.amd64);

  const AndroidABI(this.arch);
  final Architecture arch;
}

/**
 * Attributes for representation purposes of the Android platform.
 */
final class AndroidAttributes extends PlatformAttributes {
  AndroidAttributes({required this.apiLevel, required this.abi})
      : super("android", apiLevel.version);
  final AndroidAPI apiLevel;
  final AndroidABI abi;

  @override
  Architecture get arch => abi.arch;
}
