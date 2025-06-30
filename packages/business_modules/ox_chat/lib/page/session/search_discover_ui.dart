import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_chat/model/group_ui_model.dart';
import 'package:ox_chat/model/search_chat_model.dart';
import 'package:ox_chat/page/session/search_page.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/channel_model.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_network_image.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';

///Title: search_discover_ui
///Description: TODO(Fill in by oneself)
///Copyright: Copyright (c) 2021
///@author Michael
///CreateTime: 2023/5/29 10:27
extension SearchDiscoverUI on SearchPageState{

  void loadOnlineChannelsDataAndClear() async {
    dataGroups.clear();
    loadOnlineChannelsData();
  }

  void loadOnlineChannelsData() async {
    final requestId = ++lastRequestId;
    if (searchQuery.startsWith('nevent') ||
        searchQuery.startsWith('naddr') ||
        searchQuery.startsWith('nostr:') ||
        searchQuery.startsWith('note')) {
      Map<String, dynamic>? map = Channels.decodeChannel(searchQuery);
      if (map != null) {
        final kind = map['kind'];
        if (kind == 40 || kind == 41) {
          String decodeNote = map['channelId'].toString();
          List<String> relays = List<String>.from(map['relays']);
          ChannelDBISAR? c = await Channels.sharedInstance.searchChannel(decodeNote, relays);
          if (c != null) {
            List<ChannelDBISAR> result = [c];
            dataGroups.add(
              Group(title: 'Online Channels', type: SearchItemType.channel, items: result),
            );
          }
        } else if (kind == 39000) {
          final groupId = map['channelId'];
          final relays = map['relays'];
          RelayGroupDBISAR? relayGroupDB = await RelayGroup.sharedInstance.searchGroupsMetadataWithGroupID(groupId, relays[0]);
          if (relayGroupDB != null) {
            List<GroupUIModel> result = [GroupUIModel.relayGroupdbToUIModel(relayGroupDB)];
            dataGroups.add(
              Group(title: 'Online Groups', type: SearchItemType.groups, items: result),
            );
          }
        }
      }
    } else {
      List<ChannelModel?> channelModels = await getHotChannels(
          queryCode: searchQuery, context: context, showLoading: false);
      LogUtil.d('Search Result: ${channelModels.length} ${channelModels}');
      if (requestId == lastRequestId) {
        if (channelModels.length > 0) {
          List<ChannelDBISAR>? tempChannelList =
          channelModels.map((element) => element!.toChannelDB()).toList();
          dataGroups.add(
            Group(
                title: 'Online Channels',
                type: SearchItemType.channel,
                items: tempChannelList),
          );
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget discoverPage(){
    return Scaffold(
      backgroundColor: ThemeColor.color200,
      body: Column(
        children: [
          _searchView(),
          Expanded(
            child: _discoverView().setPadding(EdgeInsets.symmetric(horizontal: Adapt.px(24))),
          ),
        ],
      ),
    );
  }

  Widget _discoverView(){
    if (searchQuery.isEmpty) {
      return Container(
        width: double.infinity,
        height: Adapt.px(22),
        alignment: Alignment.topCenter,
        child: Text(
          Localized.text('ox_chat.search_channel_tips'),
          style: TextStyle(
            fontSize: Adapt.px(15),
            color: ThemeColor.color110,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
    return GroupedListView<Group, dynamic>(
      elements: dataGroups,
      groupBy: (element) => element.title,
      groupHeaderBuilder: (element){
        return Container();
      } ,
      padding: EdgeInsets.zero,
      itemBuilder: (context, element) {
        final items = element.items;
        if (element.type == SearchItemType.channel && items is List<ChannelDBISAR>) {
          return Column(
            children: items.map((item) {
              return ListTile(
                onTap: () async {
                  if(LoginManager.instance.isLoginCircle){
                    gotoChatChannelSession(item);
                  }else{
                    await OXModuleService.pushPage(context, "ox_login", "LoginPage", {});
                  }
                },
                leading: CircleAvatar(
                  child: OXCachedNetworkImage(
                    errorWidget: (context, url, error) => placeholderImage(false, 48),
                    placeholder: (context, url) => placeholderImage(false, 48),
                    fit: BoxFit.fill,
                    imageUrl: item.picture ?? '',
                    width: Adapt.px(48),
                    height: Adapt.px(48),
                  ),
                ),
                title: Text(
                  item.name ?? '',
                ).setPadding(EdgeInsets.only(bottom: Adapt.px(2))),
                subtitle: highlightText(item.about ?? ''),
              );
            }).toList(),
          );
        }
        return SizedBox.shrink();
      },
      itemComparator: (item1, item2) => item1.title.compareTo(item2.title),
      useStickyGroupSeparators: false,
      floatingHeader: false,
    );
  }

  void onDiscoverTextChanged(value) {
    searchQuery = value;
    loadOnlineChannelsDataAndClear();
  }


  Widget _searchView() {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      height: Adapt.px(80),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: Adapt.px(24)),
              decoration: BoxDecoration(
                color: ThemeColor.color190,
                borderRadius: BorderRadius.circular(Adapt.px(16)),
              ),
              child: TextField(
                controller: editingController,
                onChanged: onDiscoverTextChanged,
                decoration: InputDecoration(
                  icon: Container(
                    margin: EdgeInsets.only(left: Adapt.px(16)),
                    child: CommonImage(
                      iconName: 'icon_search.png',
                      width: Adapt.px(24),
                      height: Adapt.px(24),
                      fit: BoxFit.fill,
                    ),
                  ),
                  hintText: Localized.text('ox_chat.search'),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: Adapt.px(90),
              alignment: Alignment.center,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      ThemeColor.gradientMainEnd,
                      ThemeColor.gradientMainStart,
                    ],
                  ).createShader(Offset.zero & bounds.size);
                },
                child: Text(
                  Localized.text('ox_common.cancel'),
                  style: TextStyle(
                    fontSize: Adapt.px(15),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onTap: () {
              OXNavigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}