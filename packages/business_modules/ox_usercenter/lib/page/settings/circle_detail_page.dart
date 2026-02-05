import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/login/login_models.dart';
import 'package:ox_common/login/circle_service.dart';
import 'package:ox_common/login/circle_repository.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/common_loading.dart' as Loading;
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/utils/file_server_helper.dart';
import 'package:ox_common/repository/file_server_repository.dart';
import 'package:ox_common/log_util.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:ox_login/ox_login.dart';

import 'file_server_page.dart';
import 'profile_settings_page.dart';
import 'qr_code_display_page.dart';
import '../../utils/invite_link_manager.dart';

enum _MenuAction { edit, delete }
enum _PlanAction { changePlan, cancelSubscription, renewPlan }
enum _StorageAction { clearAllStorage }

class CircleDetailPage extends StatefulWidget {
  const CircleDetailPage({
    super.key,
    required this.circle,
    this.previousPageTitle,
    this.description = '',
  });

  final Circle circle;

  final String? previousPageTitle;

  final String description;

  String get title => Localized.text('ox_usercenter.circle_settings');

  @override
  State<CircleDetailPage> createState() => _CircleDetailPageState();
}

class _CircleDetailPageState extends State<CircleDetailPage> {
  late String _circleName;
  bool _isOwner = false;
  late ValueNotifier<String> _renewDate$;
  late ValueNotifier<String?> _subscriptionStatus$;
  int _currentMembers = 1;
  int _maxMembers = 6;
  late ValueNotifier<String> _fileServerName$;
  List<UserDBISAR> _members = [];
  void Function()? _stateListener;

