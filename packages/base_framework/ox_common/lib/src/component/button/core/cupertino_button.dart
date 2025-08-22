import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/utils/color_extension.dart';

enum _CLCupertinoButtonStyle {
  plain,
  tinted,
  filled,
}

class CLCupertinoButton extends StatefulWidget {
  const CLCupertinoButton({
    super.key,
    required this.child,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.gradient,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.onLongPress,
    required this.onPressed,
  }) : _style = _CLCupertinoButtonStyle.plain;

  const CLCupertinoButton.tinted({
    super.key,
    required this.child,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.gradient,
    this.disabledColor = CupertinoColors.tertiarySystemFill,
    this.minSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.onLongPress,
    required this.onPressed,
  }) : _style = _CLCupertinoButtonStyle.tinted;

  const CLCupertinoButton.filled({
    super.key,
    required this.child,
    this.sizeStyle = CupertinoButtonSize.large,
    this.padding,
    this.color,
    this.gradient,
    this.disabledColor = CupertinoColors.tertiarySystemFill,
    this.minSize,
    this.pressedOpacity = 0.4,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.focusColor,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.onLongPress,
    required this.onPressed,
  }) : _style = _CLCupertinoButtonStyle.filled;

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Color disabledColor;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final CupertinoButtonSize sizeStyle;
  final EdgeInsetsGeometry? padding;
  final double? minSize;
  final double? pressedOpacity;
  final BorderRadius? borderRadius;
  final AlignmentGeometry alignment;
  final Color? focusColor;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final _CLCupertinoButtonStyle _style;

  bool get enabled => onPressed != null || onLongPress != null;

  @override
  State<CLCupertinoButton> createState() => _CLCupertinoButtonState();
}

class _CLCupertinoButtonState extends State<CLCupertinoButton>
    with SingleTickerProviderStateMixin {
  static const Duration _kFadeOutDuration = Duration(milliseconds: 120);
  static const Duration _kFadeInDuration = Duration(milliseconds: 180);

  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);
  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _heldDown = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _opacity = _controller.drive(CurveTween(curve: Curves.decelerate)).drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(CLCupertinoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    if (_controller.isAnimating) return;
    final wasHeld = _heldDown;
    final future = _heldDown
        ? _controller.animateTo(
      1.0,
      duration: _kFadeOutDuration,
      curve: Curves.easeInOutCubicEmphasized,
    )
        : _controller.animateTo(
      0.0,
      duration: _kFadeInDuration,
      curve: Curves.easeOutCubic,
    );
    future.then<void>((_) {
      if (!mounted) return;
      if (wasHeld != _heldDown) _animate();
    });
  }

  void _handleTapDown(TapDownDetails _) {
    if (!_heldDown) {
      _heldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (_heldDown) {
      _heldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_heldDown) {
      _heldDown = false;
      _animate();
    }
  }

  void _onShowFocusHighlight(bool show) {
    setState(() => _isFocused = show);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final theme = CupertinoTheme.of(context);
    final primary = theme.primaryColor;

    final bool useGradient = widget.gradient != null;

    double? tintedOpacity;
    if (widget._style == _CLCupertinoButtonStyle.tinted) {
      final isLight = CupertinoTheme.brightnessOf(context) == Brightness.light;
      tintedOpacity = isLight ? kCupertinoButtonTintedOpacityLight : kCupertinoButtonTintedOpacityDark;
    }

    final Color computedForeground = () {
      if (widget._style == _CLCupertinoButtonStyle.filled && useGradient) {
        return theme.primaryContrastingColor;
      }
      return enabled
          ? primary
          : CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, context);
    }();

    final Color effectiveFocusOutlineColor = widget.focusColor ??
        HSLColor.fromColor(
          (widget.color ?? CupertinoColors.activeBlue).withOpacity(kCupertinoFocusColorOpacity),
        )
            .withLightness(kCupertinoFocusColorBrightness)
            .withSaturation(kCupertinoFocusColorSaturation)
            .toColor();

    final TextStyle textStyle = (widget.sizeStyle == CupertinoButtonSize.small
        ? theme.textTheme.actionSmallTextStyle
        : theme.textTheme.actionTextStyle)
        .copyWith(color: computedForeground);
    final IconThemeData iconTheme = IconTheme.of(context).copyWith(
      color: computedForeground,
      size: (textStyle.fontSize ?? 17) * 1.2,
    );

    BoxDecoration _buildDecoration() {
      final borderRadius =
          widget.borderRadius ?? kCupertinoButtonSizeBorderRadius[widget.sizeStyle] ?? const BorderRadius.all(Radius.circular(16));

      if (!enabled) {
        // if (useGradient && useDisabledGradient) {
        //   return BoxDecoration(gradient: widget.disabledGradient, borderRadius: borderRadius);
        // }
        if (useGradient) {
          return BoxDecoration(
            gradient: widget.gradient!.toGray(),
            borderRadius: borderRadius,
            color: CupertinoDynamicColor.resolve(widget.disabledColor, context).withOpacity(0.35),
          );
        }
        if (widget.color != null) {
          return BoxDecoration(
            color: CupertinoDynamicColor.resolve(widget.disabledColor, context),
            borderRadius: borderRadius,
          );
        }
        return BoxDecoration(borderRadius: borderRadius);
      }

      if (useGradient) {
        final Gradient g = (tintedOpacity != null)
            ? widget.gradient!.toOpacity(tintedOpacity)
            : widget.gradient!;
        return BoxDecoration(gradient: g, borderRadius: borderRadius);
      }

      if (widget.color != null || widget._style != _CLCupertinoButtonStyle.plain) {
        final Color base = (widget.color ?? primary);
        final Color bg = (tintedOpacity != null)
            ? base.withOpacity(tintedOpacity)
            : base;
        return BoxDecoration(color: bg, borderRadius: borderRadius);
      }

      return BoxDecoration(borderRadius: borderRadius);
    }

    final BoxDecoration decoration = _buildDecoration();

    return MouseRegion(
      cursor: enabled && kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onFocusChange: widget.onFocusChange,
        onShowFocusHighlight: _onShowFocusHighlight,
        enabled: enabled,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            if (widget.onPressed != null) {
              widget.onPressed!();
              context.findRenderObject()?.sendSemanticsEvent(const TapSemanticEvent());
            }
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? _handleTapDown : null,
          onTapUp: enabled ? _handleTapUp : null,
          onTapCancel: enabled ? _handleTapCancel : null,
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          child: Semantics(
            button: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:
                  widget.minSize ??
                  kCupertinoButtonMinSize[widget.sizeStyle] ??
                  kMinInteractiveDimensionCupertino,
                minHeight:
                  widget.minSize ??
                  kCupertinoButtonMinSize[widget.sizeStyle] ??
                  kMinInteractiveDimensionCupertino,
              ),
              child: FadeTransition(
                opacity: _opacity,
                child: DecoratedBox(
                  decoration: decoration.copyWith(
                    border: enabled && _isFocused
                        ? Border.fromBorderSide(
                      BorderSide(
                        color: effectiveFocusOutlineColor,
                        width: 3.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    )
                        : null,
                  ),
                  child: Padding(
                    padding: widget.padding ?? kCupertinoButtonPadding[widget.sizeStyle]!,
                    child: Align(
                      alignment: widget.alignment,
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: DefaultTextStyle(
                        style: textStyle,
                        child: IconTheme(
                          data: iconTheme,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}