
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/font_size_notifier.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TextScaleSlider extends StatefulWidget {
  final ValueChanged<double>? onChanged;

  const TextScaleSlider({super.key, this.onChanged});

  @override
  State<TextScaleSlider> createState() => _TextScaleSliderState();
}

class _TextScaleSliderState extends State<TextScaleSlider> {

  double _currentValue = 0;
  final double min = 0.9;
  final double max = 1.6;
  final double step = 0.1;
  bool _hasVibrator = false;

  @override
  void initState() {
    super.initState();
    _isHasVibrator();
    _initCurrentValue();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.px),
        color: ColorToken.surfaceContainer.of(context),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.px),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CLText.bodyLarge('Text Size',),
              CLText.bodyLarge(getFormattedTextSize(_currentValue),),
            ],
          ).setPadding(EdgeInsets.symmetric(horizontal: 16.px)),
          SfSlider(
            value: _currentValue * 10,
            min: min * 10,
            max: max * 10,
            showTicks: true,
            showDividers: true,
            interval: 1,
            stepSize: 1,
            onChanged: sliderOnChange,
          ),
          // Slider.adaptive(
          //   value: _currentValue * 10,
          //   min: min * 10,
          //   max: max * 10,
          //   divisions: 6,
          //   onChanged: sliderOnChange,
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CLText.bodyLarge('A'),
              CLText.headlineSmall('A'),
            ],
          ).setPadding(EdgeInsets.symmetric(horizontal: 16.px)),
        ],
      ),
    );
  }

  _initCurrentValue() {
    //Error prevention
    if (textScaleFactorNotifier.value < min) {
      _currentValue = min;
    } else if (textScaleFactorNotifier.value > max) {
      _currentValue = max;
    } else {
      _currentValue = textScaleFactorNotifier.value;
    }
  }

  int _getDivisions() {
    return ((max - min) / step).ceil() - 1;
  }

  double _roundToStep(double value) {
    return (value - min) / step > 0
        ? (step * ((value - min) / step).round()) + min
        : min;
  }

  _isHasVibrator() async {
    if(!PlatformUtils.isMobile) return;
    _hasVibrator = await Vibrate.canVibrate;
    setState(() {});
  }

  void sliderOnChange(value) {
    final scale = value / 10;
    double newValue = double.parse(_roundToStep(scale).toStringAsFixed(1));
    if (newValue == _currentValue) return;
    if (_hasVibrator && OXUserInfoManager.sharedInstance.canVibrate &&
        newValue != _currentValue) {
      TookKit.vibrateEffect();
    }
    setState(() {
      _currentValue = newValue;
      widget.onChanged?.call(scale);
    });
  }
}
