
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';

class CLSwitch extends StatelessWidget {
  const CLSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.size,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  final Size? size;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialSwitch();
    } else {
      return _buildCupertinoSwitch();
    }
  }

  Widget _buildMaterialSwitch() {
    final size = this.size ?? Size(52.px, 32.px); // _SwitchConfigM3.switchWidth / switchHeight
    return SizedBox.fromSize(
      size: size,
      child: Switch(
        value: value,
        onChanged: onChanged,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCupertinoSwitch() {
    final size = this.size ?? Size(51.px, 31.px);
    final scaleX = size.width / 51.0; // _kTrackWidth
    final scaleY = size.height / 31.0; // _kTrackHeight
    return SizedBox.fromSize(
      size: size,
      child: Transform.scale(
        scaleX: scaleX,
        scaleY: scaleY,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}