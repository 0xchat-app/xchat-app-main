part of 'chat_session_list_page.dart';

extension ChatSessionListPageUI on ChatSessionListPageState{
  Widget _buildListViewItem(context, int index) {
    if(index >= _msgDatas.length) return SizedBox();
    ChatSessionModelISAR item = _msgDatas[index];
    bool isMuteCurrent = ChatSessionUtils.getChatMute(item);
    GlobalKey tempKey = GlobalKey(debugLabel: index.toString());
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        _latestGlobalKey = tempKey;
      },
      child: Container(
        color: ThemeColor.color200,
        child: Slidable(
          key: tempKey,
          endActionPane: ActionPane(
            extentRatio: 0.44,
            motion: const ScrollMotion(),
            children: [
              CustomSlidableAction(
                onPressed: (BuildContext _) async {
                  ChatSessionUtils.setChatMute(item, !isMuteCurrent);
                },
                backgroundColor: ThemeManager.colors('ox_chat.actionRoyalBlue'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    assetIcon(isMuteCurrent ? 'icon_unmute.png' : 'icon_mute.png', 32, 32, color: Colors.white),
                    Text(
                      (isMuteCurrent ? 'un_mute_item' : 'mute_item').localized(),
                      style: TextStyle(color: Colors.white, fontSize: Adapt.px(12)),
                    ),
                  ],
                ),
              ),
              CustomSlidableAction(
                onPressed: (BuildContext _) async {
                  OXCommonHintDialog.show(context,
                      content: item.chatType == ChatType.chatSecret
                          ? Localized.text('ox_chat.secret_message_delete_tips')
                          : Localized.text('ox_chat.message_delete_tips'),
                      actionList: [
                        OXCommonHintAction.cancel(onTap: () {
                          OXNavigator.pop(context);
                        }),
                        OXCommonHintAction.sure(
                            text: Localized.text('ox_common.confirm'),
                            onTap: () async {
                              OXNavigator.pop(context);
                              int count = 0;
                              if(item.chatType == ChatType.chatNotice) {
                                count = await _deleteStrangerSessionList();
                              } else {
                                count = await OXChatBinding.sharedInstance.deleteSession([item.chatId]);
                              }
                              if (count > 0) {
                                _merge();
                              }
                            }),
                      ],
                      isRowAction: true);
                },
                backgroundColor: ThemeManager.colors('ox_chat.actionPurple'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    assetIcon('icon_chat_delete.png', 32, 32, color: Colors.white),
                    Text(
                      'delete'.localized(),
                      style: TextStyle(color: Colors.white, fontSize: Adapt.px(12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child: Stack(
            key: tempKey,
            children: [
              _buildBusinessInfo(item, index),
              item.alwaysTop
                  ? Container(
                alignment: Alignment.topRight,
                child: assetIcon('icon_red_always_top.png', 12, 12),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfo(ChatSessionModelISAR item, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _itemFn(item);
      },
      onLongPressStart: (_) {
        _scaleList[index].value = true;
      },
      onLongPress: () async {
        TookKit.vibrateEffect();
        await Future.delayed(Duration(milliseconds: 100));
        _scaleList[index].value = false;
        _itemLongPressFn(item, index);
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _scaleList[index],
        builder: (context, scale, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: scale ? 0.9 : 1.0),
            duration: Duration(milliseconds: 100),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.only(top: Adapt.px(12), left: Adapt.px(16), bottom: Adapt.px(12), right: Adapt.px(16)),
                  constraints: BoxConstraints(
                    minWidth: 30.px,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            _getMsgIcon(item),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: Adapt.px(16), right: Adapt.px(16)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        _buildItemName(item),
                                        if (_getChatSessionMute(item))
                                          CommonImage(
                                            iconName: 'icon_mute.png',
                                            width: Adapt.px(16),
                                            height: Adapt.px(16),
                                            package: 'ox_chat',
                                          ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 6.px),
                                      child: Container(
                                        constraints: BoxConstraints(maxWidth: Adapt.screenW / 2),
                                        child: _buildItemSubtitle(item),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildReactionIcon(item).setPaddingOnly(right: 6.px),
                              _buildReadWidget(item),
                            ],
                          ),
                          SizedBox(height: 8.px),
                          Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Text(OXDateUtils.convertTimeFormatString2(item.createTime* 1000, pattern: 'MM-dd'),
                                textAlign: TextAlign.left, maxLines: 1, style: _Style.newsContentSub()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );

  }

  Widget _getMsgIcon(ChatSessionModelISAR item) {
    if (item.chatType == '1000') {
      return assetIcon('icon_notice_avatar.png', 60, 60);
    } else {
      String showPicUrl = ChatSessionUtils.getChatIcon(item);
      String localAvatarPath = ChatSessionUtils.getChatDefaultIcon(item);
      Widget? sessionTypeWidget = ChatSessionUtils.getTypeSessionView(item.chatType, item.chatId);
      return Container(
        width: Adapt.px(60),
        height: Adapt.px(60),
        child: Stack(
          children: [
            (item.chatType == ChatType.chatGroup)
                ? Center(
                child: GroupedAvatar(
                  avatars: _groupMembersCache[item.privateGroupId] ?? [],
                  size: 60.px,
                ))
                : ClipRRect(
              borderRadius: BorderRadius.circular(Adapt.px(60)),
              child: BaseAvatarWidget(
                imageUrl: '${showPicUrl}',
                defaultImageName: localAvatarPath,
                size: Adapt.px(60),
              ),
            ),
            (item.chatType == ChatType.chatSingle)
                ? Positioned(
              bottom: 0,
              right: 0,
              child: FutureBuilder<BadgeDBISAR?>(
                initialData: _badgeCache[item.chatId],
                builder: (context, snapshot) {
                  return (snapshot.data != null)
                      ? OXCachedNetworkImage(
                    imageUrl: snapshot.data!.thumb,
                    width: Adapt.px(24),
                    height: Adapt.px(24),
                    fit: BoxFit.cover,
                  )
                      : Container();
                },
                future: _getUserSelectedBadgeInfo(item),
              ),
            )
                : SizedBox(),
            Positioned(
              bottom: 0,
              right: 0,
              child: sessionTypeWidget,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildItemName(ChatSessionModelISAR item) {
    late Widget nameView;
    ValueNotifier? tempValueNotifier = ChatSessionUtils.getChatValueNotifier(item);
    if (item.chatType == ChatType.chatNotice || tempValueNotifier == null) {
      nameView = MyText(item.chatName ?? '', 16.px, ThemeColor.color10, textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600);
    } else {
      nameView = ValueListenableBuilder(
        valueListenable: tempValueNotifier,
        builder: (context, value, child) {
          return MyText(value.name ?? '', 16.px, ThemeColor.color10, textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600);
        },
      );
    }
    return Container(
      margin: EdgeInsets.only(right: Adapt.px(4)),
      child: item.chatType == ChatType.chatSecret
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonImage(
            iconName: 'icon_lock_secret.png',
            width: Adapt.px(16),
            height: Adapt.px(16),
            package: 'ox_chat',
          ),
          SizedBox(
            width: Adapt.px(4),
          ),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  ThemeColor.gradientMainEnd,
                  ThemeColor.gradientMainStart,
                ],
              ).createShader(Offset.zero & bounds.size);
            },
            child: nameView,
          ),
        ],
      )
          : nameView,
      constraints: BoxConstraints(maxWidth: Adapt.screenW / 2.2),
    );
  }

  Widget _buildItemSubtitle(ChatSessionModelISAR announceItem) {
    final isMentioned = announceItem.mentionMessageIds.isNotEmpty;
    if (isMentioned) {
      return RichText(
        textAlign: TextAlign.left,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '[${Localized.text('ox_chat.session_content_mentioned')}]',
              style: _Style.hintContentSub(),
            ),
            TextSpan(
              text: announceItem.content ?? '',
              style: _Style.newsContentSub(),
            ),
          ],
        ),
      );
    }

    final draft = announceItem.draft ?? '';
    if (draft.isNotEmpty) {
      return Text(
        '[${Localized.text('ox_chat.session_content_draft')}]$draft',
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _Style.hintContentSub(),
      );
    }
    return Text(
      announceItem.content ?? '',
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _Style.newsContentSub(),
    );
  }

  String getLastMessageStr(MessageDBISAR? messageDB) {
    if (messageDB == null) {
      return '';
    }
    final decryptedContent = json.decode(messageDB.decryptContent);
    MessageContentModel contentModel = MessageContentModel.fromJson(decryptedContent);
    if (contentModel.contentType == null) {
      return '';
    }
    if (messageDB.type == MessageType.text) {
      return contentModel.content ?? '';
    } else {
      return '[${contentModel.contentType.toString().split('.').last}]';
    }
  }

  bool _getChatSessionMute(ChatSessionModelISAR item) {
    bool isMute = ChatSessionUtils.getChatMute(item);
    if (isMute != _muteCache[item.chatId]) {
      _muteCache[item.chatId] = isMute;
    }
    return isMute;
  }

  Widget _buildReactionIcon(ChatSessionModelISAR item) {
    final reactions = item.reactionMessageIds;
    bool isMute = _getChatSessionMute(item);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds:1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          ),
        );
      },
      child: reactions.isNotEmpty ? CommonImage(
        iconName: 'icon_session_reaction.png',
        size: 24.px,
        color: isMute ? ThemeColor.color110 : null,
        package: 'ox_chat',
      ) : SizedBox(),
    );
  }

  Widget _buildReadWidget(ChatSessionModelISAR item) {
    int read = item.unreadCount;
    bool isMute = _getChatSessionMute(item);
    if (isMute) {
      if (read > 0) {
        return ClipOval(
          child: Container(
            alignment: Alignment.center,
            color: ThemeColor.color110,
            width: Adapt.px(12),
            height: Adapt.px(12),
          ),
        );
      } else {
        return SizedBox();
      }
    }
    if (read > 0 && read < 100) {
      double paddingValue = read < 10 ? 7.px : 3.px;
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColor.red1,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.symmetric(vertical: paddingValue, horizontal: paddingValue),
        child: Text(
          read.toString(),
          style: _Style.read(),
        ),
      );
    } else if (read >= 100) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColor.red1,
          borderRadius: BorderRadius.all(Radius.circular(Adapt.px(13.5))),
        ),
        padding: EdgeInsets.symmetric(vertical: Adapt.px(3), horizontal: Adapt.px(3)),
        child: Text(
          '99+',
          style: _Style.read(),
        ),
      );
    }
    return Container();
  }

  Widget _topSearch() {
    return InkWell(
      onTap: () {
        UnifiedSearchPage().show(context);
      },
      highlightColor: Colors.transparent,
      radius: 0.0,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: Adapt.px(24),
          vertical: Adapt.px(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.px),
        height: Adapt.px(48),
        decoration: BoxDecoration(
          color: ThemeColor.color190,
          borderRadius: BorderRadius.all(Radius.circular(Adapt.px(16))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            assetIcon('icon_chat_search.png', 24, 24),
            SizedBox(
              width: Adapt.px(8),
            ),
            MyText(
              'search'.localized(),
              15,
              ThemeColor.color150,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}

class _Style {

  static TextStyle newsContentSub() {
    return new TextStyle(
      fontSize: Adapt.px(14),
      fontWeight: FontWeight.w400,
      color: ThemeColor.color120,
    );
  }

  static TextStyle hintContentSub() {
    return new TextStyle(
      fontSize: Adapt.px(14),
      fontWeight: FontWeight.w400,
      color: ThemeColor.red,
    );
  }

  static TextStyle read() {
    return new TextStyle(
      fontSize: Adapt.px(12),
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );
  }
}