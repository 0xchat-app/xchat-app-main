import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:nostr_core_dart/nostr.dart';
import 'package:ox_chat/model/option_model.dart';
import 'package:ox_chat/model/search_chat_model.dart';
import 'package:ox_chat/page/contacts/groups/relay_group_base_info_page.dart';
import 'package:ox_chat/page/contacts/groups/relay_group_manage_admins_page.dart';
import 'package:ox_chat/page/contacts/groups/relay_group_request.dart';
import 'package:ox_chat/page/session/search_page.dart';
import 'package:ox_chat/utils/chat_session_utils.dart';
import 'package:ox_chat/utils/group_share_utils.dart';
import 'package:ox_chat/utils/widget_tool.dart';
import 'package:ox_chat/widget/chat_history_for_new_members_selector_dialog.dart';
import 'package:ox_chat/widget/group_create_selector_dialog.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_chat_binding.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'package:ox_common/widgets/common_hint_dialog.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/custom_avatar_stack.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import '../contact_group_list_page.dart';
import '../contact_group_member_page.dart';
import 'group_setting_qrcode_page.dart';

class RelayGroupInfoPage extends StatefulWidget {
  final String groupId;

  RelayGroupInfoPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _RelayGroupInfoPageState createState() => new _RelayGroupInfoPageState();
}

class _RelayGroupInfoPageState extends State<RelayGroupInfoPage> {
  bool _isMute = false;
  List<UserDBISAR> groupMember = [];
  RelayGroupDBISAR? groupDBInfo = null;
  bool _isGroupMember = false;
  bool _hasAddUserPermission = false;
  bool _hasRemoveUserPermission = false;
  bool _hasAddPermission = false;
  bool _hasEditGroupStatusPermission = false;
  bool _hasDeleteGroupPermission = false;
  UserDBISAR? userDB;

