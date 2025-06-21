import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Lightweight data model used by [CLMultiUserSelector].
class SelectableUser {
  SelectableUser({
    required this.id,
    required this.displayName,
    this.avatarUrl = '',
    bool defaultSelected = false,
  }) : selected$ = ValueNotifier<bool>(defaultSelected);

  final String id; // Unique identifier of user
  final String displayName;
  final String avatarUrl;
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
    required this.users,
    this.initialSelectedIds = const [],
    required this.onChanged,
    this.title,
    this.maxSelectable,
    this.actions,
  });

  final List<SelectableUser> users;
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

  late List<SelectableUser> _allUsers;
  late Map<String, List<SelectableUser>> _groupedUsers;

  final List<SelectableUser> _selected = [];
  List<SelectableUser> _searchResults = [];

  // For tracking scroll-based background color changes
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _allUsers = List.from(widget.users);
    for (final id in widget.initialSelectedIds) {
      final user = widget.users.firstWhere((u) => u.id == id, orElse: () => SelectableUser(id: id, displayName: id));
      _selected.add(user);
    }
    _groupUsers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _groupUsers() {
    _groupedUsers = {};
    for (final user in _allUsers) {
      String first = '#';
      if (user.displayName.isNotEmpty) {
        final ch = user.displayName[0].toUpperCase();
        if (RegExp(r'[A-Z]').hasMatch(ch)) {
          first = ch;
        }
      }
      _groupedUsers.putIfAbsent(first, () => []).add(user);
    }
    _groupedUsers.forEach((key, list) {
      list.sort((a, b) => a.displayName.compareTo(b.displayName));
    });
  }

  // --- UI builders ---------------------------------------------------------

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
      body: _buildBody(),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return CLSearch(
      controller: _searchCtrl,
      prefixIcon: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200.px),
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
      ),
      padding: EdgeInsets.all(16.px),
      placeholder: Localized.text('ox_chat.search'),
      onChanged: (value) => _onSearchChanged(),
    );
  }



  Widget _buildAnimatedChip(SelectableUser user, Animation<double> animation) {
    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
      ),
      child: ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: 0.5, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(right: 8.px),
          child: GestureDetector(
            onTap: () => _toggleSelect(user),
            child: Container(
              alignment: Alignment.center,
              child: OXUserAvatar(
                user: null,
                imageUrl: user.avatarUrl,
                size: 36.px,
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
    return [SectionListViewItem(data: _searchResults.map(_buildUserItem).toList())];
  }

  ListViewItem _buildUserItem(SelectableUser user) {
    return MultiSelectItemModel<String>(
      title: user.displayName,
      value$: user.selected$,
      icon: null,
      onTap: () {
        _toggleSelect(user);
      },
    );
  }

  // --- logic ---------------------------------------------------------------

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
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }
    setState(() {
      _searchResults = _allUsers
          .where((u) => u.displayName.toLowerCase().contains(q))
          .toList();
    });
  }
} 