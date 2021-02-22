part of widgets;

class ModalCardRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin {
  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  TransitionRoute _prevRoute;
  TransitionRoute _nextRoute;

  ModalCardRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  @override
  bool get opaque => false;

  @override
  final bool maintainState = true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    assert(() {
      if (result == null) {
        throw FlutterError('The builder for route "${settings.name}" returned null.\n'
            'Route builders must never return null.');
      }
      return true;
    }());
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    _prevRoute = previousRoute;
    return true;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    _nextRoute = nextRoute;
    return true;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (_nextRoute is CupertinoPageRoute) {
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    }

    return _ModalPageStackTransition(
      level: this.isFirst ? 0.0 : 1.0,
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: CupertinoRouteTransitionMixin.isPopGestureInProgress(this),
      child: _ModalBackGestureDetector<T>(
        enabledCallback: () => popGestureEnabled,
        onStartPopGesture: () => _VerticalBackGestureController<T>(
          navigator: navigator,
          controller: controller,
        ),
        child: child,
      ),
    );
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  String get title => null;
}

/// Provides an iOS-style page transition animation.
///
/// The page slides in from the right and exits in reverse. It also shifts to the left in
/// a parallax motion when another page enters to cover it.
class _ModalPageStackTransition extends StatelessWidget {
  /// Creates an iOS-style page transition.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform the transitions linearly.
  ///    Used to precisely track back gesture drags.
  _ModalPageStackTransition({
    Key key,
    this.level: 0.0,
    @required Animation<double> primaryRouteAnimation,
    @required Animation<double> secondaryRouteAnimation,
    @required this.child,
    @required bool linearTransition,
  })  : assert(linearTransition != null),
        _primaryPositionAnimation = (linearTransition
            ? primaryRouteAnimation
            : CurvedAnimation(
                parent: primaryRouteAnimation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
              )),
        _secondaryPositionAnimation = (linearTransition
            ? secondaryRouteAnimation
            : CurvedAnimation(
                parent: secondaryRouteAnimation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
              )),
        super(key: key);

  final double level;

  // When this page is coming in to cover another page.
  final Animation<double> _primaryPositionAnimation;

  // When this page is becoming covered by another page.
  final Animation<double> _secondaryPositionAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    final outAnim = CurvedAnimation(
      parent: _secondaryPositionAnimation,
      curve: Curves.easeIn.from(0.25),
    );

    final inAnim = CurvedAnimation(
      parent: _primaryPositionAnimation,
      curve: Curves.ease,
    );

    final device = Device.of(context);
    final topBorder = (math.max(device.topBorderSize, 20.0) + 4.0);
    final parentScale = ((topBorder * outAnim.value) * 2.0 / device.height) * (1.0 - math.min(level, 1.0));
    final childPadding = topBorder * math.min(level, 1.0) + 8.0 * level;

    return Stack(
      children: [
        Container(
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.0 - parentScale).animate(outAnim),
            child: Padding(
              padding: EdgeInsets.only(top: childPadding),
              child: SlideTransition(
                position: Tween(begin: Offset(0.0, 1.0), end: Offset.zero).animate(inAnim),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: child,
                ),
              ),
            ),
          ),
        ),
        if (level == 0.0)
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: outAnim.value,
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
      ],
    );
  }
}

/// A controller for an iOS-style back gesture.
///
/// This is created by a [CupertinoPageRoute] in response from a gesture caught
/// by a [_ModalBackGestureDetector] widget, which then also feeds it input
/// from the gesture. It controls the animation controller owned by the route,
/// based on the input provided by the gesture detector.
///
/// This class works entirely in logical coordinates (0.0 is new page dismissed,
/// 1.0 is new page on top).
///
/// The type `T` specifies the return type of the route with which this gesture
/// detector controller is associated.
class _VerticalBackGestureController<T> {
  /// Creates a controller for an iOS-style back gesture.
  ///
  /// The [navigator] and [controller] arguments must not be null.
  _VerticalBackGestureController({
    @required this.navigator,
    @required this.controller,
  })  : assert(navigator != null),
        assert(controller != null) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [fractionalDelta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of
  /// [fractionalVelocity] as a fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= 1.0)
      animateForward = velocity <= 0;
    else
      animateForward = controller.value > 0.5;

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final int droppedPageForwardAnimationTime = math.min(
        ui.lerpDouble(800, 0, controller.value).floor(),
        300,
      );
      controller.animateTo(1.0, duration: Duration(milliseconds: droppedPageForwardAnimationTime), curve: animationCurve);
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final int droppedPageBackAnimationTime = ui.lerpDouble(0, 800, controller.value).floor();
        controller.animateBack(0.0, duration: Duration(milliseconds: droppedPageBackAnimationTime), curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

/// This is the widget side of [_VerticalBackGestureController].
///
/// This widget provides a gesture recognizer which, when it determines the
/// route can be closed with a back gesture, creates the controller and
/// feeds it the input from the gesture recognizer.
///
/// The gesture data is converted from absolute coordinates to logical
/// coordinates by this widget.
///
/// The type `T` specifies the return type of the route with which this gesture
/// detector is associated.
class _ModalBackGestureDetector<T> extends StatefulWidget {
  const _ModalBackGestureDetector({
    Key key,
    @required this.enabledCallback,
    @required this.onStartPopGesture,
    @required this.child,
  })  : assert(enabledCallback != null),
        assert(onStartPopGesture != null),
        assert(child != null),
        super(key: key);

  final Widget child;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<_VerticalBackGestureController<T>> onStartPopGesture;

  @override
  _ModalBackGestureDetectorState<T> createState() => _ModalBackGestureDetectorState<T>();
}

class _ModalBackGestureDetectorState<T> extends State<_ModalBackGestureDetector<T>> {
  _VerticalBackGestureController<T> _backGestureController;

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);

    _backGestureController.dragUpdate(details.primaryDelta / context.size.height);
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);

    final velocity = details?.velocity?.pixelsPerSecond?.dx ?? 0.0;

    _backGestureController?.dragEnd(velocity / context.size.height);
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down" event
    // that we don't consider here.
    _backGestureController?.dragEnd(0.0);
    _backGestureController = null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    // For devices with notches, the drag area needs to be larger on the side
    // that has the notch.

    return GestureDetector(
      excludeFromSemantics: true,
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      onVerticalDragCancel: _handleDragCancel,
      child: NotificationListener(
        child: widget.child,
        onNotification: (notification) {
          if (notification is OverscrollNotification && notification.overscroll < 0.0) {
            if (_backGestureController == null) {
              _handleDragStart(null);
            } else if (notification.dragDetails != null) {
              _handleDragUpdate(notification.dragDetails);
            }
          } else if (notification is ScrollEndNotification) {
            _handleDragEnd(notification.dragDetails);
          } else if (notification is ScrollUpdateNotification) {
            if (_backGestureController != null && notification.dragDetails != null) {
              _handleDragUpdate(notification.dragDetails);
            }
          }

          return false;
        },
      ),
    );
  }
}
