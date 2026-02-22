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

@immutable
abstract class CollectionStep<T extends CollectionStep<T>> extends Step {
  const CollectionStep();

  @override
  @protected
  FutureOr<Step?> execute(FlowController controller,
      [FutureOr<Step?> Function()? candidate]) {
    return super.execute(controller, candidate);
  }

  @protected
  Step stepwise<S extends SingleStep<T, C>, C extends StepWiser<T, C, S>>(
      C settings) {
    return settings.stepwise(this as T);
  }
}

@immutable
mixin StepWiser<T extends CollectionStep<T>, C extends StepWiser<T, C, S>,
    S extends SingleStep<T, C>> {
  @protected
  Step stepwise(T collection) {
    S step = create();
    step.wise = this as C;
    step.step = collection;
    return step;
  }

  @protected
  S create();
}

abstract class SingleStep<T extends CollectionStep<T>,
    C extends StepWiser<T, C, SingleStep<T, C>>> extends ConfigureStep {
  late final T step;
  late final C wise;
}

/**
 * A [Bubble] is a [Step] that consists of running a builder function,
 * and its returned [Step], until it receives the prompt to stop.
 * Then it will run the candidate it got on the execution of itself.
 *
 * A [Bubble] can be closed by [FlowContext.pop()], [FlowContext.close()] or
 * by setting the [bool leave] to [true].
 * * [pop()] and [close()] are meant for errors
 * that can occur as part of the workflow inside of the [Bubble].
 * * [leave] is
 * way to escape the [Bubble] successfully.
 *
 * As example, in the [Chain] step,
 * [leave] is set to true whenever the length of the steps is reached.
 */
@Deprecated("Move over to FlowController.createBubble")
abstract class Bubble extends Step {
  /**
   * Marks if the [Bubble] should be closed after the current running [Step].
   *
   * Should be used only inside of subclasses derived from [Bubble].
   */
  @protected
  bool leave = false;

  /**
   * The builder function will be called whenever the previous step inside the
   * [Bubble] passes by without an error.
   *
   * In a [Bubble] where no [FlowContext.pop()],
   * [FlowContext.close()] or [bool leave = true] occurs,
   * the builder function should never allocate memory that
   * lives longer than the step it returns, because it will be ran infinite times.
   */
  Step builder();

  /**
   * Executes the builder function until an escape prompt is received.
   *
   * Increases the [FlowContext]'s depth and runs steps.
   *
   * If closed the function will return it's given [candidate] or [null].
   */
  @override
  FutureOr<Step?> execute(
    final FlowController controller, [
    FutureOr<Step?> candidate()?,
  ]) async {
    await controller.createBubble(() => !leave ? builder() : null);
    final none = () => null;
    return (candidate ?? none)();
  }
}
