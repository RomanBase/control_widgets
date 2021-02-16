part of widgets;

class InnerNavigator extends StatefulWidget {
  final RouteFactory onGenerateRoute;
  final List<NavigatorObserver> observers;
  final WillPopCallback onWillPop;

  const InnerNavigator({
    Key key,
    @required this.onGenerateRoute,
    this.observers,
    this.onWillPop,
  }) : super(key: key);

  factory InnerNavigator.cupertino({
    @required WidgetBuilder builder,
    List<NavigatorObserver> observers,
    WillPopCallback onWillPop,
  }) =>
      InnerNavigator(
        onGenerateRoute: (settings) => CupertinoPageRoute(builder: builder, settings: settings),
        observers: observers,
        onWillPop: onWillPop,
      );

  factory InnerNavigator.material({
    @required WidgetBuilder builder,
    List<NavigatorObserver> observers,
    WillPopCallback onWillPop,
  }) =>
      InnerNavigator(
        onGenerateRoute: (settings) => MaterialPageRoute(builder: builder, settings: settings),
        observers: observers,
        onWillPop: onWillPop,
      );

  factory InnerNavigator.card({
    @required WidgetBuilder builder,
    List<NavigatorObserver> observers,
    WillPopCallback onWillPop,
  }) =>
      InnerNavigator(
        onGenerateRoute: (settings) => ModalCardRoute(builder: builder, settings: settings),
        observers: observers,
        onWillPop: onWillPop,
      );

  @override
  _InnerNavigatorState createState() => _InnerNavigatorState();
}

class _InnerNavigatorState extends State<InnerNavigator> {
  GlobalKey<NavigatorState> _navigatorKey;

  NavigatorState get navigator => _navigatorKey?.currentState;

  HeroController _heroController;

  @override
  void initState() {
    super.initState();

    _heroController = HeroController(createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end));

    _updateNavigator();
  }

  @override
  void didUpdateWidget(InnerNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateNavigator();
  }

  void _updateNavigator() {
    _navigatorKey ??= GlobalObjectKey<NavigatorState>(this);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      key: _navigatorKey,
      observers: [
        _heroController,
        ...?widget.observers,
      ],
      onGenerateRoute: widget.onGenerateRoute,
    );

    if (widget.onWillPop != null) {
      return WillPopScope(
        onWillPop: widget.onWillPop,
        child: navigator,
      );
    }

    return navigator;
  }

  bool navigateBack() {
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return true;
    }

    return false;
  }

  void navigateToRoot() {
    if (navigator != null) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _navigatorKey = null;
    _heroController = null;
  }
}
