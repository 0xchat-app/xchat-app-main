import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/account_models.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/took_kit.dart';
import 'package:ox_localizable/ox_localizable.dart';

class KeysPage extends StatefulWidget {

  const KeysPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<StatefulWidget> createState() {
    return _KeysPageState();
  }

}
enum KeyType { PublicKey, PrivateKey }
class _KeysPageState extends State<KeysPage>{

  ValueNotifier<bool> isShowPriv$ = ValueNotifier(false);

  String encodedPubkey = '';
  String encodedPrivkey = '';

  @override
  void initState() {
    super.initState();

    final account = LoginManager.instance.currentState.account;
    encodedPubkey = account?.getEncodedPubkey() ?? '';
    encodedPrivkey = account?.getEncodedPrivkey() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.keys'),
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: _body(),
    );
  }

  Widget _body() {
    return ValueListenableBuilder(
      valueListenable: isShowPriv$,
      builder: (context, isShowPriv, _) {
        return CLSectionListView(
          items: [
            SectionListViewItem(
              data: [
                CustomItemModel(
                  title: Localized.text('ox_login.public_key'),
                  subtitleWidget: CLText(
                    encodedPubkey,
                    maxLines: 2,
                  ),
                  trailing: Icon(
                    Icons.copy_rounded,
                    color: ColorToken.onSecondaryContainer.of(context),
                  ),
                  onTap: pubkeyItemOnTap,
                ),
                CustomItemModel(
                  title: Localized.text('ox_login.private_key'),
                  subtitleWidget: CLText(
                    isShowPriv ? encodedPrivkey
                        : List.filled(encodedPrivkey.length, '*').join(),
                    maxLines: 2,
                  ),
                  trailing: Icon(
                    Icons.copy_rounded,
                    color: ColorToken.onSecondaryContainer.of(context),
                  ),
                  onTap: privkeyItemOnTap,
                ),
              ],
            ),
          ],
          footer: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.px, vertical: 16.px),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildShowButton(),
                buildLogoutButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildShowButton() {
    return CLButton.tonal(
      height: 48,
      padding: EdgeInsets.symmetric(
        horizontal: 12.px,
        vertical: 12.px,
      ),
      expanded: true,
      text: 'Show Private Key',
      onTap: () => isShowPriv$.value = true,
    );
  }

  Widget buildLogoutButton() {
    return CLButton.text(
      padding: EdgeInsets.symmetric(
        horizontal: 12.px,
        vertical: 12.px,
      ),
      color: ColorToken.error.of(context),
      text: 'Logout',
      onTap: () async {
        final shouldLogout = await CLAlertDialog.show<bool>(
          context: context,
          title: Localized.text('ox_usercenter.warn_title'),
          content: Localized.text('ox_usercenter.sign_out_dialog_content'),
          actions: [
            CLAlertAction.cancel(),
            CLAlertAction<bool>(
              label: Localized.text('ox_usercenter.Logout'),
              value: true,
              isDestructiveAction: true,
            ),
          ],
        );
        
        if (shouldLogout == true) {
          LoginManager.instance.logout();
          if (PlatformStyle.isUseMaterial) {
            OXNavigator.popToRoot(context);
          } else {
            CupertinoSheetRoute.popSheet(context);
          }
        }
      }
    );
  }

  void pubkeyItemOnTap () async {
    await TookKit.copyKey(
      context,
      encodedPubkey,
    );
  }

  void privkeyItemOnTap() async {
    await TookKit.copyKey(
      context,
      encodedPrivkey,
    );
  }
}