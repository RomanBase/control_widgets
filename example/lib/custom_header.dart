import 'dart:math';

import 'package:control_widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_control/core.dart';

class CustomHeaderPage extends ControlWidget with ThemeProvider, ControlsComponent, RouteControl {
  @override
  Initializer get initComponents => (_) => {
        'scroll': StickyControl(),
      };

  StickyControl get scroll => component['scroll'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StickyScrollView.body(
        control: scroll,
        headerHeight: theme.toolbarAreaSize.height + theme.barHeight,
        stickOffset: theme.toolbarAreaSize.height + theme.barHeight,
        stickSize: theme.barHeight,
        parallaxRatio: 1.0,
        overScrollRatio: 0.0,
        background: Container(
          height: theme.toolbarAreaSize.height,
          color: theme.accentColor,
        ),
        children: [
          ActionBuilder<double>(
            control: scroll.stickRatio,
            builder: (context, value) {
              final barHeight = scroll.height - theme.barHeight * value;

              return SizedBox(
                height: barHeight,
                child: HeroAppBar(
                  heroTag: 'slide',
                  toolbarHeight: barHeight,
                  backgroundColor: theme.accentColor,
                  elevation: 0.0,
                  shape: RoundedConvexBorder(radius: 32.0),
                  centerTitle: false,
                  primary: false,
                  title: SizedBox(
                    height: barHeight,
                    child: Stack(
                      children: [
                        // Title
                        Transform.translate(
                          offset: Offset(0.0, -Curves.easeIn.transform(value) * 24.0),
                          child: Opacity(
                            opacity: 1.0 - Curves.easeOut.transform(value),
                            child: Column(
                              children: [
                                Container(
                                  width: device.width,
                                  height: theme.barHeight - 1,
                                  margin: EdgeInsets.only(top: device.topBorderSize),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      localize('title_account'),
                                      style: font.headline6,
                                    ),
                                  ),
                                ),
                                Container(
                                  //margin: EdgeInsets.symmetric(horizontal: theme.padding),
                                  height: theme.divider,
                                  color: theme.data.dividerColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Credits
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            height: theme.barHeight,
                            child: Row(
                              children: [
                                Container(
                                  width: theme.iconSize,
                                  height: theme.iconSize,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: theme.paddingHalf,
                                ),
                                Text(
                                  '1 350 ',
                                  style: theme.font.subtitle2,
                                ),
                                Text(
                                  'credits',
                                  style: theme.font.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: device.topBorderSize + theme.paddingQuad),
                        child: IconButton(
                          icon: Icon(Icons.settings_outlined),
                          onPressed: () => openRoute(CupertinoPageRoute(builder: (context) => CustomHeaderDetailPage('slide'))),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        body: Column(
          children: [
            ...List.filled(
              30,
              Container(
                height: 96.0,
                margin: EdgeInsets.symmetric(horizontal: theme.padding, vertical: theme.paddingHalf),
                color: Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)),
                child: FlatButton(
                  onPressed: () => openRoute(ModalCardRoute(
                      builder: (_) => InnerNavigator.cupertino(
                            builder: (context) => CustomHeaderDetailPage('slide_on_card'),
                          ))),
                  child: Container(),
                ),
              ),
            ),
            SizedBox(
              height: theme.paddingHalf,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomHeaderDetailPage extends ControlWidget with RouteControl {
  final Object heroTag;

  CustomHeaderDetailPage(this.heroTag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeroAppBar(
        heroTag: this.heroTag,
        backgroundColor: Colors.red,
        elevation: 6.0,
        centerTitle: true,
        title: Text('title of the detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => openRoute(CupertinoPageRoute(builder: (context) => CustomHeaderDetailPage(heroTag))),
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: 96.0,
          color: Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)),
          margin: EdgeInsets.symmetric(horizontal: 96.0),
          child: FlatButton(
            onPressed: () => openRoute(ModalCardRoute(builder: (_) => CustomHeaderDetailPage('card'))),
            child: Container(),
          ),
        ),
      ),
    );
  }
}
