import 'package:flutter/cupertino.dart';
import '../enum/moment_enum.dart';

class MomentOption {
  GestureTapCallback? onTap;
  EMomentOptionType type;
  int? clickNum;

  MomentOption({
    this.onTap,
    this.clickNum,
    required this.type,
  });
}
