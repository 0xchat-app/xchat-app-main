import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/account_models.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import '../utils/username_generator.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    super.key,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _setupDefaultValue();
    _silentlySaveAvatar();
  }

  void _setupDefaultValue() {
    final account = LoginManager.instance.currentState.account;
    if (account == null) return;

    final npub = account.getEncodedPubkey();
    _nameController.text = UsernameGenerator.generateUsername(npub);
    _avatarUrl = OXUserAvatar.clientAvatar(npub);
  }

  Future<void> _silentlySaveAvatar() async {
    final user = Account.sharedInstance.me;
    if (user == null) return;
    
    final account = LoginManager.instance.currentState.account;
    if (account == null) return;

    final npub = account.getEncodedPubkey();
    final avatarUrl = OXUserAvatar.clientAvatar(npub);
    
    user.picture = avatarUrl;
    await Account.sharedInstance.updateProfile(user);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoseFocusWrap(
      child: CLScaffold(
        appBar: CLAppBar(
          actions: [
            CLButton.text(
              text: Localized.text('ox_common.skip'),
              onTap: _onSkipTap,
            ),
          ],
        ),
        body: _buildBody(),
        bottomWidget: _buildActionButtons(),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 24.px,
        horizontal: CLLayout.horizontalPadding,
      ),
      children: [
        _buildNicknameHeader(),
        SizedBox(height: 12.px),
        _buildNameSection(),
        // SizedBox(height: 24.px),
        // _buildInfoSection(),
      ],
    );
  }

  Widget _buildNicknameHeader() {
    final title = Localized.text('ox_login.setup_profile_header_title');
    final subtitle = Localized.text('ox_login.setup_profile_header_subtitle');
    return Column(
      children: [
        CLText.titleLarge(
          title,
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLText.bodyMedium(
          subtitle,
          colorToken: ColorToken.onSurfaceVariant,
          textAlign: TextAlign.center,
          maxLines: null,
        ),
        SizedBox(height: 16.px),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLTextField(
          controller: _nameController,
          placeholder: Localized.text('ox_login.profile_name_placeholder'),
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 8.px),
        CLDescription(Localized.text('ox_login.profile_name_hint')),
      ],
    );
  }

  Widget _buildActionButtons() {
    return CLButton.filled(
      text: _isSaving
          ? Localized.text('ox_common.loading')
          : Localized.text('ox_login.save_profile'),
      onTap: !_isSaving ? _onSaveProfileTap : null,
      expanded: true,
      height: 48.px,
    );
  }

  Future<void> _onSaveProfileTap() async {
    if (_isSaving) return;

    setState(() { _isSaving = true; });

    try {
      OXLoading.show();
      final user = Account.sharedInstance.me;
      if (user == null) {
        CommonToast.instance.show(context, 'Current user info is null.');
        return;
      }
      user.name = _nameController.text.trim();
      Account.sharedInstance.updateProfile(user);
      OXLoading.dismiss();
      if (mounted) OXNavigator.popToRoot(context);
    } catch (e) {
      OXLoading.dismiss();
      setState(() { _isSaving = false; });
      if (mounted) {
        CommonToast.instance.show(context, 'Failed to save nickname: ${e.toString()}');
      }
    }
  }

  void _onSkipTap() {
    OXNavigator.popToRoot(context);
  }
}
