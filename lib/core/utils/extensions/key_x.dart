import 'package:flutter/cupertino.dart';

extension GlobalKeyX<T extends State<StatefulWidget>> on GlobalKey<T> {
  // Given a GlobalKey, return the Rect of the corresponding RenderBox's
  // paintBounds in global coordinates.
  Rect getRect() {
    if (currentContext == null) {
      return Rect.zero;
    }
    assert(currentContext != null, 'GlobalKey.currentContext is null');
    final RenderBox renderBoxContainer = currentContext!.findRenderObject()! as RenderBox;
    return Rect.fromPoints(
      renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      ),
      renderBoxContainer.localToGlobal(renderBoxContainer.paintBounds.bottomRight),
    );
  }
}
