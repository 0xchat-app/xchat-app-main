import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/widget_tool.dart';

class CLPopupMenuItem<T> {
  final T value;
  final String title;
  final Widget? icon;
  final bool enabled;
  final VoidCallback? onTap;

  const CLPopupMenuItem({
    required this.value,
    required this.title,
    this.icon,
    this.enabled = true,
    this.onTap,
  });

  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CLText.bodyMedium(
            title,
          ),
        ),
        if (icon != null)
          icon!.setPaddingOnly(left: 12)
      ],
    );
  }
}

class CLPopupMenu<T> extends StatelessWidget {
  final Widget child;
  final List<CLPopupMenuItem<T>> items;
  final T? initialValue;
  final void Function(T)? onSelected;
  final VoidCallback? onCanceled;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final bool enableFeedback;
  final Offset? offset;
  final Color? color;
  final Alignment? scaleDirection;

  const CLPopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.padding,
    this.shadowColor,
    this.surfaceTintColor,
    this.enableFeedback = true,
    this.offset,
    this.color,
    this.scaleDirection,
  });

  Offset get defaultOffset => const Offset(0, 8.0);

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialPopupMenu(context);
    } else {
      return _buildCupertinoPopupMenu(context);
    }
  }

  Widget _buildMaterialPopupMenu(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: initialValue,
      onSelected: onSelected,
      onCanceled: onCanceled,
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      enableFeedback: enableFeedback,
      offset: offset ?? defaultOffset,
      color: color,
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<T>(
          value: item.value,
          enabled: item.enabled,
          onTap: item.onTap,
          child: item.build(context),
        );
      }).toList(),
      child: child,
    );
  }

  Widget _buildCupertinoPopupMenu(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showCupertinoPopupMenu(context),
      child: child,
    );
  }

  void _showCupertinoPopupMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;
    
    final screenSize = overlay.size;
    
    const estimatedMenuWidth = 250.0;
    const estimatedMenuItemHeight = 44.0;
    final estimatedMenuHeight = items.length * estimatedMenuItemHeight;
    
    // Use the same default offset as Material design
    final effectiveOffset = offset ?? defaultOffset;
    
    // Calculate position and direction based on whether scaleDirection is provided
    double left = buttonPosition.dx + effectiveOffset.dx;
    double top = buttonPosition.dy + buttonSize.height + effectiveOffset.dy; // Default: below button
    Alignment direction = scaleDirection ?? Alignment.topLeft; // Default: expand downward
    
    if (scaleDirection != null) {
      // Use provided direction to determine position
      if (scaleDirection == Alignment.bottomLeft) {
        // Upward expansion: position menu above button
        top = buttonPosition.dy - estimatedMenuHeight - effectiveOffset.dy;
      } else if (scaleDirection == Alignment.topRight) {
        // Leftward expansion: position menu to the left of button
        left = buttonPosition.dx - estimatedMenuWidth - effectiveOffset.dx;
        top = buttonPosition.dy + effectiveOffset.dy;
      } else if (scaleDirection == Alignment.topLeft) {
        // Rightward expansion: position menu to the right of button
        left = buttonPosition.dx + buttonSize.width + effectiveOffset.dx;
        top = buttonPosition.dy + effectiveOffset.dy;
      }
      // For downward expansion (Alignment.topLeft), use default position
    } else {
      // Auto-calculate position and direction based on available space
      if (left + estimatedMenuWidth > screenSize.width) {
        left = screenSize.width - estimatedMenuWidth - 16.0;
      }
      
      if (top + estimatedMenuHeight > screenSize.height) {
        top = buttonPosition.dy - estimatedMenuHeight - effectiveOffset.dy;
      }
      
      if (left < 16.0) {
        left = 16.0;
      }
      
      if (top < 16.0) {
        top = 16.0;
      }

      // Calculate direction based on final position
      bool isExpandingUpward = top < buttonPosition.dy;
      
      // Check available space in different directions
      bool hasSpaceBelow = buttonPosition.dy + buttonSize.height + estimatedMenuHeight <= screenSize.height;
      bool hasSpaceAbove = buttonPosition.dy - estimatedMenuHeight >= 0;
      bool hasSpaceRight = buttonPosition.dx + estimatedMenuWidth <= screenSize.width;
      bool hasSpaceLeft = buttonPosition.dx - estimatedMenuWidth >= 0;
      
      if (isExpandingUpward) {
        // Menu is positioned above button, expand upward
        direction = Alignment.bottomLeft;
      } else if (!hasSpaceBelow && hasSpaceAbove) {
        // No space below but space above, expand upward
        direction = Alignment.bottomLeft;
      } else if (!hasSpaceRight && hasSpaceLeft) {
        // No space on right but space on left, expand leftward
        direction = Alignment.topRight;
      } else if (!hasSpaceLeft && hasSpaceRight) {
        // No space on left but space on right, expand rightward
        direction = Alignment.topLeft;
      } else {
        // Default: expand downward
        direction = Alignment.topLeft;
      }
    }

    // Use Overlay directly to avoid default animation of showCupertinoModalPopup
    final overlayState = Navigator.of(context).overlay!;
    late final OverlayEntry overlayEntry;
    bool isRemoved = false; // Flag to prevent duplicate removal
    final Completer<void> removalCompleter = Completer<void>(); // Track OverlayEntry removal
    
    overlayEntry = OverlayEntry(
      builder: (context) => _CupertinoPopupMenu<T>(
        items: items,
        position: Offset(left, top),
        scaleDirection: direction,
        onSelected: (value) async {
          // Wait for OverlayEntry to be completely removed before executing selection callback
          await removalCompleter.future;
          // Use SchedulerBinding to ensure the removal is complete before executing callback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelected?.call(value);
          });
        },
        onCanceled: () {
          // Safety check: ensure removal only once
          if (!isRemoved && overlayEntry.mounted) {
            isRemoved = true;
            overlayEntry.remove();
            // Complete the removal future after OverlayEntry is removed
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!removalCompleter.isCompleted) {
                removalCompleter.complete();
              }
            });
            onCanceled?.call();
          }
        },
        maxWidth: estimatedMenuWidth,
        itemHeight: estimatedMenuItemHeight,
      ),
    );
    
    overlayState.insert(overlayEntry);
  }
}

