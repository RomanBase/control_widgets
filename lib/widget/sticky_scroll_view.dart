part of widgets;

class StickyControl extends ControlModel {
  final scrollPosition = ActionControl.broadcast<double>(0.0);
  final scrollOffset = ActionControl.broadcast<double>(0.0);
  final stickRatio = ActionControl.broadcast<double>(0.0);

  ScrollController _scroll;

  ScrollController get scrollController => _scroll;

  bool get isActive => _scroll != null && _scroll.hasClients;

  double height;
  double stickOffset;
  double stickSize;

  @override
  void init(Map args) {
    super.init(args);
  }

  void setController(ScrollController controller) {
    _scroll?.removeListener(_onScroll);

    _scroll = controller;
    _scroll?.addListener(_onScroll);
  }

  void _onScroll() {
    scrollPosition.value = _scroll.position.pixels;
    scrollOffset.value = -math.min(height, _scroll.offset);
    stickRatio.value = ((_scroll.position.pixels - stickOffset) / stickSize).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    super.dispose();

    scrollPosition.dispose();
    scrollOffset.dispose();
    stickRatio.dispose();

    _scroll?.removeListener(_onScroll);
    _scroll = null;
  }
}

class StickyScrollToolbar extends StatelessWidget with ThemeProvider {
  final StickyControl control;
  final String title;

  StickyScrollToolbar({
    Key key,
    @required this.control,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ControlBuilderGroup(
      controls: [control.stickRatio, control.scrollOffset],
      builder: (context, value) => Container(
        height: theme.barHeight,
        margin: EdgeInsets.only(top: (device.topBorderSize * value[0]) + ((control.height - theme.barHeight) * (1.0 - value[0])) + math.max<double>(0.0, value[1])),
        padding: EdgeInsets.symmetric(horizontal: theme.padding),
        child: Align(
          alignment: Alignment.lerp(Alignment.centerLeft, Alignment.center, value[0]),
          child: Text(
            title,
            style: TextStyle.lerp(font.headline3, font.headline6, value[0]),
          ),
        ),
      ),
    );
  }
}

class StickyScrollView extends StatefulWidget {
  final StickyControl control;
  final ScrollController controller;
  final double headerHeight;
  final Widget background;
  final Widget header;
  final Widget headerBackground;
  final PreferredSizeWidget appBar;
  final PreferredSizeWidget tabBar;
  final List<Widget> slivers;
  final double stickSize;
  final double stickOffset;
  final double parallaxRatio;
  final double overScrollRatio;
  final Curve opacityCurve;
  final Curve parallaxCurve;
  final List<Widget> children;
  final ScrollPhysics physics;

  const StickyScrollView({
    Key key,
    this.control,
    this.controller,
    this.background,
    this.header,
    this.headerBackground,
    this.appBar,
    this.tabBar,
    this.slivers,
    this.headerHeight: 280,
    this.stickSize: 192.0,
    this.stickOffset: 72.0,
    this.parallaxRatio: 0.5,
    this.overScrollRatio: 1.0,
    this.opacityCurve: Curves.easeInToLinear,
    this.parallaxCurve: Curves.linear,
    this.children,
    this.physics: const BouncingScrollPhysics(),
  })  : assert(stickOffset != null),
        assert(stickSize != null),
        super(key: key);

  factory StickyScrollView.body({
    Key key,
    StickyControl control,
    ScrollController controller,
    Widget background,
    Widget header,
    Widget headerBackground,
    PreferredSizeWidget appBar,
    PreferredSizeWidget tabBar,
    Widget body,
    double headerHeight: 280.0,
    double stickSize: 192.0,
    double stickOffset: 72.0,
    double parallaxRatio: 0.5,
    double overScrollRatio: 1.0,
    Curve opacityCurve: Curves.easeInToLinear,
    Curve parallaxCurve: Curves.linear,
    List<Widget> children,
    ScrollPhysics physics: const BouncingScrollPhysics(),
    EdgeInsets padding,
  }) =>
      StickyScrollView(
        key: key,
        control: control,
        controller: controller,
        background: background,
        header: header,
        headerBackground: headerBackground,
        appBar: appBar,
        tabBar: tabBar,
        slivers: [
          SliverPadding(
            padding: padding ?? EdgeInsets.only(top: headerHeight),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([body]),
            ),
          ),
        ],
        headerHeight: headerHeight,
        stickSize: stickSize,
        stickOffset: stickOffset,
        parallaxRatio: parallaxRatio,
        overScrollRatio: overScrollRatio,
        opacityCurve: opacityCurve,
        parallaxCurve: parallaxCurve,
        children: children,
        physics: physics,
      );

