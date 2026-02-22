import 'package:stepflow/core.dart';
import 'package:stepflow/io.dart';
import 'package:stepflow_clang/clang.dart';

extension StringMappingMapExtension<K, V> on Map<K, V> {
  Iterable<String> macro(String Function(K key, V value) mapper) sync* {
    for (final entry in entries) {
      yield mapper(entry.key, entry.value);
    }
  }
}

extension ArgumentBuildListExtension on List<String> {
  void addIf(bool condition, String value) {
    if (condition) add(value);
  }

  void addNotNull<T>(T? value, String Function(T) map) {
    if (value != null) add(map(value));
  }
}

extension MacroFormatObjectExtension on Object? {
  String fmtMacro() => switch (this) {
    int i => "=$i",
    String s => s.isNotEmpty ? '="$s"' : "",
    _ => "",
  };
}

abstract class ClangStep<C extends StepWiser<Clang, C, SingleStep<Clang, C>>>
    extends SingleStep<Clang, C> {
  @override
  Step configure() => Shell(program: step.executablePath, arguments: format());
  List<String> format();
}
