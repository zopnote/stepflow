import 'dart:async';

import 'package:stepflow/core.dart';

/**
 * [Step] that just return the candidate and does nothing.
 */
final class Skipped extends Step {
  const Skipped();

  /**
   * Does nothing than returns the candidate.
   */
  @override
  FutureOr<Step?> execute(
    final FlowController controller, [
    FutureOr<Step?> candidate()?,
  ]) => candidate?.call();
}
