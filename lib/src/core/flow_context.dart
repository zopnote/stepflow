import 'dart:async';

import 'package:stepflow/core.dart';

/**
 * A [FlowContext] holds the information for the package's user to work with the
 * workflow's information without modifying the workflow while it's running.
 */
final class FlowContext {
  /**
   * Sets the Context's depth. Mapped to it's controller.
   */
  final void Function(int value) _setDepth;

  /**
   * Gets the Context's depth. Mapped to it's controller.
   */
  final int Function() _getDepth;

  /**
   * The [StreamSink] for all [Response]s,
   * that should be send to the user of the workflow.
   */
  final StreamSink<Response> sink;

  FlowContext(this._setDepth, this._getDepth, {required this.sink});

  /**
   * Escapes the current [Bubble].
   */
  void pop(final String message) {
    sink.add(Response(message, Level.error));
    _setDepth(_getDepth() - 1);
  }

  /**
   * Escapes the entire workflow.
   */
  void close(final String message) {
    sink.add(Response(message, Level.critical));
    _setDepth(0);
  }

  /**
   * Sends a [Response] to the consumer of the workflows communication ([onData]).
   */
  void send(final Response response) => sink.add(response);
}
