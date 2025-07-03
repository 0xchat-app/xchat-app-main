import 'package:flutter/widgets.dart';

/// A widget that shows or hides its child with animation.
/// Similar to [Visibility] but with fade and scale animations.
class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
    this.scaleCurve = Curves.easeOutBack,
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
    this.fadeBegin = 0.0,
    this.fadeEnd = 1.0,
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
  });

  /// Whether the child is visible.
  final bool visible;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The duration of the animation.
  final Duration duration;

  /// The curve for the fade animation.
  final Curve curve;

  /// The curve for the scale animation.
  final Curve scaleCurve;

  /// Whether to maintain the state of the child when it's not visible.
  final bool maintainState;

  /// Whether to maintain the animation of the child when it's not visible.
  final bool maintainAnimation;

  /// Whether to maintain the size of the child when it's not visible.
  final bool maintainSize;

  /// Whether to maintain the semantics of the child when it's not visible.
  final bool maintainSemantics;

  /// Whether to maintain the interactivity of the child when it's not visible.
  final bool maintainInteractivity;

  /// The beginning opacity value for fade animation.
  final double fadeBegin;

  /// The ending opacity value for fade animation.
  final double fadeEnd;

  /// The beginning scale value for scale animation.
  final double scaleBegin;

  /// The ending scale value for scale animation.
  final double scaleEnd;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.fadeBegin,
      end: widget.fadeEnd,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.scaleBegin,
      end: widget.scaleEnd,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.scaleCurve,
    ));

    if (widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isVisible = _controller.value > 0.0;
        
        if (!isVisible && !widget.maintainState) {
          return const SizedBox.shrink();
        }

        Widget result = Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );

        if (!isVisible) {
          if (widget.maintainSize) {
            result = SizedBox(
              width: widget.maintainSize ? null : 0,
              height: widget.maintainSize ? null : 0,
              child: result,
            );
          }
          
          if (!widget.maintainInteractivity) {
            result = IgnorePointer(child: result);
          }
          
          if (!widget.maintainSemantics) {
            result = ExcludeSemantics(child: result);
          }
        }

        return result;
      },
    );
  }
}

/// A convenience widget that combines [AnimatedVisibility] with common settings
/// for showing/hiding widgets with a smooth animation.
class AnimatedShowHide extends StatelessWidget {
  const AnimatedShowHide({
    super.key,
    required this.show,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.maintainState = false,
  });

  /// Whether to show the child.
  final bool show;

  /// The widget to show/hide.
  final Widget child;

  /// The duration of the animation.
  final Duration duration;

  /// Whether to maintain the state of the child when hidden.
  final bool maintainState;

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: show,
      duration: duration,
      maintainState: maintainState,
      child: child,
    );
  }
} 