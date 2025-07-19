import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/business_interface/ox_chat/utils.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_module_service/ox_module_service.dart';

import '../component.dart';
import '../utils/date_utils.dart';
import '../utils/theme_color.dart';
import 'common_image.dart';

class CommonLongContentPage extends StatefulWidget {
  final String? content;
  final int? timeStamp;
  final String? title;
  final String? surfacePic;
  final String? pubkey;
  final String userPic;
  final String userName;
  final bool isShowOriginalText;
  final UserDBISAR? author;

  CommonLongContentPage({
    this.content,
    this.timeStamp,
    this.title,
    this.surfacePic,
    this.pubkey,
    this.userPic = '',
    this.userName = '',
    this.author,
    this.isShowOriginalText = true,
  });

  @override
  CommonLongContentPageState createState() => CommonLongContentPageState();

  static present({
    BuildContext? context,
    String? content,
    UserDBISAR? author,
    int? timeStamp,
  }) {
    OXNavigator.pushPage(context, (context) => CommonLongContentPage(
      content: content,
      author: author,
      timeStamp: timeStamp,
    ),
      type: OXPushPageType.present,
    );
  }
}

class CommonLongContentPageState extends State<CommonLongContentPage> {
  final int contentFontSize = 14;

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: widget.title ?? '',
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.px),
          child: SafeArea(
            child: _body(),
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget() {
    String? surfacePic = widget.surfacePic;
    if (surfacePic == null) return const SizedBox();
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(11.5.px),
        topRight: Radius.circular(11.5.px),
      ),
      child: Container(
        width: double.infinity,
        color: ThemeColor.color100,
        child: CLCachedNetworkImage(
          imageUrl: surfacePic,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              badgePlaceholderContainer(height: 172, width: double.infinity),
          errorWidget: (context, url, error) =>
              badgePlaceholderContainer(size: 172, width: double.infinity),
          height: 172.px,
        ),
      ),
    );
  }

  Widget _body() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 12.px),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.px,
            color: ThemeColor.color160,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(
              11.5.px,
            ),
          ),
        ),
        child: Column(
          children: [
            _getImageWidget(),
            Container(
              padding: EdgeInsets.all(12.px),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? pubkey = widget.author?.pubKey ?? widget.pubkey;
                          if (pubkey != null) {
                            await OXModuleService.pushPage(
                                context, 'ox_chat', 'ContactUserInfoPage', {
                              'pubkey': pubkey,
                            });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40.px),
                          child: CLCachedNetworkImage(
                            imageUrl: widget.author?.picture ?? widget.userPic,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => badgePlaceholderImage(),
                            errorWidget: (context, url, error) => badgePlaceholderImage(),
                            width: 40.px,
                            height: 40.px,
                          ),
                        ),
                      ),
                      Text(
                        widget.author?.getUserShowName() ?? widget.userName,
                        style: TextStyle(
                          fontSize: 12.px,
                          fontWeight: FontWeight.w500,
                          color: ThemeColor.color0,
                        ),
                      ).setPadding(
                        EdgeInsets.symmetric(
                          horizontal: 4.px,
                        ),
                      ),
                      _timeWidget(),
                    ],
                  ).setPaddingOnly(bottom: 4.px),
                  _contentWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeWidget(){
    final timeStamp = widget.timeStamp;
    if(timeStamp == null) return const SizedBox();
    return  Expanded(
      child: Text(
        OXDateUtils.formatTimestamp(timeStamp,
            pattern: 'MM-dd HH:mm:ss'),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.px,
          fontWeight: FontWeight.w400,
          color: ThemeColor.color120,
        ),
      ),
    );
  }

  Widget _contentWidget() {
    if (widget.isShowOriginalText) {
      return SelectableText(
        widget.content ?? '',
        style: TextStyle(
          fontSize: contentFontSize.px,
          color: ThemeColor.color0,
        ),
      );
    }

    return OXModuleService.invoke(
      'ox_discovery',
      'momentRichTextWidget',
      [context],
      {
        #content: widget.content,
        #textSize: contentFontSize,
        #isShowAllContent: true,
        #clickBlankCallback: null,
        #showMoreCallback: null,
      },
    );
  }

  Widget badgePlaceholderContainer(
      {int size = 24, double? width, double? height}) {
    return Container(
      width: width ?? size.px,
      height: height ?? size.px,
      color: ThemeColor.color180,
    );
  }

  Widget badgePlaceholderImage({int size = 24}) {
    return CommonImage(
      iconName: 'icon_badge_default.png',
      fit: BoxFit.cover,
      width: size.px,
      height: size.px,
      useTheme: true,
    );
  }
}
