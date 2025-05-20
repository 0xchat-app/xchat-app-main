
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';

class CLCheckbox extends StatelessWidget {
  const CLCheckbox({
    super.key,
    required this.value,
    this.tristate = false,
    this.onChanged,
    this.size,
  });

  final bool? value;
  final bool tristate;
  final ValueChanged<bool?>? onChanged;

  final double? size;

  double get defaultSize => 40.px;
  double get defaultContentSizeRatio => Checkbox.width / 40;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialCheckbox();
    } else {
      return _buildCupertinoCheckbox();
    }
  }

  Widget _buildMaterialCheckbox() {
    final size = this.size ?? defaultSize;
    final contentSize = size * defaultContentSizeRatio;
    final scale = contentSize / Checkbox.width;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onChanged?.call(value);
      },
      child: Container(
        height: size,
        width: size,
        alignment: Alignment.center,
        child: Transform.scale(
          scale: scale,
          child: Checkbox(
            value: value,
            tristate: tristate,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoCheckbox() {
    final size = this.size ?? defaultSize;
    final contentSize = size * defaultContentSizeRatio;
    final scale = contentSize / CupertinoCheckbox.width;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: CupertinoCheckbox(
          value: value,
          tristate: tristate,
          onChanged: onChanged,
        ),
      ),
    );
  }
}