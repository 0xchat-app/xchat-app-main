import 'package:flutter/foundation.dart';
import 'package:ox_common/utils/search_manager.dart';
import 'package:ox_common/widgets/multi_user_selector.dart';
import 'user_search_manager.dart';

/// Search manager for SelectableUser objects, used in group member selection
class SelectableUserSearchManager {
  final SearchManager<SelectableUser> _searchManager;
  final UserSearchManager _userSearchManager;
  List<SelectableUser> _allUsers = [];
  bool _isLoading = false;
  bool _isUserSearchManagerListenerAdded = false;

  SelectableUserSearchManager({
    Duration debounceDelay = const Duration(milliseconds: 300),
    int minSearchLength = 1,
    int maxResults = 50,
  }) : _searchManager = SearchManager<SelectableUser>(
          debounceDelay: debounceDelay,
          minSearchLength: minSearchLength,
          maxResults: maxResults,
        ),
        _userSearchManager = UserSearchManager(
          debounceDelay: debounceDelay,
          minSearchLength: minSearchLength,
          maxResults: maxResults,
        );

  /// Get the underlying search manager's result notifier
  ValueNotifier<SearchResult<SelectableUser>> get resultNotifier => _searchManager.resultNotifier;

  /// Get current search results
  List<SelectableUser> get results => _searchManager.results;

  /// Get current search state
  SearchState get state => _searchManager.state;

  /// Get current search query
  String get currentQuery => _searchManager.currentQuery;

  /// Check if currently loading users
  bool get isLoading => _isLoading;

  /// Initialize with available users (excluding certain users)
  Future<void> initialize({
    required List<String> excludeUserPubkeys,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      await _userSearchManager.initialize();
      
      // Filter out excluded users and convert to SelectableUser
      final availableUsers = _userSearchManager.allUsers
          .where((user) => !excludeUserPubkeys.contains(user.pubKey))
          .toList();

      _allUsers = availableUsers.map((user) => SelectableUser(
        id: user.pubKey,
        displayName: _userSearchManager.getUserDisplayName(user),
        avatarUrl: user.picture ?? '',
      )).toList();
    } catch (e) {
      print('Error loading users: $e');
      _allUsers = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Get all loaded users
  List<SelectableUser> get allUsers => List.unmodifiable(_allUsers);

  /// Perform search with the given query
  void search(String query) {
    _searchManager.search(
      query,
      localSearch: _performLocalSearch,
      remoteSearch: _performRemoteSearch,
    );
  }

  /// Perform immediate search without debouncing
  Future<void> searchImmediate(String query) async {
    await _searchManager.searchImmediate(
      query,
      localSearch: _performLocalSearch,
      remoteSearch: _performRemoteSearch,
    );
  }

  /// Clear search results
  void clear() {
    _searchManager.clear();
  }

  /// Dispose resources
  void dispose() {
    if (_isUserSearchManagerListenerAdded) {
      _userSearchManager.resultNotifier.removeListener(_onUserSearchManagerResultChanged);
      _isUserSearchManagerListenerAdded = false;
    }
    _searchManager.dispose();
    _userSearchManager.dispose();
  }

  /// Perform local search on loaded users
  Future<List<SelectableUser>> _performLocalSearch(String query) async {
    final lowerQuery = query.toLowerCase();
    return _allUsers.where((user) {
      final displayName = user.displayName.toLowerCase();
      final userId = user.id.toLowerCase();

      return displayName.contains(lowerQuery) ||
          userId.contains(lowerQuery);
    }).toList();
  }

  /// Perform remote search and convert results to SelectableUser
  Future<List<SelectableUser>> _performRemoteSearch(String query) async {
    // Use UserSearchManager for remote search
    final userResults = await _userSearchManager.performRemoteSearch(query);
    
    // Convert to SelectableUser and add to local users if not already present
    final selectableResults = <SelectableUser>[];
    for (final user in userResults) {
      final selectableUser = SelectableUser(
        id: user.pubKey,
        displayName: _userSearchManager.getUserDisplayName(user),
        avatarUrl: user.picture ?? '',
      );
      
      // Add to local users if not already present
      if (!_allUsers.any((u) => u.id == selectableUser.id)) {
        _allUsers.add(selectableUser);
      }
      
      selectableResults.add(selectableUser);
    }
    
    // Set up listener for UserSearchManager result changes to update SelectableUser results
    _setupUserSearchManagerListener();
    
    return selectableResults;
  }

  /// Setup listener for UserSearchManager to handle user info updates
  void _setupUserSearchManagerListener() {
    if (_isUserSearchManagerListenerAdded) return;
    
    // Listen to UserSearchManager result changes
    _userSearchManager.resultNotifier.addListener(_onUserSearchManagerResultChanged);
    _isUserSearchManagerListenerAdded = true;
  }

  /// Handle UserSearchManager result changes
  void _onUserSearchManagerResultChanged() {
    // When UserSearchManager results change (e.g., user info updated from remote),
    // we need to refresh our current search to get the updated SelectableUser results
    final currentQuery = _searchManager.currentQuery;
    
    if (currentQuery.isNotEmpty) {
      // Re-trigger the search to get updated results
      // This will call _performLocalSearch which will use updated user info
      searchImmediate(currentQuery);
    }
  }
} 