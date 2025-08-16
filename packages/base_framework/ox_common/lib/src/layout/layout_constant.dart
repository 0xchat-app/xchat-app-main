import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

class CLLayout {
  static double get horizontalPadding => PlatformStyle.isUseMaterial
      ? 16.px
      : 20; // list_section.dart._kDefaultInsetGroupedRowsMargin

  static double get avatarRadius => 5.0;
}