
import 'dart:async';
import 'dart:io';
import 'package:chatcore/chat-core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_module_service/ox_module_service.dart';

import 'avatar_generator.dart';

class BaseAvatarWidget extends StatelessWidget {
  BaseAvatarWidget({
    required this.imageUrl,
    required this.defaultImageName,
    required this.size,
    this.isCircular = false,
    this.isClickable = false,
    this.onTap,
    this.onLongPress,
  });

  final String imageUrl;
  final String defaultImageName;
  final double size;
  final bool isCircular;
  final bool isClickable;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final radius = isCircular ? size : CLLayout.avatarRadius;
    return GestureDetector(
      onTap: isClickable ? onTap : null,
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: _buildAvatar(),
      ),
    );
  }


  Widget _buildAvatar() {
    if (imageUrl.isNotEmpty) {
      return CLCachedNetworkImage(
        errorWidget: (context, url, error) => _defaultImage(defaultImageName, size),
        placeholder: (context, url) => _defaultImage(defaultImageName, size),
        fit: BoxFit.cover,
        imageUrl: imageUrl,
        width: size,
        height: size,
        isThumb: true,
      );
    } else {
      return _defaultImage(defaultImageName, size);
    }
  }

  Image _defaultImage(String imageName, double size) => Image.asset(
    'assets/images/$imageName',
    fit: BoxFit.contain,
    width: size,
    height: size,
    package: 'ox_common',
  );
}

class OXUserAvatar extends StatefulWidget {

  OXUserAvatar({
    this.isSecretChat = false,
    this.user,
    this.imageUrl,
    this.chatId,
    double? size,
    this.isCircular = true,
    this.isClickable = false,
    this.onReturnFromNextPage,
    this.onTap,
    this.onLongPress,
  }) : this.size = size ?? Adapt.px(48);

  final bool isSecretChat;
  final UserDBISAR? user;
  final String? imageUrl;
  final String? chatId;
  final double size;
  final bool isCircular;
  final bool isClickable;
  final VoidCallback? onReturnFromNextPage;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  static String get _clientAvatarPrefix => 'generated_avatar_';
  static String clientAvatar(String value) => '${_clientAvatarPrefix}$value';
  static bool isClientAvatar(String avatar) => avatar.startsWith(_clientAvatarPrefix);

  @override
  State<StatefulWidget> createState() => OXUserAvatarState();
}

class OXUserAvatarState extends State<OXUserAvatar> {

  final defaultImageName = 'icon_user_default.png';

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.user?.picture ?? widget.imageUrl ?? '';
    if (OXUserAvatar.isClientAvatar(imageUrl)) {
      final npub = imageUrl.replaceFirst(OXUserAvatar._clientAvatarPrefix, '');
      if (npub.isNotEmpty) {
        return ClientAvatar(
          npub: npub,
          size: widget.size,
          isCircular: widget.isCircular,
          isClickable: widget.onTap != null || widget.isClickable,
          onTap: userAvatarOnTap,
          onLongPress: widget.onLongPress,
        );
      }
    }

    return BaseAvatarWidget(
      imageUrl: imageUrl,
      defaultImageName: defaultImageName,
      size: widget.size,
      isCircular: widget.isCircular,
      isClickable: widget.onTap != null || widget.isClickable,
      onTap: userAvatarOnTap,
      onLongPress: widget.onLongPress,
    );
  }

  void userAvatarOnTap() async {
    if (widget.onTap != null) {
      widget.onTap!.call();
    } else {
      final user = widget.user;
      if (user == null) {
        CommonToast.instance.show(context, 'User not found');
        return ;
      }
      await OXModuleService.pushPage(context, 'ox_chat', 'ContactUserInfoPage', {
        'pubkey': user.pubKey,
        'chatId': widget.chatId,
        'isSecretChat':widget.isSecretChat
      });
      final onReturnFromNextPage = widget.onReturnFromNextPage;
      if (onReturnFromNextPage != null) onReturnFromNextPage();
    }
  }
}

class OXGroupAvatar extends StatefulWidget {

  OXGroupAvatar({
    this.groupId,
    this.group,
    this.imageUrl,
    double? size,
    this.isCircular = true,
    this.isClickable = false,
    this.onReturnFromNextPage,
  }) : this.size = size ?? Adapt.px(48);

  final String? groupId;
  final GroupDBISAR? group;
  final String? imageUrl;
  final double size;
  final bool isCircular;
  final bool isClickable;
  final VoidCallback? onReturnFromNextPage;

  @override
  State<StatefulWidget> createState() => OXGroupAvatarState();
}

class OXGroupAvatarState extends State<OXGroupAvatar> {

  final defaultImageName = 'icon_group_default.png';

  List<String> _avatars = [];

