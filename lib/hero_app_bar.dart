part of widgets;

Curve _actionInCurve = Curves.linear.to(0.125);
Curve _actionOutCurve = Curves.linear.from(0.875);

Curve _titleInCurve = Curves.linear.to(0.5);
Curve _titleOutCurve = Curves.linear.from(0.5);

const _defaultHeroTag = HeroAppBar;

class HeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Object heroTag;
  final bool primary;
  final Color backgroundColor;
  final double elevation;
  final double toolbarHeight;
  final Color shadowColor;
  final ShapeBorder shape;
  final Widget leading;
  final Widget title;
  final bool centerTitle;
  final List<Widget> actions;
  final PreferredSizeWidget bottom;

  const HeroAppBar({
    Key key,
    this.heroTag: _defaultHeroTag,
    this.primary: true,
    this.backgroundColor,
    this.elevation: 0.0,
    this.toolbarHeight: kToolbarHeight,
    this.shadowColor,
    this.shape,
    this.leading,
    this.title,
    this.centerTitle: false,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + (bottom?.preferredSize?.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading ??
        (ModalRoute.of(context).isFirst
            ? null
            : IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: () => Navigator.of(context).pop(),
              ));

    final appBar = buildAppBar(leading: leadingWidget);

    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        AppBar fromBar = (fromHeroContext.widget as Hero).child as AppBar;

        final push = flightDirection == HeroFlightDirection.push;

        return push ? barTransition(animation, fromBar, appBar) : barTransition(animation, appBar, fromBar);
      },
      child: appBar,
    );
  }

  T _byProgress<T>(double progress, T a, T b) => progress < 0.5 ? a : b;

  Widget barTransition(Animation animation, AppBar firstBar, AppBar secondBar) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;

        return buildAppBar(
          primary: _byProgress(progress, firstBar.primary, secondBar.primary),
          toolbarHeight: ui.lerpDouble(firstBar.toolbarHeight, secondBar.toolbarHeight, progress),
          //shape: ShapeBorder.lerp(firstBar.shape, secondBar.shape, progress),
          //elevation: ui.lerpDouble(firstBar.elevation, secondBar.elevation, progress),
          backgroundColor: Color.lerp(firstBar.backgroundColor, secondBar.backgroundColor, progress),
          centerTitle: _byProgress(progress, firstBar.centerTitle, secondBar.centerTitle),
          title: _byProgress(
            progress,
            Opacity(
              opacity: 1.0 - _titleInCurve.transform(progress),
              child: SlideTransition(
                position: Tween(begin: Offset.zero, end: Offset(-1.0, 0.0)).animate(animation),
                child: firstBar.title,
              ),
            ),
            Opacity(
              opacity: _titleOutCurve.transform(progress),
              child: SlideTransition(
                position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                child: secondBar.title,
              ),
            ),
          ),
          leading: _byProgress(
            progress,
            (firstBar.leading == null
                ? null
                : Opacity(
                    opacity: 1.0 - _actionInCurve.transform(progress),
                    child: firstBar.leading,
                  )),
            (secondBar.leading == null
                ? null
                : Opacity(
                    opacity: _actionOutCurve.transform(progress),
                    child: secondBar.leading,
                  )),
          ),
          actions: _byProgress(
            progress,
            firstBar.actions
                ?.map((item) => Opacity(
                      opacity: 1.0 - _actionInCurve.transform(progress),
                      child: item,
                    ))
                ?.toList() ?? Container(),
            secondBar.actions
                ?.map((item) => Opacity(
                      opacity: _actionOutCurve.transform(progress),
                      child: item,
                    ))
                ?.toList() ?? Container(),
          ),
          bottom: buildBottom(
            animation,
            firstBar.bottom,
            secondBar.bottom,
          ),
        );
      },
    );
  }

  PreferredSizeWidget buildBottom(Animation animation, PreferredSizeWidget firstWidget, PreferredSizeWidget secondWidget) {
    if (firstWidget == null && secondWidget == null) {
      return null;
    }

    final progress = animation.value;
    final firstSize = firstWidget?.preferredSize ?? Size.zero;
    final secondSize = secondWidget?.preferredSize ?? Size.zero;

    return PreferredSize(
      child: _byProgress(
        progress,
        Opacity(
          opacity: _actionInCurve.transform(progress),
          child: firstWidget,
        ),
        Opacity(
          opacity: _actionOutCurve.transform(progress),
          child: secondWidget,
        ),
      ),
      preferredSize: Size.lerp(firstSize, secondSize, animation.value),
    );
  }

  Widget buildAppBar({
    bool primary,
    double toolbarHeight,
    ShapeBorder shape,
    double elevation,
    Color shadowColor,
    Color backgroundColor,
    Widget leading,
    Widget title,
    bool centerTitle,
    List<Widget> actions,
    PreferredSizeWidget bottom,
  }) =>
      AppBar(
        primary: primary ?? this.primary,
        toolbarHeight: toolbarHeight ?? this.toolbarHeight,
        shape: shape ?? this.shape,
        elevation: elevation ?? this.elevation,
        shadowColor: shadowColor ?? this.shadowColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        leading: leading ?? this.leading,
        title: title ?? this.title,
        centerTitle: centerTitle ?? this.centerTitle,
        actions: actions ?? this.actions,
        bottom: bottom ?? this.bottom,
      );
}
