import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';

/// A widget that displays a decryption loading animation with lock and key icons.
/// When decryption is complete, it fades out to reveal the child widget.
class DecryptionOverlay extends StatefulWidget {
  const DecryptionOverlay({
    super.key,
    required this.child,
    this.isDecrypting = true,
    this.onAnimationComplete,
    this.backgroundColor = const Color(0xFF000000),
    this.iconTintColor = const Color(0xFFFFFFFF),
    this.lockIconSize = 40.0,
    this.keyIconSize = 32.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  /// The widget to display after decryption is complete
  final Widget child;

  /// Whether the decryption animation should be playing
  final bool isDecrypting;

  /// Callback when the animation completes
  final VoidCallback? onAnimationComplete;

  /// Background color of the overlay
  final Color backgroundColor;

  /// Color of the lock icon
  final Color iconTintColor;

  /// Size of the lock icon
  final double lockIconSize;

  /// Size of the key icon
  final double keyIconSize;

  /// Duration of the complete animation cycle
  final Duration animationDuration;

  @override
  State<DecryptionOverlay> createState() => _DecryptionOverlayState();
}

class _DecryptionOverlayState extends State<DecryptionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _lockBreathAnimation;
  late final Animation<double> _lockRotateAnimation;
  late final Animation<double> _iconsOpacityAnimation;
  late final Animation<Offset> _keySlideAnimation;
  late final Animation<double> _overlayOpacityAnimation;

  // Animation timing constants
  static const double _lockBreathStart = 0.0;
  static const double _lockBreathEnd = 0.25;
  static const double _lockRotateStart = 0.25;
  static const double _lockRotateEnd = 0.5;
  static const double _fadeOutStart = 0.25;
  static const double _fadeOutEnd = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (widget.isDecrypting) {
      _animationController.repeat(min: _lockBreathStart, max: _lockBreathEnd);
    } else {
      _animationController.value = 1.0;
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Lock breathing animation (0.9 ↔ 1.1)
    _lockBreathAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 0.9),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(_lockBreathStart, _lockBreathEnd),
    ));

    // Lock rotation animation (0 → 0.25 turns = 90°)
    _lockRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(_lockRotateStart, _lockRotateEnd),
    ));

    // Key slide animation (Offset(0,1) → Offset.zero)
    _keySlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(_lockRotateStart, _lockRotateEnd),
    ));

    // Icons opacity animation (1 → 0)
    _iconsOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(_fadeOutStart, _fadeOutEnd),
    ));

    // Overall overlay opacity animation
    _overlayOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(_fadeOutStart, _fadeOutEnd),
    ));

    // Listen for animation completion
    _animationController.addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void didUpdateWidget(DecryptionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isDecrypting != oldWidget.isDecrypting) {
      if (widget.isDecrypting) {
        _animationController.repeat(min: _lockBreathStart, max: _lockBreathEnd);
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Child widget (the actual image)
        widget.child,

        // Decryption overlay
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _overlayOpacityAnimation.value,
              child: _buildDecryptionOverlay(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDecryptionOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundMask(),
        _buildDecryptionIcons().setPaddingOnly(bottom: 20.px),
      ],
    );
  }

  Widget _buildBackgroundMask() {
    return Container(
      color: widget.backgroundColor,
    );
  }

  Widget _buildDecryptionIcons() {
    return FadeTransition(
      opacity: _iconsOpacityAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lock icon with breathing and rotation animations
          ScaleTransition(
            scale: _lockBreathAnimation,
            child: RotationTransition(
              turns: _lockRotateAnimation,
              child: Icon(
                Icons.lock_outline,
                size: widget.lockIconSize.px,
                color: widget.iconTintColor,
              ),
            ),
          ),

          // Key icon with slide animation
          // SlideTransition(
          //   position: _keySlideAnimation,
          //   child: Icon(
          //     Icons.vpn_key,
          //     size: widget.keyIconSize.px,
          //     color: widget.iconTintColor,
          //   ),
          // ),
        ],
      ),
    );
  }
}