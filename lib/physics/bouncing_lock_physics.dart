part of widgets;

class BouncingLockPhysics extends BouncingScrollPhysics {
  final bool lockTop;
  final bool lockBottom;

  const BouncingLockPhysics({
    ScrollPhysics parent,
    this.lockTop: true,
    this.lockBottom: false,
  }) : super(parent: parent);

  @override
  BouncingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return BouncingLockPhysics(
      parent: buildParent(ancestor),
      lockTop: lockTop,
      lockBottom: lockBottom,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (lockTop) {
      if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
        return value - position.pixels;

      if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
        return value - position.minScrollExtent;
    }

    if (lockBottom) {
      if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
        return value - position.pixels;

      if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
    }

    return 0.0;
  }
}
