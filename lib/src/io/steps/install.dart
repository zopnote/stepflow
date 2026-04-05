import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:stepflow/core.dart';

/**
 * A step that installs files and directories to a specified location.
 */
final class Install extends ConfigureStep {
  /**
   * Path where files should be installed to relative to the environment root.
   * The path is separated through items of the list.
   */
  final String installPath;

  /**
   * The names of the directories that will
   * be installed with their name into the install location.
   */
  final List<String> directories;

  /**
   * The names of the files that will be installed with their full name
   * into the install location.
   */
  final List<String> files;

  /**
   * Path where the binaries are that should be copied to installPath.
   */
  final String binariesPath;

  /**
   * File which contains these patterns will be excluded.
   * E. g. there are two files: test.exe & text.lib
   * With .lib the text.lib won't be installed.
   */
  final List<String> excludeFileWithPatterns;

  /**
   * A step that installs files and directories to a specified location.
   *
   * Default const constructor.
   * All lists are set to empty ones, on default.
   */
  const Install({
    this.installPath = "",
    this.binariesPath = "",
    this.files = const [],
    this.directories = const [],
    this.excludeFileWithPatterns = const [],
  });

  /**
   * Installs a single [File].
   */
  void _forFile(File file) {
    final String fileName = path.basenameWithoutExtension(file.path);
    final String fileExtension = path.extension(file.path);
    if (!files.contains(fileName) ||
        excludeFileWithPatterns.contains(fileExtension)) {
      return;
    }
    final String fileInstallPath = path.join(
      installPath,
      path.relative(file.path, from: binariesPath),
    );
    final fileInstallDirectory = Directory(path.dirname(fileInstallPath));
    if (!fileInstallDirectory.existsSync()) {
      fileInstallDirectory.createSync(recursive: true);
    }
    file.copySync(fileInstallPath);
  }

  /**
   * Installs a single [Directory] with all it's files.
   */
  void _forDirectory(Directory directory) {
    if (!directories.contains(path.basename(directory.path))) {
      return;
    }
    final files = directory
        .listSync(recursive: true)
        .where((entity) => (entity is File))
        .cast<File>();
    files.forEach((file) {
      final String fileInstallPath = path.join(
        installPath,
        path.relative(directory.path, from: binariesPath),
        path.relative(file.path, from: directory.path),
      );
      final fileInstallDirectory = Directory(path.dirname(fileInstallPath));
      if (!fileInstallDirectory.existsSync()) {
        fileInstallDirectory.createSync(recursive: true);
      }
      file.copySync(fileInstallPath);
    });
  }

  /**
   * Finalizer method to configure the installation step.
   *
   * Iterates over [binariesPath] and copies matching [files] and [directories]
   * to [installPath].
   */
  @override
  Step configure() {
    return Runnable(() {
      final Directory workDirectory = Directory(binariesPath);
      workDirectory.listSync().forEach((entity) {
        if (entity is File) {
          _forFile(entity);
        } else if (entity is Directory) {
          _forDirectory(entity);
        } else {
          throw FileSystemException(
              "Only directories and files are supported for installation.",
              entity.path,
              OSError("Invalid file system type.", 2));
        }
      });
    });
  }
}
