import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/user_search_manager.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';

/// Lightweight data model used by [CLMultiUserSelector].
class SelectableUser {
  SelectableUser({
    required this.user$,
    bool defaultSelected = false,
  }) : selected$ = ValueNotifier<bool>(defaultSelected);

  String get id => user$.value.pubKey;
  final ValueNotifier<UserDBISAR> user$;
  final ValueNotifier<bool> selected$;
}

/// A reusable widget that lets user pick multiple contacts from a list.
///
/// Features:
/// * Alphabetical grouping similar to iOS contact picker
/// * Search / filter capability
/// * Animated chips for currently-selected users
/// * Platform adaptive UI (Material & Cupertino)
class CLMultiUserSelector extends StatefulWidget {
  const CLMultiUserSelector({
    super.key,
    this.userPubkeys,
    this.initialSelectedIds = const [],
    required this.onChanged,
    this.title,
    this.maxSelectable,
    this.actions,
  });

  final List<String>? userPubkeys;
  final List<String> initialSelectedIds;
  final void Function(List<SelectableUser> selected) onChanged;
  final String? title;
  final int? maxSelectable;
  final List<Widget>? actions;

  @override
  State<CLMultiUserSelector> createState() => _CLMultiUserSelectorState();
}

class _CLMultiUserSelectorState extends State<CLMultiUserSelector> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();

  List<SelectableUser> _allUsers = [];
  Map<String, List<SelectableUser>> _groupedUsers = {};

  final List<SelectableUser> _selected = [];
  late final UserSearchManager<SelectableUser> _searchManager;

  // For tracking scroll-based background color changes
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _searchManager = UserSearchManager<SelectableUser>.custom(
      convertToTargetModel: (user$) => _getOrCreateSelectableUser(user$),
      getUserId: (user) => user.id,
      debounceDelay: const Duration(milliseconds: 300),
      minSearchLength: 1,
      maxResults: 50,
    );
    
    // Add search result listener only once
    _searchManager.resultNotifier.addListener(_onSearchResultChanged);
    
    prepareData();
  }

  void prepareData() async {
    if (widget.userPubkeys != null) {
      await _searchManager.initialize(
        externalUsers: widget.userPubkeys?.map(
          (pubkey) => Account.sharedInstance.getUserNotifier(pubkey)
        ).toList(),
      );
    } else {
      await _searchManager.initialize();
    }

    _allUsers = _searchManager.allUsers;
    _groupUsers();

    // Set initial selected users
    for (final id in widget.initialSelectedIds) {
      final user = _allUsers.where((u) => u.id == id).firstOrNull;
      if (user != null) _selected.add(user);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  /// Get or create SelectableUser, maintaining selection state
  SelectableUser _getOrCreateSelectableUser(ValueNotifier<UserDBISAR> user$) {
    // First check if we already have this user in _allUsers
    return _allUsers.firstWhere(
      (user) => user.id == user$.value.pubKey,
      orElse: () => SelectableUser(user$: user$)
    );
  }

  @override
  void didUpdateWidget(covariant CLMultiUserSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userPubkeys != oldWidget.userPubkeys) {
      prepareData();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollOffset.dispose();
    _searchManager.resultNotifier.removeListener(_onSearchResultChanged);
    _searchManager.dispose();
    
    super.dispose();
  }

  void _groupUsers() {
    _groupedUsers = {};
    for (final entry in _allUsers) {
      String first = '#';
      final displayName = _getUserDisplayName(entry.user$.value);
      if (displayName.isNotEmpty) {
        final ch = displayName[0].toUpperCase();
        if (RegExp(r'[A-Z]').hasMatch(ch)) {
          first = ch;
        }
      }
      _groupedUsers.putIfAbsent(first, () => []).add(entry);
    }
    _groupedUsers.forEach((key, list) {
      list.sort((a, b) {
        final displayNameA = _getUserDisplayName(a.user$.value);
        final displayNameB = _getUserDisplayName(b.user$.value);
        return displayNameA.compareTo(displayNameB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? Localized.text('ox_common.select');
    return CLScaffold(
      appBar: CLAppBar(
        title: title,
        actions: widget.actions ?? [],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 80.px),
          child: _buildSearchBar(context),
        ),
      ),
      isSectionListPage: true,
      body: LoseFocusWrap(child: _buildBody()),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return CLSearch(
      controller: _searchCtrl,
      prefixIcon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _selected.isEmpty ? CLSearchIcon()
            : ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200.px),
          child: _buildSelectedUsersList(),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 16.px,
        horizontal: CLLayout.horizontalPadding,
      ),
      placeholder: Localized.text('ox_common.search_npub_or_username'),
      onChanged: (value) => _onSearchChanged(),
    );
  }

  Widget _buildSelectedUsersList() {
    return Container(
      key: const ValueKey('selected_users'),
      child: AnimatedList(
        key: _animatedListKey,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        reverse: true, // Reverse display, new items appear in visible area
        initialItemCount: _selected.length,
        itemBuilder: (context, index, animation) {
          // Adjust index due to reverse layout
          final reversedIndex = _selected.length - 1 - index;
          if (reversedIndex >= 0 && reversedIndex < _selected.length) {
            final user = _selected[reversedIndex];
            return _buildAnimatedChip(user, animation);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAnimatedChip(SelectableUser entry, Animation<double> animation) {
    final sizeAnimation = animation.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );
    
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
      ),
      child: AnimatedBuilder(
        animation: sizeAnimation,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            widthFactor: sizeAnimation.value,
            heightFactor: sizeAnimation.value,
            child: child,
          );
        },
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.5, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 8.px),
            child: GestureDetector(
              onTap: () => _toggleSelect(entry),
              child: Container(
                alignment: Alignment.center,
                child: ValueListenableBuilder(
                  valueListenable: entry.user$,
                  builder: (context, user, _) {
                    return OXUserAvatar(
                      user: null,
                      imageUrl: user.picture,
                      size: 36.px,
                    );
                  }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final listItems = _searchCtrl.text.isEmpty ? _buildGroupedItems() : _buildSearchItems();
    return Column(
      children: [
        Expanded(child: CLSectionListView(items: listItems)),
      ],
    );
  }

  List<SectionListViewItem> _buildGroupedItems() {
    final keys = _groupedUsers.keys.toList()
      ..sort((a, b) {
        if (a == '#') return 1;
        if (b == '#') return -1;
        return a.compareTo(b);
      });

    return keys
        .map((k) => SectionListViewItem(
              header: k,
              data: _groupedUsers[k]!.map(_buildUserItem).toList(),
            ))
        .toList();
  }

  List<SectionListViewItem> _buildSearchItems() {
    final searchResult = _searchManager.resultNotifier.value;
    if (searchResult.results.isEmpty) {
      return [];
    }
    return [SectionListViewItem(data: searchResult.results.map(_buildUserItem).toList())];
  }

  ListViewItem _buildUserItem(SelectableUser entry) {
    return CustomItemModel(
      leading: ValueListenableBuilder(
        valueListenable: entry.user$,
        builder: (context, user, _) {
          return OXUserAvatar(
            user: null,
            imageUrl: user.picture,
            size: 40.px,
          );
        }
      ),
      isCupertinoAutoTrailing: false,
      titleWidget: ValueListenableBuilder(
        valueListenable: entry.user$,
        builder: (context, user, _) {
          return Row(
            children: [
              Expanded(
                child: CLText.bodyLarge(_getUserDisplayName(user)),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: entry.selected$,
                builder: (context, isSelected, child) {
                  return CLIcon(
                    icon: isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 24.px,
                    color: isSelected
                        ? ColorToken.primary.of(context)
                        : ColorToken.onSurfaceVariant.of(context),
                  );
                },
              ),
            ],
          );
        }
      ),
      onTap: () {
        _toggleSelect(entry);
      },
    );
  }

  void _toggleSelect(SelectableUser user) {
    final selected$ = user.selected$;
    final currentlySelected = selected$.value;
    
    if (currentlySelected) {
      // Remove user - find index first, then animate removal
      final index = _selected.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        final removedUser = _selected[index];
        
        // Adjust animation index due to reverse layout
        final animatedIndex = _selected.length - 1 - index;

        _animatedListKey.currentState?.removeItem(
          animatedIndex,
          (context, animation) => _buildAnimatedChip(removedUser, animation),
          duration: const Duration(milliseconds: 300),
        );
        
        setState(() {
          _selected.removeAt(index);
          selected$.value = false;
        });
      }
    } else {
      // Add user
      if (widget.maxSelectable != null && _selected.length >= widget.maxSelectable!) return;

      setState(() {
        _selected.add(user);
        selected$.value = true;
      });

      // Due to reverse layout, new items are inserted at index 0
      _animatedListKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
    }
    
    // Only update the selected array, no other processing
    widget.onChanged([..._selected]);
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    _searchManager.search(query);
  }

  void _onSearchResultChanged() {
    if (mounted) {
      // Update local users list with any new users from remote search
      final searchResults = _searchManager.results;
      bool hasNewUsers = false;
      
      for (final searchUser in searchResults) {
        // Check if this user is not in our local list
        if (!_allUsers.any((user) => user.id == searchUser.id)) {
          _allUsers.add(searchUser);
          hasNewUsers = true;
        }
      }
      
      // Re-group users only if we added new ones (performance optimization)
      if (hasNewUsers) {
        _groupUsers();
      }
      
      setState(() {});
    }
  }

  /// Helper function to get user display name from UserDBISAR
  String _getUserDisplayName(UserDBISAR user) {
    final name = user.name ?? '';
    final nickName = user.nickName ?? '';

    if (name.isNotEmpty && nickName.isNotEmpty) {
      return '$name($nickName)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (nickName.isNotEmpty) {
      return nickName;
    }
    return user.shortEncodedPubkey;
  }
} 