/// Cupertino popup menu implementation
class _CupertinoPopupMenu<T> extends StatefulWidget {
  final List<CLPopupMenuItem<T>> items;
  final Offset position;
  final Alignment scaleDirection;
  final Future<void> Function(T)? onSelected;
  final VoidCallback? onCanceled;
  final double maxWidth;
  final double itemHeight;

  const _CupertinoPopupMenu({
    required this.items,
    required this.position,
    required this.scaleDirection,
    this.onSelected,
    this.onCanceled,
    this.maxWidth = 250,
    this.itemHeight = 44,
  });

  @override
  State<_CupertinoPopupMenu<T>> createState() => _CupertinoPopupMenuState<T>();
}

class _CupertinoPopupMenuState<T> extends State<_CupertinoPopupMenu<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isDismissing = false; // Flag to prevent duplicate removal
  
  // Touch interaction state
  int? _hoveredIndex;
  bool _isPressed = false;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Cubic(0.175, 0.885, 0.32, 1.075),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _dismissWithAnimation({bool isSelection = false}) async {
    // Prevent duplicate calls
    if (_isDismissing) return;
    _isDismissing = true;
    
    _animationController.duration = const Duration(milliseconds: 200);

    await _animationController.reverse();
    
    // Always trigger OverlayEntry removal first
    if (mounted) {
      widget.onCanceled?.call();
    }
    
    // For non-selection dismissal, we're done
    // For selection dismissal, the actual selection callback will be handled
    // in the calling code after this Future completes
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () async {
              await _dismissWithAnimation(isSelection: false);
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                alignment: widget.scaleDirection,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildMenuContainer(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuContainer() {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context), // iOS system material
        borderRadius: BorderRadius.circular(14), // ≈ 14 pt, matches iOS 13+ menu/card style
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GestureDetector(
          onTapDown: (details) {
            final index = _getItemIndexFromPosition(details.localPosition);
            if (index != null && index >= 0 && index < widget.items.length) {
              final item = widget.items[index];
              if (item.enabled) {
                setState(() {
                  _isPressed = true;
                  _pressedIndex = index;
                });
              }
            }
          },
          onTapUp: (details) async {
            final index = _getItemIndexFromPosition(details.localPosition);
            setState(() {
              _isPressed = false;
              _pressedIndex = null;
            });
            
            if (index != null && index >= 0 && index < widget.items.length) {
              final item = widget.items[index];
              if (item.enabled) {
                await _dismissWithAnimation(isSelection: true);
                if (item.onTap != null) {
                  item.onTap?.call();
                } else if (widget.onSelected != null) {
                  await widget.onSelected?.call(item.value);
                }
              }
            }
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
              _pressedIndex = null;
            });
          },
          onPanUpdate: (details) {
            final index = _getItemIndexFromPosition(details.localPosition);
            if (index != null && index >= 0 && index < widget.items.length) {
              final item = widget.items[index];
              if (item.enabled) {
                // Check if we're switching to a new item
                if (_hoveredIndex != null && _hoveredIndex != index) {
                  // Trigger haptic feedback when switching to a new item
                  HapticFeedback.lightImpact();
                }
                setState(() {
                  _hoveredIndex = index;
                });
              } else {
                // Clear hover state when hovering over disabled item
                setState(() {
                  _hoveredIndex = null;
                });
              }
            } else {
              // Clear hover state when finger moves outside all items
              setState(() {
                _hoveredIndex = null;
              });
            }
          },
          onPanEnd: (details) {
            // Only execute selection if finger is over a valid enabled item
            if (_hoveredIndex != null && 
                _hoveredIndex! >= 0 && 
                _hoveredIndex! < widget.items.length) {
              final selectedItem = widget.items[_hoveredIndex!];
              if (selectedItem.enabled) {
                _dismissWithAnimation(isSelection: true).then((_) async {
                  if (selectedItem.onTap != null) {
                    selectedItem.onTap?.call();
                  } else if (widget.onSelected != null) {
                    await widget.onSelected?.call(selectedItem.value);
                  }
                });
              } else {
                // If hovering over disabled item, just dismiss without selection
                _dismissWithAnimation(isSelection: false);
              }
            } else {
              // If finger is outside all items, just dismiss without selection
              _dismissWithAnimation(isSelection: false);
            }
            setState(() {
              _hoveredIndex = null;
              _isPressed = false;
              _pressedIndex = null;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildMenuItem(item, isLast: index == widget.items.length - 1, index: index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(CLPopupMenuItem<T> item, {bool isLast = false, int index = 0}) {
    final isHovered = _hoveredIndex == index;
    final isPressed = _pressedIndex == index && _isPressed;
    
    return Container(
      height: widget.itemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _getHighlightColor(isHovered, isPressed, item.enabled),
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Opacity(
        opacity: item.enabled ? 1.0 : 0.5,
        child: item.build(context),
      ),
    );
  }

  int? _getItemIndexFromPosition(Offset position) {
    // Check horizontal bounds (menu width)
    if (position.dx < 0 || position.dx > widget.maxWidth) {
      return null; // Outside horizontal bounds
    }
    
    // Check vertical bounds
    final totalHeight = widget.items.length * widget.itemHeight;
    if (position.dy < 0 || position.dy > totalHeight) {
      return null; // Outside vertical bounds
    }
    
    // Calculate item index
    final itemHeight = widget.itemHeight;
    final index = (position.dy / itemHeight).floor();
    
    // Final bounds check
    if (index >= 0 && index < widget.items.length) {
      return index;
    }
    
    return null; // Outside bounds
  }

  Color _getHighlightColor(bool isHovered, bool isPressed, bool enabled) {
    if (!enabled) return Colors.transparent;
    
    if (isPressed || isHovered) {
      return CupertinoColors.systemGrey.withOpacity(0.1);
    }
    
    return Colors.transparent;
  }
}

class CLPopupMenuBuilder {
  static Widget popupMenu<T>({
    Key? key,
    required Widget child,
    required List<CLPopupMenuItem<T>> items,
    T? initialValue,
    void Function(T)? onSelected,
    VoidCallback? onCanceled,
    String? tooltip,
    EdgeInsetsGeometry? padding,
    Color? shadowColor,
    Color? surfaceTintColor,
    bool enableFeedback = true,
    Offset? offset,
    Color? color,
  }) {
    return CLPopupMenu<T>(
      key: key,
      child: child,
      items: items,
      initialValue: initialValue,
      onSelected: onSelected,
      onCanceled: onCanceled,
      tooltip: tooltip,
      padding: padding,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      enableFeedback: enableFeedback,
      offset: offset,
      color: color,
    );
  }

  static CLPopupMenuItem<T> item<T>({
    required T value,
    required String title,
    Widget? icon,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return CLPopupMenuItem<T>(
      value: value,
      title: title,
      icon: icon,
      enabled: enabled,
      onTap: onTap,
    );
  }
} 