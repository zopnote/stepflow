import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stepflow/core.dart';

/**
 * Executes the [run] function as atomic part of a workflow.
 */
final class Runnable extends Step {
  /**
   * Function that will be run at [Step]'s execution.
   */
  final FutureOr<void> Function() run;
  const Runnable(this.run);

  /**
   * Executes the [run] function and returns the candidate.
   */
  @protected
  @override
  Future<Step?> execute(
    final FlowController controller, [
    FutureOr<Step?> candidate()?,
  ]) async {
    await run();
    return candidate?.call();
  }
}
