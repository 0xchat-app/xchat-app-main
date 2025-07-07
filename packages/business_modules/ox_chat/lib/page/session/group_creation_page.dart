import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/chat_session_model_isar.dart';
import 'package:ox_common/model/chat_type.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';

import 'chat_message_page.dart';

class GroupCreationPage extends StatefulWidget {
  final List<SelectableUser> selectedUsers;

  const GroupCreationPage({
    super.key,
    required this.selectedUsers,
  });

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  final TextEditingController _groupNameController = TextEditingController();
  String? _groupAvatarUrl;

  @override
  void initState() {
    super.initState();
    _initializeGroupName();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _initializeGroupName() {
    // Generate default group name
    final myName = Account.sharedInstance.me?.name ?? 'Me';
    if (widget.selectedUsers.length == 1) {
      _groupNameController.text = '${widget.selectedUsers.first.displayName} & $myName';
    } else {
      _groupNameController.text = '$myName\'s Group';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_chat.str_new_group'),
        actions: [
          CLButton.text(
            text: Localized.text('ox_common.create'),
            onTap: _onCreateGroup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupInfoSection(),
            SizedBox(height: 24.px),
            _buildMembersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: ThemeColor.color190,
        borderRadius: BorderRadius.circular(12.px),
      ),
      child: Row(
        children: [
          // Group avatar
          GestureDetector(
            onTap: _onSelectGroupAvatar,
            child: Container(
              width: 64.px,
              height: 64.px,
              decoration: BoxDecoration(
                color: ThemeColor.color180,
                borderRadius: BorderRadius.circular(32.px),
              ),
              child: _groupAvatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.px),
                      child: Image.network(
                        _groupAvatarUrl!,
                        width: 64.px,
                        height: 64.px,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 24.px,
                      color: ThemeColor.color100,
                    ),
            ),
          ),
          SizedBox(width: 16.px),
          // Group name input
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CLText.bodyMedium(
                  Localized.text('ox_chat.group_name'),
                  colorToken: ColorToken.onSurfaceVariant,
                ),
                SizedBox(height: 8.px),
                CLTextField(
                  controller: _groupNameController,
                  placeholder: Localized.text('ox_chat.group_enter_hint_text'),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.bodyLarge(
          '${Localized.text('ox_chat.group_member')} (${widget.selectedUsers.length + 1})',
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        Container(
          decoration: BoxDecoration(
            color: ThemeColor.color190,
            borderRadius: BorderRadius.circular(12.px),
          ),
          child: Column(
            children: [
              // Current user (me)
              _buildMemberItem(
                avatarUrl: Account.sharedInstance.me?.picture,
                name: Account.sharedInstance.me?.name ?? 'Me',
                subtitle: 'Admin',
                isMe: true,
              ),
              // Selected users
              ...widget.selectedUsers.map((user) => _buildMemberItem(
                    avatarUrl: user.avatarUrl,
                    name: user.displayName,
                    subtitle: '',
                    isMe: false,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberItem({
    required String? avatarUrl,
    required String name,
    required String subtitle,
    required bool isMe,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 12.px),
      child: Row(
        children: [
          OXUserAvatar(
            user: null,
            imageUrl: avatarUrl,
            size: 40.px,
          ),
          SizedBox(width: 12.px),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CLText.bodyMedium(
                  name,
                  colorToken: ColorToken.onSurface,
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.px),
                  CLText.bodySmall(
                    subtitle,
                    colorToken: ColorToken.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectGroupAvatar() {
    // TODO: Implement group avatar selection
    CommonToast.instance.show(context, 'Group avatar selection coming soon');
  }

  void _onCreateGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_chat.group_enter_hint_text'));
      return;
    }

    final myPubkey = Account.sharedInstance.me?.pubKey;
    if (myPubkey == null || myPubkey.isEmpty) {
      CommonToast.instance.show(context, 'Current account is null');
      return;
    }

    final circle = LoginManager.instance.currentCircle;
    if (circle == null) {
      CommonToast.instance.show(context, 'Current circle is null');
      return;
    }

    await OXLoading.show();

    try {
      // Build group member list (including current user)
      final memberPubkeys = widget.selectedUsers.map((u) => u.id).toList();
      memberPubkeys.add(myPubkey);

      // Create MLS group
      GroupDBISAR? groupDB = await Groups.sharedInstance.createMLSGroup(
        groupName,
        '', // Group description
        memberPubkeys,
        [myPubkey], // Admin list
        [circle.relayUrl],
      );

      await OXLoading.dismiss();

      if (groupDB == null) {
        CommonToast.instance.show(context, Localized.text('ox_chat.create_group_fail_tips'));
        return;
      }

      // Close all previous pages and navigate to group chat
      OXNavigator.popToRoot(context);

      // Navigate to group chat page
      ChatMessagePage.open(
        context: OXNavigator.navigatorKey.currentContext,
        communityItem: ChatSessionModelISAR(
          chatId: groupDB.privateGroupId,
          groupId: groupDB.privateGroupId,
          chatType: ChatType.chatGroup,
          chatName: groupDB.name,
          createTime: groupDB.updateTime,
          avatar: groupDB.picture,
        ),
      );
    } catch (e) {
      await OXLoading.dismiss();
      CommonToast.instance.show(context, e.toString());
    }
  }
} 