import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

class CLTextField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialTextField();
    } else {
      return _buildCupertinoTextField();
    }
  }

  Widget _buildMaterialTextField() {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,
    );
  }

  Widget _buildCupertinoTextField() {
    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      prefix: prefixIcon,
      suffix: suffixIcon,
      readOnly: readOnly,
    );
  }
}