  String get groupId => widget.groupId ?? widget.group?.privateGroupId ?? '';

  late Future _imageLoader;

  @override
  void initState() {
    super.initState();
    _imageLoader = _getMembers();
  }

  Future _getMembers() async {
    List<UserDBISAR> groupList = await Groups.sharedInstance.getAllGroupMembers(groupId);
    _avatars = groupList.map((element) => element.picture ?? '').toList();
    _avatars.removeWhere((element) => element.isEmpty);
  }

  @override
  void didUpdateWidget(covariant OXGroupAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupId != oldWidget.groupId || widget.group != oldWidget.group) {
      _getMembers().then((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _imageLoader,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || _avatars.isEmpty) {
          return BaseAvatarWidget(
            defaultImageName: defaultImageName,
            size: widget.size,
            imageUrl: '',
            isCircular: widget.isCircular,
            isClickable: widget.isClickable,
            onTap: _onTap,
          );
        }
        return GroupedAvatar(
          avatars: _avatars,
          size: widget.size,
          isCircular: widget.isCircular,
          isClickable: widget.isClickable,
          onTap: _onTap,
        );
      },
    );
  }

  void _onTap() async {
    final groupDB = widget.group;
    if (groupDB != null) {
      await OXModuleService.pushPage(context, 'ox_chat', 'GroupInfoPage', {
        'groupId': groupDB.privateGroupId,
      });
    }
  }
}

class GroupedAvatar extends StatelessWidget {
  final List<String> avatars;
  final double size;
  final bool isCircular;
  final bool isClickable;
  final GestureTapCallback? onTap;

  const GroupedAvatar({
    super.key,
    required this.avatars,
    required this.size,
    this.isCircular = true,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double smallSize = 0;
    List<String> avatarList = avatars;
    List<Widget> avatarWidgetList = [];

    if (avatarList.length <= 4) {
      smallSize = avatarList.length <= 2 ? size * 0.66 : size * 0.5;
    } else {
      smallSize = size / 3;
      avatarList = avatarList.length > 9 ? avatarList.sublist(0, 9) : avatarList;
    }
    avatarWidgetList = avatars.map((element) => _buildSingleAvatar(smallSize, element)).toList();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isClickable ? onTap : null,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: _buildGroupedAvatar(avatarWidgetList),
      ),
    );
  }

  Widget _buildGroupedAvatar(List<Widget> avatarWidgetList) {
    if (avatars.isEmpty) return _buildDefaultGroupedAvatar(size);
    if (avatars.length == 2) {
      return Stack(
        children: [
          Positioned(right: 0, top: 0, child: avatarWidgetList[1]),
          Positioned(left: 0, bottom: 0, child: avatarWidgetList[0]),
        ],
      );
    } else if (avatars.length <= 4) {
      return Wrap(
        children: avatarWidgetList,
      );
    } else {
      return Wrap(
        children: avatarWidgetList,
      );
    }
  }

  Widget _buildSingleAvatar(double size, String imageUrl) {
    final defaultImageName = 'icon_user_default.png';
    return BaseAvatarWidget(
      imageUrl: imageUrl,
      defaultImageName: defaultImageName,
      size: size,
      isCircular: isCircular,
    );
  }

  Widget _buildDefaultGroupedAvatar(double size){
    final defaultImageName = 'icon_group_default.png';
    return BaseAvatarWidget(
      defaultImageName: defaultImageName,
      size: size,
      imageUrl: '',
      isCircular: isCircular,
      isClickable: isClickable,
    );
  }
}

class ClientAvatar extends StatefulWidget {
  const ClientAvatar({
    super.key,
    required this.npub,
    required this.size,
    this.isCircular = false,
    this.isClickable = false,
    this.onTap,
    this.onLongPress,
  });

  final String npub;
  final double size;
  final bool isCircular;
  final bool isClickable;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  @override
  State<StatefulWidget> createState() => _ClientAvatarState();
}

class _ClientAvatarState extends State<ClientAvatar> {
  late Future<File?> imageFile;

  @override
  void initState() {
    super.initState();
    imageFile = AvatarGenerator.instance.generateAvatar(npub: widget.npub);
  }

  @override
  void didUpdateWidget(covariant ClientAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.npub != widget.npub) {
      imageFile = AvatarGenerator.instance.generateAvatar(npub: widget.npub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.isCircular ? widget.size : CLLayout.avatarRadius;
    return GestureDetector(
      onTap: widget.isClickable ? widget.onTap : null,
      onLongPress: widget.onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FutureBuilder<File?>(
          future: imageFile,
          builder: (context, snapshot) {
            final file = snapshot.data;
            if (!snapshot.hasData || file == null) return SizedBox();
            return Image.file(
              file,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}