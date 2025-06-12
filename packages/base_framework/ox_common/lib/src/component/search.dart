import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';
import 'color_token.dart';

class CLSearch extends StatefulWidget {
  CLSearch({
    super.key,
    TextEditingController? controller,
    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.showSearchIcon = true,
    this.showClearButton = true,
    this.height,
    this.padding,
  }) : controller = controller ?? TextEditingController();

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;
  final bool showSearchIcon;
  final bool showClearButton;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  State<CLSearch> createState() => _CLSearchState();
}

class _CLSearchState extends State<CLSearch> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasFocus = _focusNode.hasFocus;
    _hasText = widget.controller.text.isNotEmpty;
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _clearText() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialSearch(context);
    } else {
      return _buildCupertinoSearch(context);
    }
  }

  Widget _buildMaterialSearch(BuildContext context) {
    final padding = widget.padding ?? EdgeInsets.symmetric(vertical: 12.px);
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(
        fontSize: 16.px,
        color: ColorToken.onSurface.of(context),
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(
          fontSize: 16.px,
          color: ColorToken.onSurfaceVariant.of(context),
        ),
        prefixIcon: widget.showSearchIcon
            ? Padding(
                padding: EdgeInsets.only(left: 16.px, right: 8.px),
                child: Icon(
                  Icons.search,
                  size: 24.px,
                  color: ColorToken.onSurfaceVariant.of(context),
                ),
              )
            : null,
        prefixIconConstraints: BoxConstraints(minHeight: 24.px, minWidth: 24.px),
        suffixIcon: widget.showClearButton && _hasText
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20.px,
                  color: ColorToken.onSurfaceVariant.of(context),
                ),
                splashRadius: 20.px,
                onPressed: _clearText,
              )
            : null,
        filled: true,
        fillColor: ColorToken.surfaceContainer.of(context),
        isDense: true,
        contentPadding: padding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000), // pill shape
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000),
          borderSide: BorderSide(
            color: ColorToken.primary.of(context),
            width: 1.5.px,
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoSearch(BuildContext context) {
    // Cupertino official search field: 36pt height, pill shape (radius 10)
    final height = widget.height ?? 36.px;

    final backgroundColor = CupertinoColors.systemGrey5.resolveFrom(context);

    return Container(
      height: height,
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 8.px),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.px),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showSearchIcon) ...[
            Icon(
              CupertinoIcons.search,
              size: 20.px,
              color: ColorToken.onSurfaceVariant.of(context),
            ),
            SizedBox(width: 6.px),
          ],
          Expanded(
            child: CupertinoTextField(
              controller: widget.controller,
              focusNode: _focusNode,
              placeholder: widget.placeholder,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              decoration: null,
              padding: EdgeInsets.zero,
              style: TextStyle(
                fontSize: 16.px,
                color: ColorToken.onSurface.of(context),
              ),
              placeholderStyle: TextStyle(
                fontSize: 16.px,
                color: ColorToken.onSurfaceVariant.of(context),
              ),
            ),
          ),
          if (widget.showClearButton && _hasText) ...[
            SizedBox(width: 6.px),
            GestureDetector(
              onTap: _clearText,
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                size: 20.px,
                color: ColorToken.onSurfaceVariant.of(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 