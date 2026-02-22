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
