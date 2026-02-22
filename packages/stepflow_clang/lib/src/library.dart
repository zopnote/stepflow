import 'dart:io';

class NativeLibrary {
  final File binary;
  final Directory header;
  const NativeLibrary({required this.header, required this.binary});
}