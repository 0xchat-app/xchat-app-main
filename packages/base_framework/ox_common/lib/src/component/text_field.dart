import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';

import 'platform_style.dart';
import 'color_token.dart';

class CLTextField extends StatefulWidget {
  CLTextField({
    super.key,
    TextEditingController? controller,
    this.focusNode,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.initialText,
    this.readOnly = false,
  }) : controller = controller ?? TextEditingController() {
    if (initialText != null) {
      this.controller.text = initialText!;
    }
  }

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? placeholder; // Material -> InputDecoration.hintText
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon; // Cupertino: prefix; Material: prefixIcon
  final Widget? suffixIcon; // Cupertino: suffix; Material: suffixIcon
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final int? maxLines;
  final bool enabled;
  final bool autofocus;
  final String? initialText;
  final bool readOnly;

  @override
  State<CLTextField> createState() => _CLTextFieldState();
}

class _CLTextFieldState extends State<CLTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
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

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialTextField();
    } else {
      return _buildCupertinoTextField(context);
    }
  }

  Widget _buildMaterialTextField() {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.placeholder,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
      ),
      readOnly: widget.readOnly,
    );
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    return CupertinoTextField(
      controller: widget.controller,
      focusNode: _focusNode,
      placeholder: widget.placeholder,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      prefix: widget.prefixIcon,
      suffix: widget.suffixIcon,
      readOnly: widget.readOnly,
              decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.px),
          border: Border.all(
            color: _hasFocus 
                ? ColorToken.primary.of(context) 
                : ColorToken.onSurfaceVariant.of(context),
            width: 2.px,
          ),
        ),
      padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 12.px),
    );
  }
}