import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';
import 'color_token.dart';

class CLSearch extends StatefulWidget implements PreferredSizeWidget {
  CLSearch({
    super.key,
    TextEditingController? controller,
    this.prefixIcon,

    this.focusNode,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,

    this.showClearButton = true,
    this.height,
    this.padding,
    this.preferredHeight,
  }) : controller = controller ?? TextEditingController();

  final TextEditingController controller;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;

  final bool showClearButton;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? preferredHeight;

  @override
  Size get preferredSize => Size.fromHeight(preferredHeight ?? (PlatformStyle.isUseMaterial ? 56.px : 36.px));

  @override
  State<CLSearch> createState() => _CLSearchState();
}

class _CLSearchState extends State<CLSearch> {
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChange([String? newText]) {
    newText ??= widget.controller.text;
    final hasText = newText.isNotEmpty;
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
    final prefixIcon = widget.prefixIcon ?? Icon(
      Icons.search,
      size: 24.px,
      color: ColorToken.onSurfaceVariant.of(context),
    );
    return Container(
      padding: widget.padding,
      child: SearchBar(
        controller: widget.controller,
        focusNode: _focusNode,
        elevation: const MaterialStatePropertyAll<double>(0.0),
        leading: Padding(
          padding: EdgeInsets.only(
            left: 12.px,
            right: 8.px,
          ),
          child: prefixIcon,
        ),
        trailing: [
          if (_hasText)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20.px,
                color: ColorToken.onSurfaceVariant.of(context),
              ),
              splashRadius: 20.px,
              onPressed: _clearText,
            )
        ],
        onChanged: (newText) {
          _onTextChange(newText);
          widget.onChanged?.call(newText);
        },
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        enabled: widget.enabled,
        autoFocus: widget.autofocus,
        hintText: widget.placeholder,
      ),
    );
  }

  Widget _buildCupertinoSearch(BuildContext context) {
    final prefixIcon = widget.prefixIcon ?? const Icon(CupertinoIcons.search);
    return Container(
      padding: widget.padding,
      child: CupertinoSearchTextField(
        controller: widget.controller,
        prefixIcon: prefixIcon,
        focusNode: _focusNode,
        onChanged: (newText) {
          _onTextChange(newText);
          widget.onChanged?.call(newText);
        },
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        placeholder: widget.placeholder,
      ),
    );
  }
}