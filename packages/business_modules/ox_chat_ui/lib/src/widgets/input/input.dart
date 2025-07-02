import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/platform_utils.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';

import '../../models/giphy_image.dart';
import '../../models/input_clear_mode.dart';
import '../../models/send_button_visibility_mode.dart';
import '../state/inherited_chat_theme.dart';
import 'attachment_button.dart';
import 'input_face_page.dart';
import 'input_more_page.dart';
import 'input_text_field_controller.dart';
import 'input_voice_page.dart';
import 'send_button.dart';


/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  const Input({
    super.key,
    required this.items,
    this.chatId,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onSendPressed,
    this.options = const InputOptions(),
    this.onVoiceSend,
    this.textFieldHasFocus,
    this.onGifSend,
    this.inputBottomView,
    this.onFocusNodeInitialized,
    this.onInsertedContent,
    this.customInputViewChanged,
  });

  final String? chatId;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// See [AttachmentButton.onPressed].
  final VoidCallback? onAttachmentPressed;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final Future<bool> Function(types.PartialText) onSendPressed;

  ///Send a voice message
  final void Function(String path, Duration duration)? onVoiceSend;

  final VoidCallback? textFieldHasFocus;

  final ValueChanged<FocusNode>? onFocusNodeInitialized;

  /// Customisation options for the [Input].
  final InputOptions options;

  final List<InputMoreItem> items;

  ///Send a gif message
  final void Function(GiphyImage giphyImage)? onGifSend;

  ///Send a inserted content
  final void Function(KeyboardInsertedContent insertedContent)? onInsertedContent;

  final void Function(InputType inputType)? customInputViewChanged;

  final Widget? inputBottomView;

  @override
  State<Input> createState() => InputState();
}

/// [Input] widget state.
class InputState extends State<Input> {

  double get _itemSpacing => 8.px;
  double get iconSize => 24.pxWithTextScale;
  double get iconButtonSize => 40.pxWithTextScale;
  double get containerHeight => 88.px;
  double get inputContainerHeight => 56.px;
  double get containerHorPadding => 16.px;

