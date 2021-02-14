part of widgets;

Curve _showActionCurve = Curves.linear.from(0.875);
Curve _hideActionCurve = Curves.linear.from(0.95);
Curve _showTitleCurve = Curves.linear.from(0.875);
Curve _hideTitleCurve = Curves.linear.from(0.95);

const _defaultHeroTag = HeroAppBar;

class HeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Object heroTag;
  final bool primary;
  final Color backgroundColor;
  final double elevation;
  final double height;
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
    this.height: kToolbarHeight,
    this.shadowColor,
    this.shape,
    this.leading,
    this.title,
    this.centerTitle: false,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize?.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading ??
        (ModalRoute.of(context).isFirst
            ? null
            : IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: () => Navigator.of(context).pop(),
              ));

    return Hero(
      tag: heroTag,
      transitionOnUserGestures: true,
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
        AppBar fromBar = (fromHeroContext.widget as Hero).child as AppBar;

        final push = flightDirection == HeroFlightDirection.push;

        return push ? pushTransition(animation, fromBar, leadingWidget) : popTransition(animation, fromBar, leadingWidget);
      },
      child: buildAppBar(
        title: title,
        color: backgroundColor,
        leading: leadingWidget,
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  Widget pushTransition(Animation animation, AppBar fromBar, Widget leading) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;

          return buildAppBar(
            color: Color.lerp(fromBar.backgroundColor, backgroundColor, progress),
            title: Stack(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              children: [
                Opacity(
                  opacity: 1.0 - progress,
                  child: SlideTransition(
                    position: Tween(begin: Offset.zero, end: Offset(-1.0, 0.0)).animate(animation),
                    child: fromBar.title,
                  ),
                ),
                Opacity(
                  opacity: progress,
                  child: SlideTransition(
                    position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                    child: title,
                  ),
                ),
              ],
            ),
            leading: progress > 0.5
                ? (leading == null
                    ? null
                    : Opacity(
                        opacity: _showActionCurve.transform(progress),
                        child: leading,
                      ))
                : (fromBar.leading == null
                    ? null
                    : Opacity(
                        opacity: _hideActionCurve.transform(1.0 - progress),
                        child: fromBar.leading,
                      )),
            actions: progress > 0.5
                ? actions
                    ?.map((item) => Opacity(
                          opacity: _showActionCurve.transform(progress),
                          child: item,
                        ))
                    ?.toList()
                : fromBar.actions
                    ?.map((item) => Opacity(
                          opacity: _hideActionCurve.transform(1.0 - progress),
                          child: item,
                        ))
                    ?.toList(),
            bottom: buildBottom(
              animation,
              bottom,
              fromBar.bottom,
            ),
          );
        });
  }

  Widget popTransition(Animation animation, AppBar fromBar, Widget leading) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = animation.value;

          return buildAppBar(
            color: Color.lerp(fromBar.backgroundColor, backgroundColor, 1.0 - progress),
            title: Stack(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              children: [
                Opacity(
                  opacity: 1.0 - progress,
                  child: SlideTransition(
                    position: Tween(begin: Offset.zero, end: Offset(-1.0, 0.0)).animate(animation),
                    child: title,
                  ),
                ),
                Opacity(
                  opacity: progress,
                  child: SlideTransition(
                    position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
                    child: fromBar.title,
                  ),
                ),
              ],
            ),
            leading: progress > 0.5
                ? (fromBar.leading == null
                    ? null
                    : Opacity(
                        opacity: _hideActionCurve.transform(progress),
                        child: fromBar.leading,
                      ))
                : (leading == null
                    ? null
                    : Opacity(
                        opacity: _showActionCurve.transform(1.0 - progress),
                        child: leading,
                      )),
            actions: progress > 0.5
                ? fromBar.actions
                    ?.map((item) => Opacity(
                          opacity: _hideActionCurve.transform(progress),
                          child: item,
                        ))
                    ?.toList()
                : actions
                    ?.map((item) => Opacity(
                          opacity: _showActionCurve.transform(1.0 - progress),
                          child: item,
                        ))
                    ?.toList(),
            bottom: buildBottom(
              animation,
              fromBar.bottom,
              bottom,
            ),
          );
        });
  }

  PreferredSizeWidget buildBottom(Animation animation, PreferredSizeWidget firstWidget, PreferredSizeWidget secondWidget) {
    if (firstWidget == null && secondWidget == null) {
      return null;
    }

    final progress = animation.value;
    final firstSize = firstWidget?.preferredSize ?? Size.zero;
    final secondSize = secondWidget?.preferredSize ?? Size.zero;

    return PreferredSize(
      child: progress > 0.5
          ? Opacity(
              opacity: _hideActionCurve.transform(progress),
              child: firstWidget,
            )
          : Opacity(
              opacity: _showActionCurve.transform(1.0 - progress),
              child: secondWidget,
            ),
      preferredSize: Size.lerp(firstSize, secondSize, animation.value),
    );
  }

  Widget buildAppBar({
    @required Widget title,
    @required Color color,
    Widget leading,
    List<Widget> actions,
    PreferredSizeWidget bottom,
  }) =>
      AppBar(
        primary: primary,
        toolbarHeight: height,
        shape: shape,
        elevation: elevation,
        shadowColor: shadowColor,
        backgroundColor: color,
        leading: leading,
        title: title,
        centerTitle: centerTitle,
        actions: actions,
        bottom: bottom,
      );
}
