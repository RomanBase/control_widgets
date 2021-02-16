part of widgets;

class RoundedConvexBorder extends ContinuousRectangleBorder {
  final double radius;

  RoundedConvexBorder({this.radius: 32.0});

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path path = Path();
    path.lineTo(0, rect.height + radius);
    path.arcToPoint(Offset(radius, rect.height), radius: Radius.circular(radius));

    path.lineTo(rect.width - radius, rect.height);

    path.arcToPoint(Offset(rect.width, rect.height + radius), radius: Radius.circular(radius));

    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}
