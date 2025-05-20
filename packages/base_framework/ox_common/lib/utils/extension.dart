
import 'package:flutter/cupertino.dart';

extension TextEditingControllerEx on TextEditingController {
  /// The input box is assigned a value and the cursor remains on the far right
  void setText(String text) {
    this.text = text;
    this.selection = TextSelection.fromPosition(TextPosition(
      affinity: TextAffinity.downstream,
      offset: text.length,
    ));
  }
}

extension GlobalKeyEx on GlobalKey {
  double? get maxY {
    final renderObject = this.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dy + size.height;
    }
    return null;
  }
  double? get x {
    final renderObject = this.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return position.dx - (size.width / 2);
    }
    return null;
  }
  double? get y {
    final renderObject = this.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return size.height;
    }
    return null;
  }
}

extension BuildContextEx on BuildContext {
  double? get maxY {
    final renderObject = this.findRenderObject();
    if (renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dy + size.height;
    }
    return null;
  }
  double? get centerX {
    final renderObject = this.findRenderObject();
    if (renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dx + size.width / 2.0;
    }
    return null;
  }
}

extension BoolEx on bool {
  bool get not {
    return !this;
  }
}

extension ValueNotifierMap<T> on ValueNotifier<T> {
  ValueNotifier<R> map<R>(R Function(T value) mapper) {
    return _MappedValueNotifier(mapper: mapper, parentNotifier: this);
  }
}

class _MappedValueNotifier<R, T> extends ValueNotifier<R> {
  _MappedValueNotifier({
    required this.mapper,
    required this.parentNotifier,
  }) : super(mapper(parentNotifier.value)) {
    parentNotifier.addListener(listenerCallback);
  }

  final R Function(T value) mapper;
  final ValueNotifier<T> parentNotifier;

  void listenerCallback() {
    value = mapper(parentNotifier.value);
  }

  @override
  void dispose() {
    parentNotifier.removeListener(listenerCallback);
    super.dispose();
  }
}