  factory StickyScrollView.builder({
    Key key,
    StickyControl control,
    ScrollController controller,
    Widget background,
    Widget header,
    Widget headerBackground,
    PreferredSizeWidget appBar,
    PreferredSizeWidget tabBar,
    int itemCount,
    @required IndexedWidgetBuilder itemBuilder,
    double headerHeight: 280.0,
    double stickSize: 192.0,
    double stickOffset: 72.0,
    double parallaxRatio: 0.5,
    double overScrollRatio: 1.0,
    Curve opacityCurve: Curves.easeInToLinear,
    Curve parallaxCurve: Curves.linear,
    List<Widget> children,
    ScrollPhysics physics: const BouncingScrollPhysics(),
    EdgeInsets padding,
  }) =>
      StickyScrollView(
        key: key,
        control: control,
        controller: controller,
        background: background,
        header: header,
        headerBackground: headerBackground,
        appBar: appBar,
        tabBar: tabBar,
        slivers: [
          SliverPadding(
            padding: padding ?? EdgeInsets.only(top: headerHeight + 8.0, bottom: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                itemBuilder,
                childCount: itemCount,
              ),
            ),
          ),
        ],
        headerHeight: headerHeight,
        stickSize: stickSize,
        stickOffset: stickOffset,
        parallaxRatio: parallaxRatio,
        overScrollRatio: overScrollRatio,
        opacityCurve: opacityCurve,
        parallaxCurve: parallaxCurve,
        children: children,
        physics: physics,
      );

  @override
  _StickyScrollViewState createState() => _StickyScrollViewState();
}

class _StickyScrollViewState extends State<StickyScrollView> {
  StickyControl control;

  double get appBarHeight => widget.appBar?.preferredSize?.height ?? 0.0;

  double get tabBarHeight => widget.tabBar?.preferredSize?.height ?? 0.0;

  double get overScrollSize => math.min(control.scrollOffset.value, control.scrollOffset.value * widget.overScrollRatio);

  @override
  void initState() {
    super.initState();

    control = widget.control ?? StickyControl();
    control.setController(widget.controller ?? ScrollController());

    control.height = widget.headerHeight;
    control.stickOffset = widget.headerHeight - widget.stickOffset;
    control.stickSize = widget.stickSize;
  }

  @override
  void didUpdateWidget(StickyScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);

    control.height = widget.headerHeight;
    control.stickOffset = widget.headerHeight - widget.stickOffset;
    control.stickSize = widget.stickSize;

    if (widget.controller != null && widget.controller != control._scroll) {
      control.setController(widget.controller);
    }

    control._onScroll();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.background != null) widget.background,
        // Header
        if (widget.headerBackground != null)
          ActionBuilderGroup(
            controls: [control.scrollOffset, control.stickRatio, control.scrollPosition],
            builder: (context, value) {
              return Transform.translate(
                offset: Offset(0.0, -control.stickSize * widget.parallaxRatio * widget.parallaxCurve.transform(value[1])),
                child: Opacity(
                  opacity: 1.0 - widget.opacityCurve.transform(value[1]),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: widget.headerHeight + math.max(0.0, overScrollSize),
                      child: widget.headerBackground,
                    ),
                  ),
                ),
              );
            },
          ),
        // Content
        CustomScrollView(
          controller: control._scroll,
          physics: widget.physics,
          slivers: widget.slivers,
        ),
        // Header
        if (widget.header != null)
          ActionBuilderGroup(
            controls: [control.scrollOffset, control.stickRatio],
            builder: (context, value) {
              return Opacity(
                opacity: 1.0 - widget.opacityCurve.transform(value[1]),
                child: SizedBox(
                  height: math.max(0.0, widget.headerHeight + overScrollSize),
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Transform.translate(
                      offset: Offset(0.0, -control.stickSize * widget.parallaxRatio * widget.parallaxCurve.transform(value[1])),
                      child: Container(
                        height: widget.headerHeight + math.max(0.0, overScrollSize),
                        child: widget.header,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        // TabBar
        if (widget.tabBar != null)
          ActionBuilder<double>(
            control: control.scrollOffset,
            builder: (context, value) {
              return Transform.translate(
                offset: Offset(0.0, widget.headerHeight - tabBarHeight + math.max(overScrollSize, -widget.headerHeight + appBarHeight + tabBarHeight)),
                child: SizedBox(
                  width: widget.tabBar.preferredSize.width,
                  height: widget.tabBar.preferredSize.height,
                  child: widget.tabBar,
                ),
              );
            },
          ),
        // Toolbar
        if (widget.appBar != null)
          SizedBox(
            width: widget.appBar.preferredSize.width,
            height: widget.appBar.preferredSize.height,
            child: ActionBuilder<double>(
              control: control.stickRatio,
              builder: (context, ratio) {
                return Opacity(
                  opacity: widget.opacityCurve.transform(ratio),
                  child: IgnorePointer(
                    ignoring: ratio < 0.1,
                    child: widget.appBar,
                  ),
                );
              },
            ),
          ),
        // Other widgets
        if (widget.children != null) ...widget.children,
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    control.dispose();
  }
}
