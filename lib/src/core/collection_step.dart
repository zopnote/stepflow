import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stepflow/core.dart';

/**
 * A [CollectionStep] is the superior describer of a toolset
 */
@immutable
abstract class CollectionStep<Self extends CollectionStep<Self>> extends Step {
  const CollectionStep();

  @override
  @protected
  FutureOr<Step?> execute(FlowController controller,
      [FutureOr<Step?> Function()? candidate]) {
    return super.execute(controller, candidate);
  }

  @protected
  Step stepwise<Single extends SingleStep<Self, Wiser>,
      Wiser extends StepWiser<Self, Wiser, Single>>(Wiser settings) {
    return settings.stepwise(this as Self);
  }
}

@immutable
mixin StepWiser<
    Collection extends CollectionStep<Collection>,
    Wiser extends StepWiser<Collection, Wiser, Single>,
    Single extends SingleStep<Collection, Wiser>> {
  @protected
  Step stepwise(final Collection collection) {
    final Single step = create();
    step.wise = this as Wiser;
    step.step = collection;
    return step;
  }

  @protected
  Single create();
}

abstract class SingleStep<
    Collection extends CollectionStep<Collection>,
    Wiser extends StepWiser<Collection, Wiser,
        SingleStep<Collection, Wiser>>> extends ConfigureStep {
  late final Collection step;
  late final Wiser wise;
}
