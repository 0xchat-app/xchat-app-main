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
import '../utils/avatar_generator.dart';
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
  }

  Future<void> _setupDefaultValue() async {
    final account = LoginManager.instance.currentState.account;
    if (account == null) return;

    final npub = account.getEncodedPubkey();
    _nameController.text = UsernameGenerator.generateUsername(npub);
    _avatarUrl = 'generated_avatar_$npub';
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
        _buildHeader(),
        SizedBox(height: 12.px),
        _buildAvatarSection(),
        SizedBox(height: 12.px),
        _buildNameSection(),
        // SizedBox(height: 24.px),
        // _buildInfoSection(),
      ],
    );
  }

  Widget _buildHeader() {
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Hero(
          tag: 'profile_avatar_hero',
          child: _buildAvatarWidget(),
        ),
        SizedBox(height: 12.px),
        CLButton.tonal(
          child: CLText.labelLarge('Edit Photo'),
          height: 30.px,
          padding: EdgeInsets.symmetric(
            horizontal: 12.px,
            vertical: 5.px,
          ),
          onTap: _onAvatarTap,
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          'Nickname',
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
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

  Widget _buildInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.px),
      decoration: BoxDecoration(
        color: ColorToken.surfaceContainer.of(context),
        borderRadius: BorderRadius.circular(12.px),
        border: Border.all(
          color: ColorToken.onSurfaceVariant.of(context).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.px,
                color: ColorToken.primary.of(context),
              ),
              SizedBox(width: 8.px),
              CLText.titleSmall(
                Localized.text('ox_login.profile_info_title'),
                colorToken: ColorToken.primary,
              ),
            ],
          ),
          SizedBox(height: 12.px),
          CLText.bodySmall(
            Localized.text('ox_login.profile_info_content'),
            colorToken: ColorToken.onSurfaceVariant,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget() {
    if (_avatarUrl != null && _avatarUrl!.startsWith('generated_avatar_')) {
      final npub = _avatarUrl!.replaceFirst('generated_avatar_', '');
      if (npub.isNotEmpty) {
        return GestureDetector(
          onTap: _onAvatarTap,
          child: AvatarGenerator.instance.generateAvatar(
            npub,
            size: 100.px,
            borderRadius: 50.px,
          ),
        );
      }
    }

    return OXUserAvatar(
      imageUrl: _avatarUrl,
      size: 100.px,
      onTap: _onAvatarTap,
    );
  }

  Future<void> _onAvatarTap() async {
    await _openAvatarDisplayPage();
    if (mounted) setState(() {});
  }

  Future<void> _openAvatarDisplayPage() async {
    try {
      await OXModuleService.pushPage(
        context,
        'ox_usercenter',
        'AvatarDisplayPage',
        {
          'heroTag': 'profile_avatar_hero',
          'avatarUrl': _avatarUrl,
          'showEditButton': true,
        },
      );
    } catch (_) {
      await _showAvatarUrlDialog();
    }
  }

  Future<void> _showAvatarUrlDialog() async {
    final TextEditingController urlController = TextEditingController(text: _avatarUrl ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: CLText.titleMedium(Localized.text('ox_login.enter_avatar_url')),
        content: CLTextField(
          controller: urlController,
          placeholder: 'https://example.com/avatar.jpg',
        ),
        actions: [
          CLButton.text(
            text: Localized.text('ox_common.cancel'),
            onTap: () => OXNavigator.pop(context),
          ),
          CLButton.filled(
            text: Localized.text('ox_common.confirm'),
            onTap: () => OXNavigator.pop(context, urlController.text.trim()),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _avatarUrl = result;
      });
    }
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
      user.picture = _avatarUrl;
      final success = (await Account.sharedInstance.updateProfile(user)) != null;
      OXLoading.dismiss();

      if (success) {
        if (mounted) OXNavigator.popToRoot(context);
      } else {
        setState(() { _isSaving = false; });
        if (mounted) {
          CommonToast.instance.show(context, Localized.text('ox_login.profile_save_failed'));
        }
      }
    } catch (e) {
      OXLoading.dismiss();
      setState(() { _isSaving = false; });
      if (mounted) {
        CommonToast.instance.show(context, 'Failed to save profile: ${e.toString()}');
      }
    }
  }

  void _onSkipTap() {
    OXNavigator.popToRoot(context);
  }
}
