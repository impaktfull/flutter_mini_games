import 'package:flutter/widgets.dart';

/// A text painter for a `CustomPainter` that repaints every frame: the text is only laid out
/// again when the text or the style changes.
///
/// Owned by a `State` (create it there, pass it to the painter, [dispose] it in `dispose`).
class CachedTextPainter {
  final TextPainter _painter = TextPainter(textDirection: TextDirection.ltr);
  String? _text;
  TextStyle? _style;

  /// The laid out painter for [text] in [style]
  TextPainter layout(String text, TextStyle style) {
    if (text != _text || style != _style) {
      _text = text;
      _style = style;
      _painter
        ..text = TextSpan(text: text, style: style)
        ..layout();
    }
    return _painter;
  }

  void dispose() => _painter.dispose();
}
