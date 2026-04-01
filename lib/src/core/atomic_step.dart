import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stepflow/core.dart';

/**
 * Blueprint of the atomic representation of a step inside of workflows.
 *
 * An [Step] is capable of manipulating the execution order.
 * It can also run whatever code it wants.
 */
abstract class Step {
  const Step();

  /**
   * Work this [Step] will do.
   *
   * The controller holds the context of the workflow and can manipulate it's data.
   *
   * The function has to return the [Step] that will follow in the execution chain.
   * If you don't want to manipulate the order, just return the [candidate].
   * For an example look at the implementation of [Bubble].
   */
  FutureOr<Step?> execute(
    final FlowController controller, [
    FutureOr<Step?> candidate()?,
  ]) =>
      (candidate ?? () => null)();

  Future<Response> call([FlowController? controller]) async {
    controller ??= FlowController.observed(
      (r) => r.isError ? throw Exception(r) : null,
    );
    await this.execute(controller);
    return controller.close();
  }
}

/**
 * A [ConfigureStep] will build it's [configure()] function into the smallest parts and executes them.
 */
@immutable
abstract class ConfigureStep extends Step {
  const ConfigureStep();

  /**
   * Composes [Step]s into one unit to enable more
   * modular and understandable workflows.
   *
   * Has to return a [Step].
   */
  Step configure();

  /**
   * A [ConfigureStep] will just executes it's underlying [Step]s of [configure()].
   */
  @override
  @protected
  FutureOr<Step?> execute(
    final FlowController controller, [
    FutureOr<Step?> candidate()?,
  ]) =>
      this.configure().execute(controller, candidate);
}
