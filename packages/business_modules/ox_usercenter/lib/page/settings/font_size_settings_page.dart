
import 'package:flutter/widgets.dart';
import 'package:ox_cache_manager/ox_cache_manager.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/font_size_notifier.dart';
import 'package:ox_common/utils/storage_key_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/utils/text_scale_slider.dart';

class FontSizeSettingsPage extends StatefulWidget {
  const FontSizeSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<FontSizeSettingsPage> createState() => _FontSizeSettingsPageState();
}

class _FontSizeSettingsPageState extends State<FontSizeSettingsPage> {
  double _textScale = textScaleFactorNotifier.value;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(_textScale),
      ),
      child: CLScaffold(
        appBar: CLAppBar(
          title: Localized.text('ox_usercenter.str_settings_chat'),
          actions: [
            CLButton.text(
              text: Localized.text('ox_common.save'),
              onTap: () {
                textScaleFactorNotifier.value = _textScale;
                OXCacheManager.defaultOXCacheManager.saveForeverData(StorageKeyTool.APP_FONT_SIZE, _textScale);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  OXNavigator.pop(context);
                });
              }
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: CLLayout.horizontalPadding,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Column(
                  children: [
                    _buildChatWidget(
                      name: 'Jack',
                      content: 'Hello, XChat.\nHow can I set the text size?',
                      picture: 'icon_chat_settings_right.png',
                      isSender: false,
                    ),
                    SizedBox(height: 16.px),
                    _buildChatWidget(
                      name: 'XChat',
                      content: 'Hello, Jack.\nGo to "Settings - Text Size", and drag the slider below to set the text size.',
                      picture: 'icon_chat_settings_left.png',
                      isSender: true,
                    ),
                  ],
                ),
                const Spacer(),
                TextScaleSlider(
                  onChanged: (value) {
                    setState(() {
                      _textScale = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatWidget({
    required String name,
    required String content,
    required String picture,
    bool isSender = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: isSender ? TextDirection.rtl : TextDirection.ltr,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5.px),
          child: CommonImage(
            iconName: picture,
            width: 40.px,
            height: 40.px,
            package: 'ox_usercenter',
          ),
        ),
        SizedBox(width: 10.px),
        Expanded(
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              CLText.bodyMedium(name),
              SizedBox(height: 4.px),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.px,
                  horizontal: CLLayout.horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSender ? ColorToken.primary.of(context) : ColorToken.surfaceContainer.of(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSender ? 16.px : 0),
                    topRight: Radius.circular(isSender ? 0 : 16.px),
                    bottomRight: Radius.circular(16.px),
                    bottomLeft: Radius.circular(16.px),
                  ),
                ),
                child: CLText.bodyLarge(content),
              ),
            ],
          ),
        )
      ],
    );
  }
}
