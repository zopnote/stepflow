import 'dart:io' show File;

import 'package:stepflow/core.dart';
import 'package:stepflow_clang/clang.dart';

import 'clang_step.dart';

/// Configuration object for invoking `clang-format` as a Stepflow step.
///
/// This class represents a **complete, declarative mapping** of the
/// `clang-format` command line interface into Dart. Each field corresponds
/// directly to one or more CLI flags and is translated *exclusively* inside
/// [ClangFormat.format].
///
/// ### Design goals
///
/// - No hidden logic: every argument is constructed in one place
/// - Deterministic behavior: the same settings always produce the same CLI
/// - CI- and editor-friendly
/// - Faithful to the official `clang-format` semantics
///
/// ### Style resolution priority
///
/// Exactly one formatting style must be provided. Resolution follows the
/// official precedence rules:
///
/// 1. [inlineStyle] → `-style={ ... }`
/// 2. [styleFile]   → `-style=file --assume-filename=<path>`
/// 3. [style]       → `-style=<LLVM|Google|…>`
///
/// If none of these is set, construction fails early via an assertion.
class ClangFormatSettings
    with StepWiser<Clang, ClangFormatSettings, ClangFormat> {
  /// Source files to format.
  ///
  /// Each file is appended verbatim to the end of the CLI invocation.
  final List<File> input;

  /// Whether formatting should be applied in-place (`-i`).
  ///
  /// If `false`, formatted output is written to stdout instead.
  final bool inPlace;

  /// Built-in formatting style (e.g. LLVM, Google, Mozilla).
  ///
  /// Mapped to `-style=<value>`.
  final ClangFormatStyle? style;

  /// Inline YAML style definition.
  ///
  /// This corresponds to the `-style={ ... }` CLI form and allows defining
  /// formatting rules programmatically without a `.clang-format` file.
  final ClangFormatInlineStyle? inlineStyle;

  /// Explicit `.clang-format` file reference.
  ///
  /// Implemented using:
  ///
  /// ```text
  /// -style=file --assume-filename=<path>
  /// ```
  ///
  /// This mirrors clang-format’s internal file discovery logic.
  final File? styleFile;

  /// Language hint used for parsing and formatting.
  ///
  /// Passed as a synthetic filename via `--assume-filename`.
  final ClangFormatLanguage? language;

  /// Cursor position for editor integrations.
  ///
  /// When set, clang-format will attempt to preserve the logical cursor
  /// position after formatting.
  final int? cursor;

  /// Line ranges to format (1-based, inclusive).
  ///
  /// Each entry is translated to `-lines=<start>:<end>`.
  final List<ClangFormatRange> ranges;

  /// Whether include directives should be sorted.
  ///
  /// If `false`, maps to `-sort-includes=false`.
  final bool sortIncludes;

  /// Disables formatting entirely.
  ///
  /// Useful for validation or debugging. Maps to `-disable-format`.
  final bool disableFormat;

  /// Emit formatting changes as XML replacements.
  ///
  /// Intended for tooling and CI usage. Maps to `-output-replacements-xml`.
  final bool outputReplacementsXML;

  const ClangFormatSettings({
    required this.input,
    this.inPlace = true,
    this.style,
    this.inlineStyle,
    this.styleFile,
    this.language,
    this.cursor,
    this.ranges = const [],
    this.sortIncludes = true,
    this.disableFormat = false,
    this.outputReplacementsXML = false,
  }) : assert(
         style != null || inlineStyle != null || styleFile != null,
         'One of style, inlineStyle or styleFile must be provided',
       );

  @override
  ClangFormat create() => ClangFormat();
}