  @override
  void initState() {
    super.initState();
    _circleName = widget.circle.name;
    _renewDate$ = ValueNotifier<String>('Dec 31, 2025');
    _subscriptionStatus$ = ValueNotifier<String?>(null);
    _fileServerName$ = ValueNotifier<String>('');
    _checkIfOwner();
    _stateListener = () {
      final state = LoginManager.instance.currentState;
      if (state.currentCircle?.id != widget.circle.id ||
          state.currentCircle?.tenantInfo == null) return;
      if (!mounted) return;
      _updateUIWithTenantInfo(state.currentCircle!.tenantInfo!.toJson());
    };
    LoginManager.instance.state$.addListener(_stateListener!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadLocalData();
      _loadSubscriptionInfo();
      _loadFileServerInfo();
    });
  }

  @override
  void dispose() {
    if (_stateListener != null) {
      LoginManager.instance.state$.removeListener(_stateListener!);
    }
    _renewDate$.dispose();
    _subscriptionStatus$.dispose();
    _fileServerName$.dispose();
    super.dispose();
  }

  void _checkIfOwner() {
    final currentPubkey = LoginManager.instance.currentPubkey;
    _isOwner = widget.circle.ownerPubkey == currentPubkey;
  }

  /// Check if this circle is a paid relay (based on relayUrl matching privateRelayApiBaseUrl)
  bool _isPaidRelay() {
    return CircleApi.isPaidRelay(widget.circle.relayUrl);
  }

  /// Load local data first (for paid relays, UI comes from _loadSubscriptionInfo only)
  Future<void> _loadLocalData() async {
    _circleName = widget.circle.name;
  }

  /// Load cached tenant info from CircleDBISAR
  Future<Map<String, dynamic>?> _loadCachedTenantInfo() async {
    try {
      return await Account.sharedInstance.loadTenantInfoFromCircleDB(
        widget.circle.id,
      );
    } catch (e) {
      LogUtil.w(() => 'Failed to load cached tenant info: $e');
      return null;
    }
  }

  /// Update UI with tenant info
  Future<void> _updateUIWithTenantInfo(Map<String, dynamic> tenantInfo) async {
    // Check if current user is tenant admin
    final currentPubkey = LoginManager.instance.currentPubkey;
    final tenantAdminPubkey = tenantInfo['tenant_admin_pubkey'] as String?;
    if (tenantAdminPubkey != null && tenantAdminPubkey.isNotEmpty) {
      _isOwner = tenantAdminPubkey.toLowerCase() == currentPubkey.toLowerCase();
    } else {
      // Fallback to circle pubkey check
      _isOwner = widget.circle.ownerPubkey == currentPubkey;
    }

    // Extract member count and limits
    final currentMembers = tenantInfo['current_members'] as int? ?? 0;
    final maxMembers = tenantInfo['max_members'] as int? ?? 100;

    // Extract and convert members list (batch getUserInfos to avoid N sequential DB reads)
    final membersList = <UserDBISAR>[];
    final membersData = tenantInfo['members'] as List<dynamic>?;
    if (membersData != null && membersData.isNotEmpty) {
      final pubkeys = <String>[];
      final displayNames = <String, String>{};
      for (final memberData in membersData) {
        final memberMap = memberData as Map<String, dynamic>;
        final pubkey = memberMap['pubkey'] as String?;
        if (pubkey != null && pubkey.isNotEmpty) {
          pubkeys.add(pubkey);
          final displayName = memberMap['display_name'] as String?;
          if (displayName != null && displayName.isNotEmpty) {
            displayNames[pubkey] = displayName;
          }
        }
      }
      final userMap = await Account.sharedInstance.getUserInfos(pubkeys);
      for (final pubkey in pubkeys) {
        final user = userMap[pubkey];
        if (user != null) {
          final displayName = displayNames[pubkey];
          if (displayName != null && displayName.isNotEmpty) {
            user.name = displayName;
          }
          membersList.add(user);
        }
      }
    }

    // Extract expires_at and format renew date
    String renewDateText = 'Dec 31, 2025'; // Default
    final expiresAt = tenantInfo['expires_at'] as int?;
    if (expiresAt != null && expiresAt > 0) {
      try {
        // expires_at is in seconds, convert to milliseconds
        final date = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        renewDateText = DateFormat('MMM d, yyyy').format(date);
      } catch (e) {
        LogUtil.w(() => 'Failed to format expires_at: $e');
      }
    }

    // Extract subscription status
    String? subscriptionStatus = tenantInfo['subscription_status'] as String?;
    // If subscription_status is not available, determine status from expires_at
    if (subscriptionStatus == null || subscriptionStatus.isEmpty) {
      if (expiresAt != null && expiresAt > 0) {
        try {
          final expiresDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
          final now = DateTime.now();
          subscriptionStatus = expiresDate.isBefore(now) ? 'expired' : 'active';
        } catch (e) {
          LogUtil.w(() => 'Failed to determine subscription status from expires_at: $e');
        }
      }
    }

    // Extract tenant name if available
    final tenantName = tenantInfo['name'] as String?;
    if (tenantName != null && tenantName.isNotEmpty && tenantName != _circleName) {
      // Optionally update circle name if different
      // _circleName = tenantName;
    }

    if (mounted) {
      setState(() {
        _currentMembers = currentMembers;
        _maxMembers = maxMembers;
        _members = membersList;
        _renewDate$.value = renewDateText;
        _subscriptionStatus$.value = subscriptionStatus;
      });
    }
  }

  /// Save tenant info to cache (CircleDBISAR)
  /// This method is called when we successfully get tenant info, which means it's a paid circle
  Future<void> _saveTenantInfoToCache(Map<String, dynamic> tenantInfo) async {
    try {
      await Account.sharedInstance.saveTenantInfoToCircleDB(
        circleId: widget.circle.id,
        tenantInfo: tenantInfo,
      );
    } catch (e) {
      LogUtil.w(() => 'Failed to save tenant info to cache: $e');
    }
  }

  Future<void> _loadSubscriptionInfo() async {
    // Only load subscription info for paid relays
    if (!_isPaidRelay()) {
      return;
    }

    // Try to load cached data from local first and display immediately
    final cachedData = await _loadCachedTenantInfo();
    if (cachedData != null) {
      _updateUIWithTenantInfo(cachedData);
    }

    // Update category if it's not already paid
    if (widget.circle.category != CircleCategory.paid) {
      await _updateCircleCategory(CircleCategory.paid);
    }

    // Then request server update (request regardless of whether cached data exists)
    try {
      final tenantInfo = await CircleMemberService.sharedInstance.getTenantInfoForRelay(
        widget.circle.relayUrl,
        circleId: widget.circle.id,
      );
      
      // Update UI
      await _updateUIWithTenantInfo(tenantInfo.toJson());

      // Save to local cache
      await _saveTenantInfoToCache(tenantInfo.toJson());

      // Sync to LoginManager state so state$ has latest tenantInfo (reactive UI elsewhere)
      if (LoginManager.instance.currentCircle?.id == widget.circle.id) {
        LoginManager.instance.updateCircleTenantInfo(tenantInfo);
      }

      // If server returns tenant_name different from local, update circle name
      final tenantName = tenantInfo.name;
      if (tenantName.isNotEmpty && tenantName != _circleName) {
        if (mounted) {
          setState(() {
            _circleName = tenantName;
          });
        }
      }
    } catch (e) {
      // Request failed, keep displaying local data (if any)
      LogUtil.w(() => 'Failed to load subscription info: $e');
      // If no cached data was loaded and request failed, try fallback
      if (_members.isEmpty && cachedData == null) {
        _loadCurrentUserFallback();
      }
    }
  }

  /// Update circle category in account-level database
  Future<void> _updateCircleCategory(CircleCategory category) async {
    try {
      final loginManager = LoginManager.instance;
      final account = loginManager.currentState.account;
      if (account == null) return;

      // Find the circle in account circles
      final circleIndex = account.circles.indexWhere((c) => c.id == widget.circle.id);
      if (circleIndex == -1) return;

      // Update category
      account.circles[circleIndex].category = category;

      // Save to account database
      final accountDb = account.db;
      final success = await CircleRepository.update(accountDb, account.circles[circleIndex]);
      if (success) {
        LogUtil.v(() => 'Updated circle category to $category for circle: ${widget.circle.id}');
        // Update LoginManager state to reflect the change
        loginManager.updateStateAccount(account);
      }
    } catch (e) {
      LogUtil.w(() => 'Failed to update circle category: $e');
    }
  }
  
  Future<void> _loadCurrentUserFallback() async {
    try {
      final currentPubkey = LoginManager.instance.currentPubkey;
      if (currentPubkey.isNotEmpty) {
        final currentUser = await Account.sharedInstance.getUserInfo(currentPubkey);
        if (currentUser != null && _members.isEmpty) {
          setState(() {
            _members = [currentUser];
            _currentMembers = 1;
          });
        }
      }
    } catch (e) {
      LogUtil.e(() => 'Failed to load current user: $e');
    }
  }

  Future<void> _loadFileServerInfo() async {
    final selectedUrl = widget.circle.selectedFileServerUrl;
    String displayName = '';
    
    if (FileServerHelper.isDefaultFileServerGroupSelected(selectedUrl)) {
      displayName = Localized.text('ox_usercenter.default_file_server_group');
    } else {
      try {
        final repo = FileServerRepository(DBISAR.sharedInstance.isar);
        final servers = repo.fetch();
        final matched = servers.firstWhere((e) => e.url == selectedUrl);
        displayName = matched.name.isNotEmpty ? matched.name : matched.url;
      } catch (e) {
        displayName = selectedUrl;
      }
    }
    
    _fileServerName$.value = displayName;
  }


  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        previousPageTitle: widget.previousPageTitle,
        title: widget.title,
        actions: [_buildMenuButton(context)],
        backgroundColor: ColorToken.primaryContainer.of(context),
      ),
      body: CLSectionListView(
        padding: EdgeInsets.only(bottom: 40.px),
        items: [
          SectionListViewItem(
            headerWidget: _buildHeader(context),
            data: [],
          ),
          ..._buildMainItems(context),
        ],
      ),
      isSectionListPage: true,
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return CLButton.icon(
      icon: CupertinoIcons.ellipsis,
      onTap: () async {
        final action = await CLPicker.show<_MenuAction>(
          context: context,
          items: [
            // CLPickerItem(label: Localized.text('ox_usercenter.edit_profile'), value: _MenuAction.edit),
            CLPickerItem(
              label: Localized.text('ox_usercenter.delete_circle'),
              value: _MenuAction.delete,
              isDestructive: true,
            ),
          ],
        );
        if (action != null) {
          _handleMenuAction(context, action);
        }
      },
    );
  }

  void _handleMenuAction(BuildContext context, _MenuAction action) {
    switch (action) {
      case _MenuAction.edit:
        OXNavigator.pushPage(context, (_) =>
            ProfileSettingsPage(previousPageTitle: widget.title));
        break;
      case _MenuAction.delete:
        _confirmDelete(context);
        break;
    }
  }

  void _confirmDelete(BuildContext context) async {
    final bool? confirmed = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.delete_circle_confirm_title'),
      content: Localized.text('ox_usercenter.delete_circle_confirm_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.delete_circle'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (confirmed == true) {
      try {
        await LoginManager.instance.deleteCircle(widget.circle.id);
      } catch (e) {
        CommonToast.instance.show(context, e.toString());
      }
      OXNavigator.popToRoot(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: PlatformStyle.isUseMaterial
          ? ColorToken.primaryContainer.of(context)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.px),
      
          CircleAvatar(
            radius: 40.px,
            backgroundColor: ColorToken.onPrimary.of(context),
            child: CLText.titleLarge(
              _circleName.isNotEmpty ? _circleName[0].toUpperCase() : '?',
            ),
          ),
      
          SizedBox(height: 12.px),

          GestureDetector(
            onTap: () => _editCircleName(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: CLText.titleLarge(
                    _circleName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.px),
                Icon(
                  CupertinoIcons.create_solid,
                  size: 18.px,
                  color: ColorToken.onSurfaceVariant.of(context),
                ),
              ],
            ),
          ),
      
          SizedBox(height: 12.px),
      
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: PlatformStyle.isUseMaterial
          //         ? 24.px
          //         : 4.px,
          //     vertical: 12.px,
          //   ),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       CLText.bodyLarge(Localized.text('ox_chat.description')),
          //       CLText.bodyMedium(description),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> _editCircleName(BuildContext context) async {
    await CLDialog.showInputDialog(
      context: context,
      title: Localized.text('ox_usercenter.edit_circle_name'),
      inputLabel: Localized.text('ox_usercenter.circle_name'),
      initialValue: _circleName,
      onConfirm: (newName) async {
        if (newName.trim().isEmpty) {
          CommonToast.instance.show(context, Localized.text('ox_common.input_cannot_be_empty'));
          return false;
        }
        
        if (newName.trim() == _circleName) {
          return true; // No change needed
        }

        try {
          Loading.OXLoading.show();
          
          final trimmedName = newName.trim();
          
          // If this is a paid relay, update tenant name on server first
          if (_isPaidRelay()) {
            try {
              await CircleMemberService.sharedInstance.updateTenant(
                name: trimmedName,
              );
              // After successful server update, reload tenant info to sync local cache
              // This will update CircleDBISAR and UI
              await _loadSubscriptionInfo();
            } catch (e) {
              Loading.OXLoading.dismiss();
              LogUtil.e(() => 'Failed to update tenant name on server: $e');
              final errorMessage = e.toString().replaceFirst('Exception: ', '');
              CommonToast.instance.show(
                context,
                errorMessage.isNotEmpty 
                    ? errorMessage 
                    : Localized.text('ox_common.operation_failed'),
              );
              return false;
            }
          }
          
          // Update account-level Circle object in local database
          final updatedCircle = await CircleService.updateCircleName(
            widget.circle.id,
            trimmedName,
          );

          if (updatedCircle == null) {
            Loading.OXLoading.dismiss();
            CommonToast.instance.show(context, Localized.text('ox_common.operation_failed'));
            return false;
          }

          Loading.OXLoading.dismiss();
          
          // Update UI state (for paid relays, _loadSubscriptionInfo already updated it, but we update again to ensure consistency)
          setState(() {
            _circleName = trimmedName;
          });

          return true;
        } catch (e) {
          Loading.OXLoading.dismiss();
          // Show detailed error message
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          CommonToast.instance.show(context, errorMessage.isNotEmpty ? errorMessage : Localized.text('ox_common.operation_failed'));
          return false;
        }
      },
    );
  }

  List<SectionListViewItem> _buildMainItems(BuildContext context) {
    final items = <SectionListViewItem>[
      // Relay Server
      SectionListViewItem(
        footer: Localized.text('ox_usercenter.relay_server_description'),
        data: [
          LabelItemModel(
            icon: ListViewIcon.data(CupertinoIcons.antenna_radiowaves_left_right),
            title: Localized.text('ox_usercenter.relay_server'),
            subtitle: widget.circle.relayUrl,
            onTap: null,
          ),
          LabelItemModel(
            icon: ListViewIcon.data(CupertinoIcons.settings),
            title: Localized.text('ox_usercenter.file_server_setting'),
            // subtitle: _fileServerName$.value,
            onTap: () {
              OXNavigator.pushPage(context, (_) => FileServerPage(
                previousPageTitle: widget.title,
                readOnlyForPaidCircle: _isPaidRelay(),
              )).then((_) {
                // Reload file server info when returning from file server page
                _loadFileServerInfo();
              });
            },
          ),
        ],
      ),
    ];

    // Add subscription and members sections if user is owner
    if (_isOwner) {
      items.addAll([
        _buildSubscriptionSection(context),
        _buildMembersSection(context),
      ]);
    }

    return items;
  }

  SectionListViewItem _buildSubscriptionSection(BuildContext context) {
    return SectionListViewItem(
      header: Localized.text('ox_usercenter.subscription_and_usage'),
      data: [
        // Plan
        CustomItemModel(
          icon: ListViewIcon.data(Icons.workspace_premium),
          title: Localized.text('ox_usercenter.plan'),
          subtitleWidget: ValueListenableBuilder<String?>(
            valueListenable: _subscriptionStatus$,
            builder: (context, status, _) {
              return ValueListenableBuilder<String>(
                valueListenable: _renewDate$,
                builder: (context, renewDate, _) {
                  if (status == 'active') {
                    return Row(
                      children: [
                        Expanded(
                          child: CLText.bodySmall(
                            Localized.text('ox_usercenter.renews_on').replaceAll('{date}', renewDate),
                            colorToken: ColorToken.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  } else if (status == 'expired') {
                    return Row(
                      children: [
                        Expanded(
                          child: CLText.bodySmall(
                            Localized.text('ox_usercenter.subscription_expired_on').replaceAll('{date}', renewDate),
                            colorToken: ColorToken.error,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Default: show renew date only
                    return CLText.bodySmall(
                      Localized.text('ox_usercenter.renews_on').replaceAll('{date}', renewDate),
                      colorToken: ColorToken.onSurfaceVariant,
                    );
                  }
                },
              );
            },
          ),
          onTap: () {
            _showPlanOptions(context);
          },
        ),
        // Storage
        LabelItemModel(
          icon: ListViewIcon.data(Icons.storage),
          title: Localized.text('ox_usercenter.storage'),
          // value$: _storageUsed$,
          onTap: () {
            _showStorageOptions(context);
          },
        ),
      ],
    );
  }

  SectionListViewItem _buildMembersSection(BuildContext context) {
    final currentPubkey = LoginManager.instance.currentPubkey;
    final memberItems = <ListViewItem>[];

    // Add owner (current user)
    UserDBISAR? ownerUser;
    try {
      ownerUser = _members.firstWhere(
        (user) => user.pubKey == currentPubkey,
      );
    } catch (e) {
      // Owner not found in members list, use first member if available
      if (_members.isNotEmpty) {
        ownerUser = _members.first;
      }
    }
    
    if (ownerUser != null) {
      memberItems.add(
        LabelItemModel(
          icon: ListViewIcon.data(Icons.person),
          title: Localized.text('ox_usercenter.you_owner'),
          subtitle: Localized.text('ox_usercenter.owner'),
          onTap: null,
        ),
      );
    }

    // Add other members
    for (final member in _members) {
      if (member.pubKey != currentPubkey) {
        final memberName = member.name ?? '';
        final displayName = memberName.isNotEmpty 
            ? memberName 
            : (member.pubKey.length >= 8 
                ? member.pubKey.substring(0, 8) 
                : member.pubKey);
        memberItems.add(
          CustomItemModel(
            icon: ListViewIcon.data(Icons.person),
            title: displayName,
            subtitle: Localized.text('ox_usercenter.member'),
            trailing: CLButton.text(
              text: Localized.text('ox_usercenter.remove'),
              color: ColorToken.error.of(context),
              onTap: () => _removeMember(member),
            ),
            onTap: () {
              // Navigate to user profile page
              OXModuleService.pushPage(
                context,
                'ox_chat',
                'ContactUserInfoPage',
                {
                  'pubkey': member.pubKey,
                },
              );
            },
          ),
        );
      }
    }

    // Add "Add Member" option only if not at max capacity
    if (_currentMembers < _maxMembers) {
      memberItems.add(
        LabelItemModel(
          icon: ListViewIcon.data(Icons.person_add),
          title: Localized.text('ox_usercenter.add_member'),
          onTap: _addMember,
        ),
      );
    }

    return SectionListViewItem(
      header: '${Localized.text('ox_usercenter.members')}(${_currentMembers}/${_maxMembers})',
      data: memberItems,
    );
  }

  Future<void> _removeMember(UserDBISAR member) async {
    final memberName = member.name ?? '';
    final displayName = memberName.isNotEmpty 
        ? memberName 
        : (member.pubKey.length >= 8 
            ? member.pubKey.substring(0, 8) 
            : member.pubKey);
    
    final confirmed = await CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.remove_member_title'),
      content: Localized.text('ox_usercenter.remove_member_content').replaceAll('{name}', displayName),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.remove'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    );

    if (confirmed == true) {
      Loading.OXLoading.show();
      try {
        await CircleMemberService.sharedInstance.removeMember(
          memberPubkey: member.pubKey,
        );
        
        if (mounted) {
          CommonToast.instance.show(context, Localized.text('ox_common.operation_success'));
          await _loadSubscriptionInfo();
        }
      } catch (e) {
        if (mounted) {
          CommonToast.instance.show(context, e.toString());
        }
      } finally {
        Loading.OXLoading.dismiss();
      }
    }
  }

  Future<void> _addMember() async {
    // Check if member limit is reached
    if (_currentMembers >= _maxMembers) {
      CommonToast.instance.show(
        context,
        Localized.text('ox_usercenter.member_limit_reached'),
      );
      return;
    }

    // Navigate to QR code display page for circle invite
    if (mounted) {
      await OXNavigator.pushPage(
        context,
        (context) => QRCodeDisplayPage(
          inviteType: InviteType.circle,
          circle: widget.circle,
        ),
      );
    }
  }


  void _showPlanOptions(BuildContext context) async {
    final status = _subscriptionStatus$.value;
    final items = <CLPickerItem<_PlanAction>>[];

    // Build options based on subscription status
    if (status == 'active') {
      // Active subscription: show change plan and cancel subscription
      items.addAll([
        CLPickerItem(
          label: Localized.text('ox_usercenter.change_plan'),
          value: _PlanAction.changePlan,
        ),
        CLPickerItem(
          label: Localized.text('ox_usercenter.cancel_subscription'),
          value: _PlanAction.cancelSubscription,
          isDestructive: true,
        ),
      ]);
    } else if (status == 'expired') {
      // Expired subscription: show renew plan
      items.addAll([
        CLPickerItem(
          label: Localized.text('ox_usercenter.change_plan'),
          value: _PlanAction.changePlan,
        ),
        CLPickerItem(
          label: Localized.text('ox_usercenter.renew'),
          value: _PlanAction.renewPlan,
        ),
      ]);
    } else {
      // Default: show all options
      items.addAll([
        CLPickerItem(
          label: Localized.text('ox_usercenter.change_plan'),
          value: _PlanAction.changePlan,
        ),
        CLPickerItem(
          label: Localized.text('ox_usercenter.renew'),
          value: _PlanAction.renewPlan,
        ),
        CLPickerItem(
          label: Localized.text('ox_usercenter.cancel_subscription'),
          value: _PlanAction.cancelSubscription,
          isDestructive: true,
        ),
      ]);
    }

    final action = await CLPicker.show<_PlanAction>(
      context: context,
      items: items,
    );

    if (action == null) return;

    switch (action) {
      case _PlanAction.changePlan:
        _handleChangePlan(context);
        break;
      case _PlanAction.cancelSubscription:
        _handleCancelSubscription(context);
        break;
      case _PlanAction.renewPlan:
        _handleRenewPlan(context);
        break;
    }
  }

  void _showStorageOptions(BuildContext context) async {
    final action = await CLPicker.show<_StorageAction>(
      context: context,
      items: [
        CLPickerItem(
          label: Localized.text('ox_usercenter.clear_all_storage'),
          value: _StorageAction.clearAllStorage,
          isDestructive: true,
        ),
      ],
    );

    if (action == null) return;

    switch (action) {
      case _StorageAction.clearAllStorage:
        _showClearStorageDialog(context);
        break;
    }
  }

  void _handleChangePlan(BuildContext context) {
    OXNavigator.pushPage(
      context,
      (context) => PrivateCloudOverviewPage(groupId: widget.circle.groupId,),
      type: OXPushPageType.present,
      fullscreenDialog: true,
    );
  }

  Future<void> _handleCancelSubscription(BuildContext context) async {
    await _openSubscriptionManagement(context);
  }

  Future<void> _handleRenewPlan(BuildContext context) async {
    await _openSubscriptionManagement(context);
  }

  Future<void> _openSubscriptionManagement(BuildContext context) async {
    String url;
    if (Platform.isIOS) {
      url = 'https://apps.apple.com/account/subscriptions';
    } else if (Platform.isAndroid) {
      url = 'https://play.google.com/store/account/subscriptions?package=com.oxchat.lite';
    } else {
      CommonToast.instance.show(
        context,
        Localized.text('ox_common.unsupported_platform'),
      );
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      CommonToast.instance.show(
        context,
        Localized.text('ox_common.failed_to_open_url'),
      );
    }
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.cancel_subscription_title'),
      content: Localized.text('ox_usercenter.cancel_subscription_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.cancel_subscription'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    ).then((confirmed) {
      if (confirmed == true) {
        // TODO: Implement cancel subscription logic
        CommonToast.instance.show(context, Localized.text('ox_common.operation_success'));
      }
    });
  }

  void _showClearStorageDialog(BuildContext context) {
    CLAlertDialog.show<bool>(
      context: context,
      title: Localized.text('ox_usercenter.clear_all_storage_title'),
      content: Localized.text('ox_usercenter.clear_all_storage_content'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_usercenter.clear_all_storage'),
          value: true,
          isDestructiveAction: true,
        ),
      ],
    ).then((confirmed) async {
      if (confirmed == true) {
        await _handleClearAllStorage(context);
      }
    });
  }

  /// Handle clear all storage operation
  Future<void> _handleClearAllStorage(BuildContext context) async {
    // Only allow for paid relays
    if (!_isPaidRelay()) {
      CommonToast.instance.show(context, Localized.text('ox_common.operation_failed'));
      return;
    }

    // Get account credentials
    final pubkey = LoginManager.instance.currentPubkey;
    final privkey = Account.sharedInstance.currentPrivkey;
    
    if (pubkey.isEmpty || privkey.isEmpty) {
      CommonToast.instance.show(context, Localized.text('ox_common.operation_failed'));
      return;
    }

    // Get tenantId from CircleDBISAR, fallback to circle.id if not available
    String tenantId = widget.circle.id;
    try {
      final circleDB = await Account.sharedInstance.getCircleById(widget.circle.id);
      if (circleDB?.tenantId != null && circleDB!.tenantId!.isNotEmpty) {
        tenantId = circleDB.tenantId!;
      }
    } catch (e) {
      LogUtil.w(() => 'Failed to get tenantId from CircleDBISAR: $e');
      // Use circle.id as fallback
    }

    // Show loading
    Loading.OXLoading.show();

    try {
      // Call API to delete tenant files
      final result = await CircleApi.deleteTenantFiles(
        pubkey: pubkey,
        privkey: privkey,
        tenantId: tenantId,
      );

      // Hide loading
      Loading.OXLoading.dismiss();

      // Show success message
      CommonToast.instance.show(
        context,
        Localized.text('ox_common.operation_success'),
      );

      LogUtil.v(() => 'Successfully deleted ${result.deletedCount}/${result.totalCount} files for tenant $tenantId');
    } catch (e) {
      // Hide loading
      Loading.OXLoading.dismiss();

      // Show error message
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      CommonToast.instance.show(context, errorMessage);

      LogUtil.e(() => 'Failed to delete tenant files: $e');
    }
  }
}