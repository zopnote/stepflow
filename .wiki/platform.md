
### Getting started with Stepflow's platform representation

This guide should walk you through the purpose, functions, and usage of the `lib/platform/` interface. 
By the end, you'll know how to detect, define, and use platform metadata in a type-safe way.

## 1. The purpose

Because a platform is often made up of multiple dependent attributes 
(architecture, sdk, version), there is a need to represent the platform 
attributes just as dependently with their different metadata by itself.

This allows type-safe and more robust code when dealing with platform-specific logic 
or deployment targets.

---

## 2. Detecting your current platform

The easiest way to start is by asking Stepflow what the current machine looks like.

```dart
import 'package:stepflow/platform/platform.dart';

void main() {
  // Automatically detects the OS, architecture, 
  // version and other attributes.
  final current = Platform.current();

  print("You are running on: ${current.os.name}");
  print("Specific attributes (As example): "
      "${current.attributes.features.sse3.available}");
}
```

## 3. Defining targets manually

Sometimes you aren't checking the current machine, but defining a target for a build or deployment. Stepflow provides factory methods for every supported platform.

### Windows
```dart
final winTarget = Platform.windows(
  architecture: WindowsArchitecture.x64,
  buildVersion: WindowsBuildVersion.win11_24H2, // Predefined constant
);
```

### Android
```dart
final androidTarget = Platform.android(
  apiLevel: AndroidAPI.tiramisu, // API Level 33 (Android 13)
  abi: AndroidABI.arm64_v8a,
);
```

### macOS & iOS
```dart
final macTarget = Platform.macos(
  processor: MacOSProcessor.applesilicon,
  version: Version(14, 0, 0),
);

final iosTarget = Platform.ios(
  sdkVersion: Version(17, 2, 0),
);
```

---

## 4. Understanding the Building Blocks

The API is composed of four main elements:

1.  **`Platform<Attributes>`**: The main container, representing a platform with its declared attributes.
2.  **`OperatingSystem`**: An enum (`windows`, `linux`, `macos`, `ios`, `android`, `none`, `generic`).
3.  **`Architecture`**: Unified hardware types (`amd64`, `aarch64`, `x86`, `arm`, `riscv`).
4.  **`Version`**: A semantic versioning implementation (`major`, `minor`, `patch`).

### External Resources for Versioning
Mapping system versions can be complex. Here are the references Stepflow follows:
- [Windows Build Information](https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information)
  - major.minor.build (e.g., 10.0.22000)
- [Android API Levels](https://developer.android.com/tools/releases/platforms)
  - major.minor.path for the android os version in combination with the api level (e.g., level: 36; version: 16.0.0 - )
- [Apple OS Versions](https://support.apple.com/en-us/HT201260)
  - major.minor.patch for the os sdk version (e.g., for tahoe 26.2.0)
- [Android NDK ABIs](https://developer.android.com/ndk/guides/abis)

---

## 5. Bare Metal and Custom Targets

Stepflow isn't limited to full operating systems. If you are targeting a microcontroller or a custom firmware, use the `bareMetal` factory.

```dart
final esp32 = Platform.bareMetal(
  architecture: Architecture.riscv32,
);

print(esp32.os); // Output: OperatingSystem.none


// Or add your own platform
// -----------------------------------------------------
class MicroControllerCustomPlatformAttributes
  extends PlatformAttributes {
    const MicroControllerCustomPlatformAttributes() : 
      super("mcc32", Version(2, 8, 3));

    final Version version = Version(2, 8, 3);
    final bool isDevelopmentEnvironment = true;
    final Architecture architecture = .riscv32;
}

final Platform myMcc32Platform = Platform(
  os: OperatingSystem.generic, 
  attributes: MicroControllerCustomPlatformAttributes()
);
// -----------------------------------------------------

```

## Summary

The Stepflow Platform API makes your code:
- **Readable:** Use named constants like `.tiramisu` or `.win11_24H2`.
- **Safe:** Catch platform mismatches during development.
- **Predictable:** Unified versioning and architecture naming across all systems.
- **Extensible:** Add your own platforms with attributes.
