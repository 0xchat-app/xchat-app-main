import 'package:flutter/cupertino.dart';
import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:ox_chat/utils/widget_tool.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/smart_group_avatar.dart';
import 'package:ox_common/widgets/common_image.dart';

///Title: share_item_info
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2024/2/26 16:38
mixin ShareItemInfoMixin {
  Map<String, List<String>> _groupMembersCache = {};

  void updateStateView(Map<String, List<String>> groupMembersCache) {
    _groupMembersCache = groupMembersCache;
  }

  Widget buildItemName(ChatSessionModelISAR item) {
    String showName = '';
    switch (item.chatType) {
      case ChatType.chatSingle:
        showName = Account.sharedInstance.userCache[item.getOtherPubkey]?.value.name ?? '';
        break;
      case ChatType.chatGroup:
        showName = Groups.sharedInstance.groups[item.chatId]?.value.name ?? '';
        break;
    }
    return Container(
      margin: EdgeInsets.only(right: 4.px),
      child: Text(showName,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: Adapt.px(16), fontWeight: FontWeight.w600, color: ThemeColor.color10)),
      constraints: BoxConstraints(maxWidth: Adapt.screenW - Adapt.px(48 + 60 + 36 + 50)),
      // width: Adapt.px(135),
    );
  }

  Widget buildItemIcon(ChatSessionModelISAR item) {
    if (item.chatType == '1000') {
      return assetIcon('icon_notice_avatar.png', 60, 60);
    } else {
      String showPicUrl = '';
      String localAvatarPath = '';
      switch (item.chatType) {
        case ChatType.chatSingle:
        case ChatType.chatGroup:
          showPicUrl = Groups.sharedInstance.groups[item.chatId]?.value.picture ?? '';
          localAvatarPath = 'icon_group_default.png';
          break;
      }
      return Container(
        width: Adapt.px(60),
        height: Adapt.px(60),
        child: (item.chatType == ChatType.chatGroup)
            ? Center(
                child: SmartGroupAvatar(
                groupId: item.groupId,
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
      );
    }
  }

  //Queries the list of Friends to see if each Friend name contains a search character
  List<UserDBISAR>? loadChatFriendsWithSymbol(String symbol) {
    List<UserDBISAR>? friendList = Contacts.sharedInstance.fuzzySearch(symbol);
    return friendList;
  }

  //Queries the list of Channels to see if each Channel name contains a search character
  List<ChannelDBISAR>? loadChatChannelsWithSymbol(String symbol) {
    final List<ChannelDBISAR>? channelList = Channels.sharedInstance.fuzzySearch(symbol);
    return channelList;
  }

  List<GroupDBISAR>? loadChatGroupWithSymbol(String symbol) {
    final List<GroupDBISAR>? groupDBlist = Groups.sharedInstance.fuzzySearch(symbol);
    return groupDBlist;
  }
}

enum ShareSearchType {
  friends,
  groups,
  channels,
  recentChats,
}

class ShareSearchGroup {
  final String title;
  final ShareSearchType type;
  final List<ChatSessionModelISAR> items;

  ShareSearchGroup({required this.title, required this.type, required this.items});

  @override
  String toString() {
    return 'ShareSearchGroup{title: $title, type: $type, items: $items}';
  }
}
