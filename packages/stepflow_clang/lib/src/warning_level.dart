class ClangWarningLevel {
  final String flag;
  const ClangWarningLevel(this.flag);
  static const ClangWarningLevel none = ClangWarningLevel("w");
  static const ClangWarningLevel normal = ClangWarningLevel("");
  static const ClangWarningLevel all = ClangWarningLevel("Weverything");
  static const ClangWarningLevel uncompromising = ClangWarningLevel("Werror");
}