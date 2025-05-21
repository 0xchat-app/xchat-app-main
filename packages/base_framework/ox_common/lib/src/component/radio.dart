
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';

class CLRadio<T> extends StatelessWidget {
  const CLRadio({
    super.key,
    required this.value,
    this.groupValue,
    ValueChanged<dynamic>? onChanged,
    this.toggleable = false,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.size,
    this.autoEnable = true,
  }) : onChanged = onChanged ?? (autoEnable ? CLRadio.autoEnableChangedHandler : null);

  final T value;
  final T? groupValue;
  final ValueChanged<dynamic>? onChanged;
  final bool toggleable;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;

  final double? size;
  final bool autoEnable;

  double get defaultSize => 40.px;
  double get defaultContentSizeRatio => 24 / 40;

  static void autoEnableChangedHandler(dynamic value) {}

  @override
  Widget build(BuildContext context) {
    Widget radio;
    if (PlatformStyle.isUseMaterial) {
      radio = _buildMaterialRadio();
    } else {
      radio = _buildCupertinoRadio();
    }
    final size = this.size ?? defaultSize;
    final contentSize = size * defaultContentSizeRatio;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onChanged?.call(value);
      },
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        child: SizedBox(
          height: contentSize,
          width: contentSize,
          child: FittedBox(
            child: radio,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialRadio() {
    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      toggleable: toggleable,
      autofocus: autofocus,
      focusNode: focusNode,
      mouseCursor: mouseCursor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    );
  }

  Widget _buildCupertinoRadio() {
    return CupertinoRadio<T>(
      mouseCursor: mouseCursor,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      toggleable: toggleable,
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}