  InputType inputType = InputType.inputTypeDefault;
  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
            (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        final isComposing = _textController.value.composing.isValid;
        if (event is KeyDownEvent && !isComposing) {
          _handleSendPressed();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
  );
  bool get isOnInput =>
      (inputType == InputType.inputTypeText && _inputFocusNode.hasFocus)
      || inputType == InputType.inputTypeEmoji;
  bool _sendButtonVisible = false;
  late TextEditingController _textController;

  final _keyboardHeightPlugin = KeyboardHeightPlugin();

  Curve get animationCurves => Curves.ease;
  Duration get animationDuration => Duration(milliseconds: 200);

  double _pluginKeyboardHeight = 0.0;

  void dismissMoreView(){
    changeInputType(InputType.inputTypeDefault);
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.sendButtonVisibilityMode !=
        oldWidget.options.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        widget.textFieldHasFocus?.call();
      }
    });
    _textController =
        widget.options.textEditingController ?? InputTextFieldController();
    _handleSendButtonVisibilityModeChange();
    widget.onFocusNodeInitialized?.call(_inputFocusNode);
    _keyboardHeightPlugin.onKeyboardHeightChanged((height) {
      if (!mounted) return;
      if (height < 1) return;

      if (_pluginKeyboardHeight != height) _pluginKeyboardHeight = height;

      // Change input type to text mode after keyboard height is detected
      // This prevents UI flickering that occurs when changing input type
      // before keyboard height is available
      changeInputType(InputType.inputTypeText);
    });
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: ColorToken.surfaceContainer.of(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildInputExtensionWidget(),
          defaultInputWidget(),
          _buildBottomPanel(),
        ],
      ),
    );

  Widget buildInputExtensionWidget() => Padding(
    padding: EdgeInsets.only(
      left: containerHorPadding,
      right: containerHorPadding,
    ),
    child: widget.inputBottomView,
  );

  // Calculate height of custom panels (emoji / more / voice)
  double _getCustomPanelHeight() {
    switch (inputType) {
      case InputType.inputTypeEmoji:
        return 360;
      case InputType.inputTypeMore:
      case InputType.inputTypeVoice:
        return 202;
      case InputType.inputTypeText:
        return max(_pluginKeyboardHeight, 0);
      default:
        return 0;
    }
  }

  // Build the custom panel widget corresponding to current InputType
  Widget? _getCustomPanelWidget() {
    if (inputType == InputType.inputTypeMore) {
      return InputMorePage(items: widget.items);
    } else if (inputType == InputType.inputTypeEmoji) {
      return InputFacePage(textController: _textController);
    } else if (inputType == InputType.inputTypeVoice) {
      return InputVoicePage(
        onPressed: (_path, duration) {
          widget.onVoiceSend?.call(_path, duration);
        },
        onCancel: () {},
      );
    }
    return null;
  }

  // Unified bottom panel: takes the max height between keyboard and custom panel
  Widget _buildBottomPanel() {
    final panelHeight = _getCustomPanelHeight();
    final customPanelWidget = _getCustomPanelWidget();
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurves,
      height: panelHeight + safeBottomHeight,
      alignment: Alignment.topCenter,
      child: customPanelWidget,
    );
  }

  Widget defaultInputWidget() {
    final containerVertical = (containerHeight - inputContainerHeight) / 2;
    final iconButtonVertical = (inputContainerHeight - iconButtonSize) / 2;
    final generalHorizontal = 8.px;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: containerVertical,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMoreButton().setPaddingOnly(
            left: generalHorizontal,
            top: iconButtonVertical,
            bottom: iconButtonVertical,
          ),
          _buildEmojiButton().setPaddingOnly(
            right: generalHorizontal,
            top: iconButtonVertical,
            bottom: iconButtonVertical,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorToken.surfaceContainerHigh.of(context),
                borderRadius: BorderRadius.circular(28.px),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: inputContainerHeight,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.px),
                      alignment: Alignment.center,
                      child: _buildInputTextField(),
                    ).setPaddingOnly(left: 20.px),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    firstChild: _buildSendButton(),
                    secondChild: _buildVoiceButton(),
                    crossFadeState: _sendButtonVisible
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ).setPaddingOnly(
                    right: generalHorizontal,
                    top: iconButtonVertical,
                    bottom: iconButtonVertical,
                  ),
                ],
              ),
            ).setPaddingOnly(right: containerHorPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    if(PlatformUtils.isDesktop) return SizedBox().setPadding(EdgeInsets.all(_itemSpacing));
    return AttachmentButton(
      isLoading: widget.isAttachmentUploading ?? false,
      size: iconButtonSize,
      iconSize: iconSize,
      onPressed: () {
        changeInputType(InputType.inputTypeVoice);
      },
    );
  }

  Widget _buildInputTextField() {
    final textStyle = Theme.of(context).textTheme.bodyLarge!;
    final textColor = ColorToken.onSurface.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: iconSize),
      child: TextField(
        enabled: widget.options.enabled,
        autocorrect: widget.options.autocorrect,
        enableSuggestions: widget.options.enableSuggestions,
        controller: _textController,
        cursorColor: ColorToken.primary.of(context),
        decoration: InheritedChatTheme.of(context)
            .theme
            .inputTextDecoration
            .copyWith(
          hintStyle: textStyle.copyWith(
            color: textColor.withValues(alpha: 0.5),
          ),
          hintText: Localized.text('ox_chat_ui.chat_input_hint_text'),
          hintMaxLines: 1,
          // InheritedL10n.of(context).l10n.inputPlaceholder,
        ),
        focusNode: _inputFocusNode,
        keyboardType: widget.options.keyboardType,
        maxLines: 10,
        minLines: 1,
        onChanged: widget.options.onTextChanged,
        onTap: () {
          widget.options.onTextFieldTap;
        },
        style: textStyle.copyWith(
          color: textColor,
        ),
        textCapitalization: TextCapitalization.sentences,
        contentInsertionConfiguration:  ContentInsertionConfiguration(
          allowedMimeTypes: const <String>['image/png', 'image/gif', 'image/webp'],
          onContentInserted: (KeyboardInsertedContent data) async {
            if (data.data != null) {
              widget.onInsertedContent?.call(data);
            }
          },
        ),
        contextMenuBuilder: widget.options.contextMenuBuilder ?? (_, editableTextState) =>
            AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState),
      ),
    );
  }

  Widget _buildSendButton() =>
      SendButton(
        onPressed: _handleSendPressed,
        size: iconButtonSize,
        iconSize: iconSize,
      );

  Widget _buildEmojiButton() =>
      CommonIconButton(
        onPressed: () {
          changeInputType(InputType.inputTypeEmoji);
        },
        iconName: 'chat_emoti_icon.png',
        size: iconButtonSize,
        iconSize: iconSize,
        color: ColorToken.onSurface.of(context),
        package: 'ox_chat_ui',
      );

  Widget _buildMoreButton() {
    final isOnInput = this.isOnInput;
    return AnimatedAlign(
      alignment: Alignment.center,
      widthFactor: isOnInput ? 0.0 : 1.0,
      duration: animationDuration,
      child: AnimatedScale(
        scale: isOnInput ? 0.0 : 1.0,
        duration: animationDuration,
        child: AnimatedOpacity(
          opacity: isOnInput ? 0.0 : 1.0,
          duration: animationDuration,
          child: CommonIconButton(
            onPressed: () {
              changeInputType(InputType.inputTypeMore);
            },
            iconName: 'chat_more_icon.png',
            size: iconButtonSize,
            iconSize: iconSize,
            color: ColorToken.onSurface.of(context),
            package: 'ox_chat_ui',
          ),
        ),
      ),
    );
  }

  double get safeBottomHeight {
    if (inputType == InputType.inputTypeText) return 0.0;

    return MediaQuery.of(context).viewPadding.bottom;
  }

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void _handleSendPressed() async {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      final partialText = types.PartialText(text: text);
      final isSuccess = await widget.onSendPressed(partialText);
      if (!isSuccess) return ;

      if (widget.options.inputClearMode == InputClearMode.always) {
        _textController.clear();
        final onTextChanged = widget.options.onTextChanged;
        if (onTextChanged != null) onTextChanged(_textController.text);
      }
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  void changeInputType(InputType type) {
    if (inputType == type) return;

    setState(() {
      inputType = type;
      if (type != InputType.inputTypeText && _inputFocusNode.hasFocus) {
        _inputFocusNode.unfocus();
      }
    });
  }
}

@immutable
class InputOptions {
  const InputOptions({
    this.inputClearMode = InputClearMode.always,
    this.keyboardType = TextInputType.multiline,
    this.onTextChanged,
    this.onTextFieldTap,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.textEditingController,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enabled = true,
    this.contextMenuBuilder,
    this.pasteTextAction,
  });

  /// Controls the [Input] clear behavior. Defaults to [InputClearMode.always].
  final InputClearMode inputClearMode;
  
  /// Controls the [Input] keyboard type. Defaults to [TextInputType.multiline].
  final TextInputType keyboardType;

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;



  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;

  /// Controls the [TextInput] autocorrect behavior. Defaults to [true].
  final bool autocorrect;

  /// Controls the [TextInput] enableSuggestions behavior. Defaults to [true].
  final bool enableSuggestions;

  /// Controls the [TextInput] enabled behavior. Defaults to [true].
  final bool enabled;

  final EditableTextContextMenuBuilder? contextMenuBuilder;

  final Action<PasteTextIntent>? pasteTextAction;
}


enum InputType {
  inputTypeDefault,
  inputTypeText,
  inputTypeEmoji,
  inputTypeMore,
  inputTypeVoice,
}