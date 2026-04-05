import 'dart:async';

import 'package:stepflow/core.dart';

/**
 * A [Chain] is a [Bubble] that has a builder, which only will returning [Step]s
 * until the length of the [Chain] is reached.
 *
 * If you want an infinite [Chain], create your own [Bubble].
 */
final class Chain extends Step {
  Chain._internal({required this.builder, required this.length});

  /**
   * A [Chain] that consists of a [List] of [Step].
   *
   * Will execute the [Step] in their order,
   * if the context won't [pop()] or [close()].
   */
  factory Chain({required List<Step> steps}) {
    return Chain._internal(
      builder: (index) {
        return steps[index];
      },
      length: steps.length,
    );
  }

  /**
   * A [Chain] that consists of it's [builder] function and [length].
   *
   * Will execute the builder's [Step]s, if the context won't [pop()] or [close()].
   */
  factory Chain.builder(Step builder(int index), {required final int length}) =>
      Chain._internal(builder: builder, length: length);

  /**
   * The [builder] function has to return a [Step] until the index is as high,
   * as the length allows. The function will be executed every time,
   * the forgoing [Step] is done with it's execution.
   */
  late final Step Function(int index) builder;

  /**
   * The [length] parameter is the length of the [Chain]
   * and will specify of how many [Step]s the [Chain] consists of.
   */
  final int length;

  /**
   * The [index] of the currently ongoing [Step] for the [Chain].
   */
  int _i = 0;

  /**
   * The [builder()] of the [Chain]'s execution order.
   */
  @override
  Future<Step?> execute(FlowController controller,
      [FutureOr<Step?> candidate()?]) async {
    await controller.createBubble(() => _i < length ? builder(_i++) : null);
    return candidate?.call();
  }
}
