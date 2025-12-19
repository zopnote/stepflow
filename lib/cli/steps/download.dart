import 'dart:async';
import 'dart:io';

import 'package:stepflow/common.dart';

/**
 * Download files from an url and extract them if desired.
 */
final class Download extends Step {
  final Uri url;
  final String outputPath;
  Download({required this.url, required this.outputPath});

  @override
  Future<Step?> execute(
    FlowContextController controller, [
    FutureOr<Step?> Function()? candidate,
  ]) async {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    response.pipe(File('foo.txt').openWrite());
    return (candidate ?? () => null)();
  }

  @override
  Map<String, dynamic> toJson() => {"type": "download"};
}
