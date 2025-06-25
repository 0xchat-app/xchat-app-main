import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/theme_color.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/widgets/common_appbar.dart';
import 'dart:io';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_button.dart';
import 'package:ox_common/widgets/common_image.dart';
import 'package:ox_common/widgets/common_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_usercenter/widget/select_asset_dialog.dart';

class AvatarPreviewPage extends StatefulWidget {
  final File? imageFile;
  final UserDBISAR? userDB;

  const AvatarPreviewPage({this.imageFile, this.userDB, Key? key}) : super(key: key);

  @override
  State<AvatarPreviewPage> createState() => _AvatarPreviewPageState();
}

class _AvatarPreviewPageState extends State<AvatarPreviewPage> with WidgetsBindingObserver {
  UserDBISAR? mUserDB;
  File? imageFile;
  bool _isShowMenu = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mUserDB = widget.userDB;
    if (mUserDB != null && mUserDB!.pubKey == Account.sharedInstance.me!.pubKey) {
      _isShowMenu = true;
    }
    if (widget.imageFile != null) {
      imageFile = widget.imageFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.color200,
      appBar: CommonAppBar(
        title: Localized.text('ox_usercenter.Profile picture'),
        useLargeTitle: false,
        centerTitle: true,
        canBack: true,
        actions: !_isShowMenu
            ? null
            : <Widget>[
                Container(
                  margin: EdgeInsets.only(right: Adapt.px(5)),
                  color: Colors.transparent,
                  child: OXButton(
                    highlightColor: Colors.transparent,
                    color: Colors.transparent,
                    minWidth: Adapt.px(44),
                    height: Adapt.px(44),
                    child: CommonImage(
                      iconName: "nav_more_new.png",
                      color: ThemeColor.color0,
                      width: Adapt.px(24),
                      height: Adapt.px(24),
                    ),
                    onPressed: () async {
                      Map? selectAssetDialog = await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => const SelectAssetDialog(),
                      );
                      if(selectAssetDialog == null) return;
                      SelectAssetAction action = selectAssetDialog['action'];
                      File? imgFile = selectAssetDialog['result'];
                      if(action == SelectAssetAction.Remove){
                        setState(() {
                          imageFile = null;
                        });
                        OXNavigator.pop(context, selectAssetDialog);
                      }
                      else if (imgFile != null) {
                        setState(() {
                          imageFile = imgFile;
                        });
                        // 07/04 requirement change
                        OXNavigator.pop(context, selectAssetDialog);
                      }
                    },
                  ),
                ),
              ],
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    final imageWidth = MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height;
    String localAvatarPath = 'assets/images/user_image.png';
    Image placeholderImage = Image.asset(
      localAvatarPath,
      fit: BoxFit.cover,
      width: imageWidth,
      height: imageHeight,
      package: 'ox_common',
    );
    return Container(
      color: ThemeColor.color200,
      width: imageWidth,
      height: imageHeight,
      child: Align(
          alignment: const Alignment(1, -0.5),
          child: imageFile != null
              ? PhotoView(
                  imageProvider: FileImage(imageFile!, scale: 1),
                  errorBuilder: (_, __, ___) {
                    return placeholderImage;
                  })
              : PhotoView(
                  imageProvider: OXCachedImageProviderEx.create('${mUserDB?.picture}', width: imageWidth),
                  errorBuilder: (_, __, ___) {
                    return placeholderImage;
                  })),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && imageFile == null) {
      OXLoading.dismiss();
    }
  }
}
