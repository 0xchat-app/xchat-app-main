
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

class CLTextField extends StatelessWidget {
  const CLTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;                 // Material -> InputDecoration.hintText
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;                  // Cupertino: prefix; Material: prefixIcon
  final Widget? suffixIcon;                  // Cupertino: suffix; Material: suffixIcon
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final bool enabled;
  final bool autofocus;

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
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCupertinoTextField() {
    return CupertinoTextField(
      controller: controller,
      focusNode: focusNode,
      placeholder: placeholder,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      prefix: prefixIcon,
      suffix: suffixIcon,
    );
  }
}