import 'dart:io';

import 'package:stepflow/io.dart';

Future<void> main() async {
  await Shell(
      program: "dart",
      arguments: [],
      onStdout: (context, chars) => stdout.add(chars))();
}
