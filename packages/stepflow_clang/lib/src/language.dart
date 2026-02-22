
enum ClangLanguage {
  cxx11("c++", "c++11"),
  cxx14("c++", "c++14"),
  cxx17("c++", "c++17"),
  cxx23("c++", "c++23"),
  c99("c", "c99"),
  c11("c", "c11"),
  c17("c", "c17"),
  c23("c", "c2x");

  const ClangLanguage(this.language, this.standard);
  final String language;
  final String standard;
}