/// Stepflow execution unit for `clang-format`.
///
/// The entire command line is constructed in [format] using a fluent,
/// append-only style. No argument construction is delegated elsewhere.
class ClangFormat extends ClangStep<ClangFormatSettings> {
  @override
  List<String> format() => List<String>.empty(growable: true)
    // Executable
    ..add('clang-format')
    // ─────────────────────────────────────────────
    // Style resolution (priority order)
    // inlineStyle > styleFile > style
    // ─────────────────────────────────────────────
    ..addIf(
      wise.inlineStyle != null,
      '-style=${wise.inlineStyle!.toCliValue()}',
    )
    ..addIf(wise.inlineStyle == null && wise.styleFile != null, '-style=file')
    ..addIf(
      wise.inlineStyle == null && wise.styleFile != null,
      '--assume-filename=${wise.styleFile!.path}',
    )
    ..addIf(
      wise.inlineStyle == null && wise.styleFile == null && wise.style != null,
      '-style=${wise.style}',
    )
    // ─────────────────────────────────────────────
    // Formatting behavior
    // ─────────────────────────────────────────────
    ..addIf(wise.inPlace, '-i')
    ..addIf(!wise.sortIncludes, '-sort-includes=false')
    ..addIf(wise.disableFormat, '-disable-format')
    ..addIf(wise.outputReplacementsXML, '-output-replacements-xml')
    // ─────────────────────────────────────────────
    // Cursor & language hints
    // ─────────────────────────────────────────────
    ..addNotNull<int>(wise.cursor, (c) => '-cursor=$c')
    ..addNotNull<ClangFormatLanguage>(
      wise.language,
      (l) => '-assume-filename=dummy.$l',
    )
    // ─────────────────────────────────────────────
    // Line ranges
    // ─────────────────────────────────────────────
    ..addAll(wise.ranges.map((r) => '-lines=${r.start}:${r.end}'))
    // ─────────────────────────────────────────────
    // Input files (always last)
    // ─────────────────────────────────────────────
    ..addAll(wise.input.map((f) => f.path));
}

/// Built-in formatting styles supported by clang-format.
///
/// These correspond to the officially shipped presets.
final class ClangFormatStyle {
  /// Raw CLI value.
  final String value;
  const ClangFormatStyle(this.value);

  static const ClangFormatStyle file = ClangFormatStyle('file');
  static const ClangFormatStyle llvm = ClangFormatStyle('LLVM');
  static const ClangFormatStyle google = ClangFormatStyle('Google');
  static const ClangFormatStyle chromium = ClangFormatStyle('Chromium');
  static const ClangFormatStyle mozilla = ClangFormatStyle('Mozilla');
  static const ClangFormatStyle webkit = ClangFormatStyle('WebKit');

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClangFormatStyle && other.value == value;
}

/// Language hint abstraction for clang-format.
///
/// Used to disambiguate parsing rules when file extensions are ambiguous
/// or missing.
final class ClangFormatLanguage {
  final String value;
  const ClangFormatLanguage(this.value);

  static const ClangFormatLanguage c = ClangFormatLanguage('c');
  static const ClangFormatLanguage cpp = ClangFormatLanguage('cpp');
  static const ClangFormatLanguage objc = ClangFormatLanguage('m');
  static const ClangFormatLanguage proto = ClangFormatLanguage('proto');

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClangFormatLanguage && other.value == value;
}

/// Line range definition for partial formatting.
///
/// Both [start] and [end] are 1-based and inclusive.
final class ClangFormatRange {
  final int start;
  final int end;

  const ClangFormatRange(this.start, this.end);
}

/// Inline YAML style definition for clang-format.
///
/// This class allows constructing a `.clang-format` configuration
/// programmatically and embedding it directly into the CLI invocation.
///
/// Example:
///
/// ```dart
/// ClangFormatInlineStyle({
///   'BasedOnStyle': 'LLVM',
///   'IndentWidth': 2,
///   'ColumnLimit': 100,
/// });
/// ```
final class ClangFormatInlineStyle {
  /// Key-value mapping of clang-format rules.
  final Map<String, Object> rules;

  const ClangFormatInlineStyle(this.rules);

  /// Serializes the rule map into a clang-format compatible inline YAML string.
  String toCliValue() {
    final buffer = StringBuffer('{');
    var first = true;

    for (final entry in rules.entries) {
      if (!first) buffer.write(', ');
      first = false;
      buffer.write('${entry.key}: ${_formatValue(entry.value)}');
    }

    buffer.write('}');
    return buffer.toString();
  }

  String _formatValue(Object value) {
    if (value is bool || value is num) {
      return value.toString();
    }
    if (value is String) {
      return value.contains(' ') ? '"$value"' : value;
    }
    if (value is List) {
      return '[${value.map(_formatValue).join(', ')}]';
    }
    throw UnsupportedError(
      'Unsupported clang-format value type: ${value.runtimeType}',
    );
  }
}
