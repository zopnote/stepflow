import 'dart:io' as io;

import 'package:test/test.dart';
import 'package:stepflow/platform/platform.dart' as stepflow;

void main() => group("Platform representation interfaces", () {
  test("Ensure that the platform detection is validate.", () {
    final current = stepflow.Platform.current();
    print("Detected OS: ${current.os.name}");
    print("Detected Name: ${current.attributes.name}");
    print(
      "Detected Version: ${current.attributes.version.major}.${current.attributes.version.minor}.${current.attributes.version.patch}",
    );

    expect(current.os.name, equals(io.Platform.operatingSystem));
  });

  test("FirstWhereOrNullExtension works correctly", () {
    final list = [1, 2, 3, 4, 5];
    expect(
      stepflow.FirstWhereOrNullExtension(list).firstWhereOrNull((e) => e == 3),
      equals(3),
    );
    expect(
      stepflow.FirstWhereOrNullExtension(list).firstWhereOrNull((e) => e == 6),
      isNull,
    );
    expect(
      stepflow.FirstWhereOrNullExtension([]).firstWhereOrNull((e) => true),
      isNull,
    );
  });
});
