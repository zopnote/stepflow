import 'package:stepflow/platform/platform.dart';

/**
 * Attributes for representation purposes of a bare-metal platform.
 *
 * Bare-metal targets are systems without a full operating system,
 * such as microcontrollers, firmware, or single-board computers.
 */
final class BareMetalAttributes extends PlatformAttributes {
  const BareMetalAttributes({required this.architecture}) : super("baremetal", const Version(0, 0, 0));
  final Architecture architecture;
}