  @override
  void initState() {
    super.initState();
    userDB = Account.sharedInstance.me;
    _groupInfoInit();
    _loadDataFromRelay();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getPermissionValue() {
    _hasAddUserPermission = RelayGroup.sharedInstance.hasPermissions(groupDBInfo?.admins ?? [], userDB?.pubKey??'', [GroupActionKind.addUser]);
    _hasRemoveUserPermission = RelayGroup.sharedInstance.hasPermissions(groupDBInfo?.admins ?? [], userDB?.pubKey??'', [GroupActionKind.removeUser]);
    _hasAddPermission = RelayGroup.sharedInstance.hasPermissions(groupDBInfo?.admins ?? [], userDB?.pubKey??'', [GroupActionKind.addPermission]);
    _hasEditGroupStatusPermission = RelayGroup.sharedInstance.hasPermissions(groupDBInfo?.admins ?? [], userDB?.pubKey??'', [GroupActionKind.editGroupStatus]);
    _hasDeleteGroupPermission = RelayGroup.sharedInstance.hasPermissions(groupDBInfo?.admins ?? [], userDB?.pubKey??'', [GroupActionKind.deleteGroup]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.color190,
      appBar: CommonAppBar(
        useLargeTitle: false,
        centerTitle: true,
        title: Localized.text('ox_chat.group_info'),
        backgroundColor: ThemeColor.color190,
        actions: [
          _appBarActionWidget(),
          SizedBox(width: 24.px),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 12.px,
          ),
          child: Column(
            children: [
              _groupBaseInfoView(),
              _optionMemberWidget(),
              _groupTypeView(),
              _groupNotesView(),
              _muteWidget(),
              _groupHistoryView(),
              _leaveBtnWidget(),
              SizedBox(height: 50.px),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarActionWidget() {
    return GestureDetector(
      onTap: _shareGroupFn,
      child: Container(
        child: CommonImage(
          iconName: 'share_icon.png',
          width: Adapt.px(20),
          height: Adapt.px(20),
          useTheme: true,
        ),
      ),
    );
  }

  Widget _groupBaseInfoView() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        OXNavigator.pushPage(
          context,
              (context) => RelayGroupBaseInfoPage(
            groupId: widget.groupId,
          ),
        ).then((value){
          setState(() {});
        });
      },
      child: RelayGroupBaseInfoView(
        groupId: widget.groupId,
        groupQrCodeFn: () {
          _DisableShareDialog(true);
        },
      ),
    );
  }

  Widget _optionMemberWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      margin: EdgeInsets.only(top: 16.px),
      padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 12.px),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _groupMemberOptionFn(GroupListAction.view),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    Localized.text('ox_chat.view_all_members').replaceAll(r'${count}', '${groupMember.length}'),
                    14.px,
                    ThemeColor.color100,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CommonImage(
                    iconName: 'icon_more.png',
                    width: Adapt.px(24),
                    height: Adapt.px(24),
                    package: 'ox_chat',
                    useTheme: true,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.px),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _memberAvatarWidget(),
              _addOrDelMember(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberAvatarWidget() {
    int groupMemberNum = groupMember.length;
    if (groupMemberNum == 0) return Container();
    int renderCount = groupMemberNum > 8 ? 8 : groupMemberNum;
    return CustomAvatarStack(
      maxAvatars: groupMemberNum,
      imageUrls: _getMemberAvatars(renderCount),
      avatarSize: 48.px,
      spacing: 24.px,
      borderColor: ThemeColor.color180,
    );
  }

  List<String> _getMemberAvatars(int renderCount) {
    List<String> avatarList = [];
    for (var n = 0; n < renderCount; n++) {
      String groupPic = groupMember[n].picture ?? '';
      avatarList.add(groupPic);
    }
    return avatarList;
  }

  Widget _addOrDelMember() {
    return Container(
      child: Row(
        children: [
          _addMemberBtnWidget(),
          _removeMemberBtnWidget(),
        ],
      ),
    );
  }

  Widget _addMemberBtnWidget() {
    if (!_hasAddUserPermission) return SizedBox();
    return GestureDetector(
      onTap: () => _groupMemberOptionFn(GroupListAction.add),
      child: CommonImage(
        iconName: 'add_circle_icon.png',
        size: 40.px,
        useTheme: true,
      ),
    );
  }

  Widget _removeMemberBtnWidget() {
    if (!_hasRemoveUserPermission) return SizedBox();
    return GestureDetector(
      onTap: () => _groupMemberOptionFn(GroupListAction.remove),
      child: Container(
        margin: EdgeInsets.only(left: 12.px),
        child: CommonImage(
          iconName: 'del_circle_icon.png',
          size: 40.px,
          useTheme: true,
        ),
      ),
    );
  }

  Widget _groupTypeView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      margin: EdgeInsets.only(top: 16.px),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GroupItemBuild(
            title: Localized.text('ox_chat.str_group_type'),
            subTitle: groupDBInfo != null
                ? (groupDBInfo!.closed ? GroupType.closeGroup.text : GroupType.openGroup.text)
                : '--',
            subTitleIcon: groupDBInfo != null
                ? (groupDBInfo!.closed ? GroupType.closeGroup.typeIcon : GroupType.openGroup.typeIcon)
                : null,
            onTap: _hasEditGroupStatusPermission ? _updateGroupTypeFn : null,
            isShowMoreIcon: _hasEditGroupStatusPermission,
          ),
          GroupItemBuild(
            title: Localized.text('ox_chat.str_chat_history_for_new_members'),
            subTitle: groupDBInfo != null
                ? (groupDBInfo!.private ? ChatHistoryForNewMembersType.hidden.text : ChatHistoryForNewMembersType.show.text)
                : '--',
            onTap: _hasEditGroupStatusPermission ? _updateGroupHistoryStatusFn : null,
            isShowMoreIcon: _hasEditGroupStatusPermission,
          ),
          GroupItemBuild(
            title: Localized.text('ox_chat.str_group_relay'),
            subTitle: groupDBInfo?.relay ?? '--',
            onTap: null,
            subTitleMaxLines: 2,
            isShowMoreIcon: false,
            isShowDivider: _hasAddPermission,
          ),
          if (_hasAddPermission)
            GroupItemBuild(
            title: Localized.text('ox_chat.join_request'),
            onTap: _groupRequestFn,
            isShowMoreIcon: true,
            isShowDivider: true,
          ),
          if (_hasAddPermission)
            GroupItemBuild(
              title: Localized.text('ox_chat.str_group_administrators'),
              onTap: _manageGroupFn,
              isShowMoreIcon: true,
              isShowDivider: false,
            ),
        ],
      ),
    );
  }

  Widget _groupNotesView(){
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.px),
          color: ThemeColor.color180,
        ),
        margin: EdgeInsets.only(top: 16.px),
        child: GroupItemBuild(
          title: Localized.text('ox_chat.str_group_notes'),
          onTap: _gotoGroupNotesFn,
          isShowMoreIcon: true,
          isShowDivider: false,
        ),
    );
  }
  Widget _groupHistoryView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      margin: EdgeInsets.only(top: 16.px),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GroupItemBuild(
            title: Localized.text('ox_chat.str_group_search_chat_history'),
            onTap: _searchChatHistoryFn,
            isShowMoreIcon: true,
            isShowDivider: false,
          ),
          // GroupItemBuild(
          //   title: Localized.text('ox_chat.str_group_clear_chat_history'),
          //   onTap: _clearChatHistoryFn,
          //   isShowMoreIcon: true,
          //   isShowDivider: false,
          // ),
          // GroupItemBuild(
          //   title: Localized.text('ox_chat.str_group_report'),
          //   subTitle: groupDBInfo?.groupId ?? '--',
          //   onTap: _reportFn,
          //   isShowMoreIcon: _isGroupMember,
          // ),
          // GroupItemBuild(
          //   title: Localized.text('ox_chat.group_notice'),
          //   titleDes: _getGroupNotice,
          //   onTap: _updateGroupNoticeFn,
          //   isShowMoreIcon: _isGroupMember,
          // ),
        ],
      ),
    );
  }

  void _searchChatHistoryFn() async {
    OXNavigator.pushPage(
      context,
          (context) => SearchPage(
        searchPageType: SearchPageType.singleSessionRelated,
        forceFirstPage: true,
        chatMessage: ChatMessage(
          widget.groupId,
          '',
          groupDBInfo?.name ?? '',
          '',
          '',
          ChatType.chatRelayGroup,
          1,
        ),
      ),
    );
  }

  void _clearChatHistoryFn() async {

  }

  void _reportFn() async {

  }

  Widget _muteWidget() {
    return Container(
      margin: EdgeInsets.only(top: 16.px),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Adapt.px(16)),
        color: ThemeColor.color180,
      ),
      child: Column(
        children: [
          ///Remark
          ///Alias
          GroupItemBuild(
            title: Localized.text('ox_chat.mute_item'),
            isShowDivider: false,
            actionWidget: _muteSwitchWidget(),
            isShowMoreIcon: false,
          ),
        ],
      ),
    );
  }

  Widget _muteSwitchWidget() {
    return Container(
      height: Adapt.px(25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Switch(
            value: _isMute,
            activeColor: Colors.white,
            activeTrackColor: ThemeColor.gradientMainStart,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: ThemeColor.color160,
            onChanged: (value) => _changeMuteFn(value),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
        ],
      ),
    );
  }

  Widget _leaveBtnWidget() {
    String content = !_isGroupMember || _hasDeleteGroupPermission ? Localized.text('ox_chat.delete_and_leave_item') : Localized.text('ox_chat.str_leave_group');
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: 16.px),
        width: double.infinity,
        height: Adapt.px(48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ThemeColor.color180,
        ),
        alignment: Alignment.center,
        child: Text(
          content,
          style: TextStyle(
            color: ThemeColor.red,
            fontSize: Adapt.px(16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () {
        ChatSessionUtils.leaveConfirmWidget(context, ChatType.chatRelayGroup, widget.groupId, isGroupMember: _isGroupMember, hasDeleteGroupPermission: _hasDeleteGroupPermission);
      },
    );
  }

  void _updateGroupHistoryStatusFn() async {
    var result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChatHistoryForNewMembersSelectorDialog(titleTxT: 'str_chat_history_for_new_members_change_type_hint'.localized(), isChangeType: true,);
      },
    );
    if (result != null && result is ChatHistoryForNewMembersType) {
      await OXLoading.show();
      bool privateType = result == ChatHistoryForNewMembersType.show ? false : true;
      OKEvent event = await RelayGroup.sharedInstance
          .editMetadata(widget.groupId, groupDBInfo?.name ?? '', groupDBInfo?.about ?? '', groupDBInfo?.picture ?? '', groupDBInfo?.closed ?? false, privateType, '');
      await OXLoading.dismiss();
      if (!event.status) return CommonToast.instance.show(context, event.message);
      setState(() {
        RelayGroupDBISAR? groupDB = RelayGroup.sharedInstance.groups[widget.groupId]?.value;
        if (groupDB != null) {
          groupDBInfo = groupDB;
        }
      });
    }
  }

  void _updateGroupTypeFn() async {
    var result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GroupCreateSelectorDialog(titleTxT: 'str_group_type_change_hint'.localized(), isChangeType: true,);
      },
    );
    if (result != null && result is GroupType) {
      await OXLoading.show();
      bool privateType = result == GroupType.openGroup ? false : true;
      OKEvent event = await RelayGroup.sharedInstance
          .editMetadata(widget.groupId, groupDBInfo?.name ?? '', groupDBInfo?.about ?? '', groupDBInfo?.picture ?? '', privateType, groupDBInfo?.private ?? false, '');
      await OXLoading.dismiss();
      if (!event.status) return CommonToast.instance.show(context, event.message);
      setState(() {
        RelayGroupDBISAR? groupDB = RelayGroup.sharedInstance.groups[widget.groupId]?.value;
        if (groupDB != null) {
          groupDBInfo = groupDB;
        }
      });
    }
  }

  void _updateGroupNoticeFn() async {

  }

  void _groupRequestFn() async {
    OXNavigator.pushPage(context, (context) => RelayGroupRequestsPage(groupId: widget.groupId)).then((value) {
      _loadMembers();
    });
  }

  void _manageGroupFn() async {
    await OXNavigator.pushPage(
      context,
          (context) => RelayGroupManageAdminsPage(
        relayGroupDB: groupDBInfo!,
        admins: groupDBInfo!.admins ?? [],
      ),
    );
    _groupInfoInit();
  }

  void _gotoGroupNotesFn() async {
   await OXModuleService.pushPage(
      context,
      'ox_discovery',
      'GroupMomentsPage',
      {
        'groupId': widget.groupId,
      },
    );
  }

  void _groupQrCodeFn(bool isQrCode) {
    if (isQrCode) {
      OXNavigator.pushPage(
        context,
            (context) => GroupSettingQrcodePage(
          groupId: widget.groupId,
          groupType: groupDBInfo != null && groupDBInfo!.closed ? GroupType.closeGroup : GroupType.openGroup,
        ),
      );
    } else {
      GroupShareUtils.shareGroup(context, widget.groupId,
        groupDBInfo != null && groupDBInfo!.closed ? GroupType.closeGroup : GroupType.openGroup,);
    }
  }

  void _DisableShareDialog(bool isQrCode) {
    if ((groupDBInfo != null && !groupDBInfo!.closed) || (groupDBInfo != null && groupDBInfo!.closed && _hasAddUserPermission)) return _groupQrCodeFn(isQrCode);
    OXCommonHintDialog.show(
      context,
      title: "",
      content: Localized.text('ox_chat.enabled_group_join_verification'),
      actionList: [
        OXCommonHintAction.sure(
            text: Localized.text('ox_common.confirm'),
            onTap: () {
              OXNavigator.pop(context);
              if (isQrCode){
                OXNavigator.pushPage(
                  context,
                  (context) => GroupSettingQrcodePage(
                    groupId: widget.groupId,
                    groupType: groupDBInfo != null && groupDBInfo!.closed ? GroupType.closeGroup : GroupType.openGroup,
                  ),
                );
              } else {
                OXNavigator.pushPage(
                  context,
                  (context) => ContactGroupMemberPage(
                    groupId: widget.groupId,
                    groupType: groupDBInfo != null && groupDBInfo!.closed ? GroupType.closeGroup : GroupType.openGroup,
                  ),
                  type: OXPushPageType.present,
                );
              }
            }),
      ],
      isRowAction: true,
    );
  }

  void _shareGroupFn() {
    _DisableShareDialog(false);
  }

  void _changeMuteFn(bool value) async {
    if (!_isGroupMember) {
      CommonToast.instance.show(context, Localized.text('ox_chat.group_mute_no_member_toast'));
      return;
    }
    await OXLoading.show();
    if (value) {
      await RelayGroup.sharedInstance.muteGroup(widget.groupId);
      CommonToast.instance.show(context, Localized.text('ox_chat.group_mute_operate_success_toast'));
    } else {
      await RelayGroup.sharedInstance.unMuteGroup(widget.groupId);
      CommonToast.instance.show(context, Localized.text('ox_chat.group_mute_operate_success_toast'));
    }
    final bool result = await OXUserInfoManager.sharedInstance.setNotification();
    await OXLoading.dismiss();
    if (result) {
      if (mounted)
        OXChatBinding.sharedInstance.sessionUpdate();
        setState(() {
          _isMute = value;
        });
    } else {
      CommonToast.instance.show(context, 'mute_fail_toast'.localized());
    }
  }

  void _groupMemberOptionFn(GroupListAction action) async {
    bool? result = await OXNavigator.pushPage(
      context,
      (context) => ContactGroupMemberPage(
        groupId: widget.groupId,
        groupType: groupDBInfo != null ? (groupDBInfo!.closed ? GroupType.closeGroup : GroupType.openGroup) : null,
      ),
      type: OXPushPageType.present,
    );
    if (result != null && result) _groupInfoInit();
  }

  void _groupInfoInit() {
    String groupId = widget.groupId;
    RelayGroupDBISAR? groupDB = RelayGroup.sharedInstance.groups[groupId]?.value;
    if (groupDB != null) {
      groupDBInfo = groupDB;
      _isMute = groupDB.mute;
      _getPermissionValue();
      setState(() {});
      _loadMembers();
    }
  }

  void _getIsGroupMemberValue(List<UserDBISAR> memberUserDBs) {
    UserDBISAR? userInfo = Account.sharedInstance.me;
    if (userInfo == null) {
      _isGroupMember = false;
    } else {
      _isGroupMember = memberUserDBs.any((userDB) => userDB.pubKey == userInfo.pubKey);
    }
  }

  void _loadMembers() async {
    List<UserDBISAR> localMembers = await RelayGroup.sharedInstance.getGroupMembersFromLocal(widget.groupId);
    if (localMembers.isNotEmpty) {
      groupMember = localMembers;
      _getIsGroupMemberValue(localMembers);
    }
    setState(() {});
  }

  void _loadDataFromRelay() async {
    RelayGroup.sharedInstance.getGroupMetadataFromRelay(widget.groupId).then((relayGroupDB) {
      if (!mounted) return ;
      if (relayGroupDB != null) {
        setState(() {
          groupDBInfo = relayGroupDB;
          _isMute = relayGroupDB.mute;
          _getPermissionValue();
        });
      }
      RelayGroup.sharedInstance.getGroupMembersFromLocal(widget.groupId).then((value){
        groupMember = value;
        _getIsGroupMemberValue(value);
        setState(() {});
      });
    });
  }
}
