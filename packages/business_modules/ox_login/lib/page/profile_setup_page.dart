import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import '../utils/avatar_generator.dart';
import '../utils/username_generator.dart';

/// Profile setup page for creating/updating user profile
/// 
/// This page allows users to set up their profile after login/registration.
/// Users can skip this step if they want to go directly to home.
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    super.key,
    this.isNewAccount = false,
  });

  final bool isNewAccount;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isSaving = false;
  String? _avatarUrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ProfileSetupPage initialized, isNewAccount: ${widget.isNewAccount}');
    _loadCurrentProfile();
    _nameController.addListener(_onInputChanged);
    _bioController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isNewAccount 
        ? Localized.text('ox_login.setup_profile_title')
        : Localized.text('ox_login.update_profile_title');
    
    return CLScaffold(
      appBar: CLAppBar(
        title: title,
        actions: [
          // Skip button
          CLButton.text(
            text: Localized.text('ox_common.skip'),
            onTap: _onSkipTap,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(24.px),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32.px),
            _buildAvatarSection(),
            SizedBox(height: 24.px),
            _buildNameSection(),
            SizedBox(height: 24.px),
            _buildBioSection(),
            SizedBox(height: 32.px),
            _buildActionButtons(),
            SizedBox(height: 24.px),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = widget.isNewAccount 
        ? Localized.text('ox_login.setup_profile_header_title')
        : Localized.text('ox_login.update_profile_header_title');
    
    final subtitle = widget.isNewAccount
        ? Localized.text('ox_login.setup_profile_header_subtitle')
        : Localized.text('ox_login.update_profile_header_subtitle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleLarge(
          title,
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLText.bodyMedium(
          subtitle,
          colorToken: ColorToken.onSurfaceVariant,
          maxLines: null,
        ),
        if (widget.isNewAccount) ...[
          SizedBox(height: 16.px),
          Container(
            padding: EdgeInsets.all(12.px),
            decoration: BoxDecoration(
              color: ColorToken.primaryContainer.of(context),
              borderRadius: BorderRadius.circular(8.px),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16.px,
                      color: ColorToken.primary.of(context),
                    ),
                    SizedBox(width: 8.px),
                    Expanded(
                      child: CLText.bodySmall(
                        '✨ 新建账号将自动生成用户名和头像',
                        colorToken: ColorToken.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.px),
                CLText.bodySmall(
                  '当前状态: ${_nameController.text.isNotEmpty ? "✅ 用户名: ${_nameController.text}" : "⏳ 正在生成用户名"}',
                  colorToken: ColorToken.primary,
                ),
                SizedBox(height: 4.px),
                CLText.bodySmall(
                  '头像状态: ${_avatarUrl != null && _avatarUrl!.startsWith('generated_avatar_') ? "✅ Emoji头像已生成" : "⏳ 正在生成头像"}',
                  colorToken: ColorToken.primary,
                ),
                if (_avatarUrl != null && _avatarUrl!.startsWith('generated_avatar_')) ...[
                  SizedBox(height: 4.px),
                  CLText.bodySmall(
                    '动物: ${_getAnimalStyleName()}',
                    colorToken: ColorToken.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          Localized.text('ox_login.profile_avatar_label'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 16.px),
        Center(
          child: Column(
            children: [
              Hero(
                tag: 'profile_avatar_hero',
                child: _buildAvatarWidget(),
              ),
              SizedBox(height: 12.px),
              CLButton.tonal(
                child: CLText.labelLarge(Localized.text('ox_login.change_avatar')),
                height: 36.px,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.px,
                  vertical: 8.px,
                ),
                onTap: _onAvatarTap,
              ),
              if (widget.isNewAccount) ...[
                SizedBox(height: 8.px),
                CLButton.tonal(
                  child: CLText.labelLarge('🔄 重新生成Emoji头像'),
                  height: 36.px,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.px,
                    vertical: 8.px,
                  ),
                  onTap: _onRegenerateAvatarTap,
                ),
                SizedBox(height: 8.px),
                CLButton.tonal(
                  child: CLText.labelLarge('🧪 测试Emoji头像生成'),
                  height: 36.px,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.px,
                    vertical: 8.px,
                  ),
                  onTap: _onTestAvatarGenerationTap,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          Localized.text('ox_login.profile_name_label'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        Row(
          children: [
            Expanded(
              child: CLTextField(
                controller: _nameController,
                placeholder: Localized.text('ox_login.profile_name_placeholder'),
                textInputAction: TextInputAction.next,
              ),
            ),
            if (widget.isNewAccount) ...[
              SizedBox(width: 12.px),
              CLButton.tonal(
                child: CLText.labelLarge(Localized.text('ox_login.regenerate_username')),
                height: 48.px,
                padding: EdgeInsets.symmetric(horizontal: 12.px),
                onTap: _onRegenerateUsernameTap,
              ),
            ],
          ],
        ),
        SizedBox(height: 8.px),
        CLText.bodySmall(
          Localized.text('ox_login.profile_name_hint'),
          colorToken: ColorToken.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CLText.titleMedium(
          Localized.text('ox_login.profile_bio_label'),
          colorToken: ColorToken.onSurface,
        ),
        SizedBox(height: 12.px),
        CLTextField(
          controller: _bioController,
          placeholder: Localized.text('ox_login.profile_bio_placeholder'),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: 8.px),
        CLText.bodySmall(
          Localized.text('ox_login.profile_bio_hint'),
          colorToken: ColorToken.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CLButton.filled(
          text: _isSaving 
              ? Localized.text('ox_common.loading')
              : Localized.text('ox_login.save_profile'),
          onTap: _hasChanges && !_isSaving ? _onSaveProfileTap : null,
          expanded: true,
          height: 48.px,
        ),
        SizedBox(height: 16.px),
        CLButton.tonal(
          text: Localized.text('ox_login.import_from_relay'),
          onTap: _onImportFromRelayTap,
          expanded: true,
          height: 48.px,
        ),
      ],
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

  void _onInputChanged() {
    final hasChanges = _nameController.text.isNotEmpty || _bioController.text.isNotEmpty;
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _loadCurrentProfile() async {
    try {
      // Get current user info from Account
      final currentUser = await _getCurrentUserInfo();
      if (currentUser != null) {
        setState(() {
          _nameController.text = currentUser.name ?? '';
          _bioController.text = currentUser.bio ?? '';
          _avatarUrl = currentUser.picture;
        });
      }
      
              // If this is a new account, generate default username and avatar
        if (widget.isNewAccount) {
          debugPrint('This is a new account, will generate default profile');
          await _generateDefaultProfile();
        } else {
          debugPrint('This is an existing account, profile already exists');
        }
    } catch (e) {
      debugPrint('Error loading current profile: $e');
    }
  }
  
  /// Generate default profile for new accounts
  Future<void> _generateDefaultProfile() async {
    try {
      debugPrint('Generating default profile for new account...');
      
      // Get current user's npub
      final currentUser = await _getCurrentUserInfo();
      if (currentUser == null) {
        debugPrint('Current user is null, cannot generate profile');
        return;
      }
      
      final npub = currentUser.pubKey;
      debugPrint('User npub: $npub');
      
      if (npub.isEmpty) {
        debugPrint('Npub is empty, cannot generate profile');
        return;
      }
      
      // Generate username if not set
      if (_nameController.text.isEmpty) {
        final username = UsernameGenerator.instance.generateUsername(npub);
        debugPrint('Generated username: $username');
        _nameController.text = username;
      }
      
      // Generate avatar if not set
      if (_avatarUrl == null || _avatarUrl!.isEmpty) {
        _avatarUrl = 'generated_avatar_$npub';
        debugPrint('Generated avatar URL: $_avatarUrl');
      }
      
      // Update UI state with all changes
      setState(() {
        _hasChanges = _nameController.text.isNotEmpty || _bioController.text.isNotEmpty;
      });
      
      debugPrint('Default profile generation completed');
    } catch (e) {
      debugPrint('Error generating default profile: $e');
    }
  }
  
  /// Build avatar widget with support for generated avatars
  Widget _buildAvatarWidget() {
    debugPrint('Building avatar widget with URL: $_avatarUrl');
    
    // Check if this is a generated avatar
    if (_avatarUrl != null && _avatarUrl!.startsWith('generated_avatar_')) {
      // Extract npub from the generated avatar URL
      final npub = _avatarUrl!.replaceFirst('generated_avatar_', '');
      debugPrint('Extracted npub for generated avatar: $npub');
      
      if (npub.isNotEmpty) {
        // Use the avatar generator to create a pixel art avatar
        debugPrint('Creating generated avatar for npub: $npub');
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
    
    // Use regular avatar for non-generated images
    debugPrint('Using regular avatar with URL: $_avatarUrl');
    return OXUserAvatar(
      imageUrl: _avatarUrl,
      size: 100.px,
      onTap: _onAvatarTap,
    );
  }
  
  /// Handle regenerate username button tap
  void _onRegenerateUsernameTap() async {
    try {
      final currentUser = await _getCurrentUserInfo();
      if (currentUser == null) return;
      
      final npub = currentUser.pubKey;
      if (npub.isEmpty) return;
      
      // Generate a new username
      final newUsername = UsernameGenerator.instance.generateUsername(npub);
      debugPrint('Regenerated username: $newUsername');
      
      // Update the controller and force UI update
      setState(() {
        _nameController.text = newUsername;
        _hasChanges = true;
      });
      
      // Show success message
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Generated new username: $newUsername'
        );
      }
    } catch (e) {
      debugPrint('Error regenerating username: $e');
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to generate new username'
        );
      }
    }
  }
  
  /// Handle regenerate avatar button tap
  void _onRegenerateAvatarTap() async {
    try {
      final currentUser = await _getCurrentUserInfo();
      if (currentUser == null) return;
      
      final npub = currentUser.pubKey;
      if (npub.isEmpty) return;
      
      // Generate a new avatar
      _avatarUrl = 'generated_avatar_$npub';
      debugPrint('Regenerated avatar URL: $_avatarUrl');
      
      // Force UI update
      setState(() {});
      
      // Show success message
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Generated new emoji avatar!'
        );
      }
    } catch (e) {
      debugPrint('Error regenerating avatar: $e');
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to generate new avatar'
        );
      }
    }
  }
  
  /// Handle test avatar generation button tap
  void _onTestAvatarGenerationTap() async {
    try {
      debugPrint('Testing avatar generation...');
      
      // Test with a sample npub
      const testNpub = 'npub1test123456789abcdefghijklmnopqrstuvwxyz';
      
      // Generate test avatar
      _avatarUrl = 'generated_avatar_$testNpub';
      
      // Force UI update
      setState(() {});
      
      // Show success message
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Test emoji avatar generated! Check console for debug info.'
        );
      }
      
      debugPrint('Test avatar generated with URL: $_avatarUrl');
    } catch (e) {
      debugPrint('Error testing avatar generation: $e');
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to generate test avatar: $e'
        );
      }
    }
  }
  
  /// Get animal style name for current avatar
  String _getAnimalStyleName() {
    if (_avatarUrl == null || !_avatarUrl!.startsWith('generated_avatar_')) {
      return 'Unknown';
    }
    
    try {
      final npub = _avatarUrl!.replaceFirst('generated_avatar_', '');
      return AvatarGenerator.instance.getAnimalStyleName(npub);
    } catch (e) {
      debugPrint('Error getting animal style name: $e');
      return 'Unknown';
    }
  }

  Future<void> _onAvatarTap() async {
    try {
      // Use the avatar display page with static open method
      await _openAvatarDisplayPage();
      
      // Refresh avatar after potential changes
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error opening avatar display: $e');
    }
  }

  Future<void> _openAvatarDisplayPage() async {
    try {
      // Try to use the existing avatar display page
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
    } catch (e) {
      // Fallback: show a simple dialog for avatar URL input
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
            onTap: () => Navigator.of(context).pop(),
          ),
          CLButton.filled(
            text: Localized.text('ox_common.confirm'),
            onTap: () => Navigator.of(context).pop(urlController.text.trim()),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _avatarUrl = result;
        _hasChanges = true;
      });
    }
  }

  Future<void> _onSaveProfileTap() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Show loading
      OXLoading.show();
      
      // Save profile information
      final success = await _saveProfile();
      
      OXLoading.dismiss();

      if (success) {
        // Successfully saved profile, return true to continue to home
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Failed to save profile
        setState(() {
          _isSaving = false;
        });
        
        if (mounted) {
          CommonToast.instance.show(
            context, 
            Localized.text('ox_login.profile_save_failed')
          );
        }
      }
    } catch (e) {
      OXLoading.dismiss();
      setState(() {
        _isSaving = false;
      });
      
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to save profile: ${e.toString()}'
        );
      }
    }
  }

  Future<void> _onImportFromRelayTap() async {
    try {
      // Show loading
      OXLoading.show();
      
      // Import profile from relay
      final success = await _importProfileFromRelay();
      
      OXLoading.dismiss();

      if (success) {
        // Successfully imported profile
        await _loadCurrentProfile();
        setState(() {
          _hasChanges = false;
        });
        
        if (mounted) {
          CommonToast.instance.show(
            context, 
            Localized.text('ox_login.profile_import_success')
          );
        }
      } else {
        // Failed to import profile
        if (mounted) {
          CommonToast.instance.show(
            context, 
            Localized.text('ox_login.profile_import_failed')
          );
        }
      }
    } catch (e) {
      OXLoading.dismiss();
      
      if (mounted) {
        CommonToast.instance.show(
          context, 
          'Failed to import profile: ${e.toString()}'
        );
      }
    }
  }

  Future<bool> _saveProfile() async {
    try {
      // Use Account to save profile information
      final currentUser = await _getCurrentUserInfo();
      if (currentUser == null) return false;

      // Update user information
      currentUser.name = _nameController.text.trim();
      currentUser.bio = _bioController.text.trim();
      if (_avatarUrl != null) {
        currentUser.picture = _avatarUrl;
      }

      // Save to database
      await _saveUserToDB(currentUser);
      
      return true;
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return false;
    }
  }

  Future<bool> _importProfileFromRelay() async {
    try {
      // Use Account to reload profile from relay
      final currentUser = await _getCurrentUserInfo();
      if (currentUser == null) return false;

      // Reload profile from relay
      await _reloadProfileFromRelay(currentUser.pubKey);
      
      return true;
    } catch (e) {
      debugPrint('Error importing profile: $e');
      return false;
    }
  }

  Future<dynamic> _getCurrentUserInfo() async {
    try {
      // First try to get from LoginManager
      final loginState = LoginManager.instance.currentState;
      if (loginState.account != null) {
        debugPrint('Got user from LoginManager: ${loginState.account!.pubkey}');
        
        // Create a mock user object with the information we need
        return _MockUser(
          pubKey: loginState.account!.pubkey,
          name: null, // Will be generated
          bio: null,  // Will be generated
          picture: null, // Will be generated
        );
      }
      
      // Fallback to dynamic import
      debugPrint('Trying dynamic import for user info...');
      final accountModule = await OXModuleService.invoke('chatcore', 'getCurrentUser', []);
      return accountModule;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<void> _saveUserToDB(dynamic user) async {
    try {
      // Use dynamic import to save user to database
      await OXModuleService.invoke('chatcore', 'saveUserToDB', [user]);
    } catch (e) {
      debugPrint('Error saving user to DB: $e');
      rethrow;
    }
  }

  Future<void> _reloadProfileFromRelay(String pubkey) async {
    try {
      // Use dynamic import to reload profile from relay
      await OXModuleService.invoke('chatcore', 'reloadProfileFromRelay', [pubkey]);
    } catch (e) {
      debugPrint('Error reloading profile from relay: $e');
      rethrow;
    }
  }

  void _onSkipTap() {
    // Return false to indicate user skipped profile setup
    Navigator.of(context).pop(false);
  }
}

/// Mock user class for profile generation
class _MockUser {
  final String pubKey;
  String? name;
  String? bio;
  String? picture;
  
  _MockUser({
    required this.pubKey,
    this.name,
    this.bio,
    this.picture,
  });
}
