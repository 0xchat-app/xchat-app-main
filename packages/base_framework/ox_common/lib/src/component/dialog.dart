import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'button.dart';
import 'color_token.dart';
import 'text.dart';
import 'text_field.dart';

class CLDialog {
  /// Show a bottom sheet input dialog that slides up from the bottom
  /// 
  /// This creates a modal bottom sheet with an input field that:
  /// - Automatically focuses the input field when shown
  /// - Adjusts spacing to stick to the keyboard when shown
  /// - Uses native Flutter bottom sheet animation
  /// - Supports async validation and loading states
  /// 
  /// [context] BuildContext
  /// [title] Dialog title
  /// [description] Optional description text (supports multi-line)
  /// [inputLabel] Input field placeholder text
  /// [confirmText] Confirm button text, defaults to localized "Confirm"
  /// [cancelText] Cancel button text (currently not used as only confirm button is shown)
  /// [initialValue] Initial value for input field
  /// [validator] Optional input validator function
  /// [onConfirm] Async callback when confirm button is pressed, receives input value, returns success boolean
  /// [onCancel] Optional callback when dialog is dismissed
  /// 
  /// Returns the input value if confirmed, null if cancelled
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? description,
    required String inputLabel,
    String? confirmText,
    String? cancelText,
    String? initialValue,
    String? Function(String?)? validator,
    Future<bool> Function(String)? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InputBottomSheet(
        title: title,
        description: description,
        inputLabel: inputLabel,
        confirmText: confirmText,
        cancelText: cancelText,
        initialValue: initialValue,
        validator: validator,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

class InputBottomSheet extends StatefulWidget {
  const InputBottomSheet({
    Key? key,
    required this.title,
    this.description,
    required this.inputLabel,
    this.confirmText,
    this.cancelText,
    this.initialValue,
    this.validator,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  final String title;
  final String? description;
  final String inputLabel;
  final String? confirmText;
  final String? cancelText;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Future<bool> Function(String)? onConfirm;
  final VoidCallback? onCancel;

  @override
  State<InputBottomSheet> createState() => _InputBottomSheetState();
}

class _InputBottomSheetState extends State<InputBottomSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorText;

  double get horizontal => 16.px;
  double get separatorHeight => 20.px;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    // Auto focus after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorToken.surface.of(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.px),
            topRight: Radius.circular(20.px),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                children: [
                  Expanded(
                    child: CLText.headlineSmall(
                      widget.title,
                    ).setPadding(EdgeInsets.all(horizontal)),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _handleCancel,
                    child: Container(
                      width: 48.px,
                      height: 48.px,
                      child: Icon(
                        Icons.close,
                        size: 24.px,
                        color: ColorToken.onSurface.of(context),
                      ),
                    ),
                  ).setPaddingOnly(right: 4.px),
                ],
              ),

              SizedBox(height: 8.px),

              // Description
              if (widget.description != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: CLText.titleSmall(
                    widget.description!,
                    colorToken: ColorToken.onSurfaceVariant,
                    maxLines: 10,
                  ),
                ).setPaddingOnly(bottom: separatorHeight),
              
              // Input field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CLTextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        placeholder: widget.inputLabel,
                        enabled: !_isLoading,
                        onChanged: (value) {
                          if (_errorText != null) {
                            setState(() {
                              _errorText = null;
                            });
                          }
                        },
                      ),
                      if (_errorText != null) ...[
                        SizedBox(height: 8.px),
                        CLText.bodySmall(
                          _errorText!,
                          colorToken: ColorToken.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ).setPaddingOnly(bottom: separatorHeight),

              // Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: CLButton.filled(
                  text: widget.confirmText ?? Localized.text('ox_common.confirm'),
                  onTap: _isLoading ? null : _handleConfirm,
                  expanded: true,
                  height: 48.px,
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(bottom: 24.px),
                  child: Center(
                    child: SizedBox(
                      width: 20.px,
                      height: 20.px,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.px,
                        color: ColorToken.primary.of(context),
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 16.px),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  Future<void> _handleConfirm() async {
    final input = _controller.text.trim();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (input.isEmpty) {
      setState(() {
        _errorText = Localized.text('ox_common.input_cannot_be_empty');
      });
      return;
    }

    // Call onConfirm callback if provided
    if (widget.onConfirm != null) {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      try {
        final success = await widget.onConfirm!(input);
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(input);
          } else {
            setState(() {
              _isLoading = false;
              _errorText = Localized.text('ox_common.operation_failed');
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorText = e.toString();
          });
        }
      }
    } else {
      Navigator.of(context).pop(input);
    }
  }
} 