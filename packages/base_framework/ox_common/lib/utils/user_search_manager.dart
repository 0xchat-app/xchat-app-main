import 'package:flutter/foundation.dart';
import 'package:ox_common/utils/search_manager.dart';
import 'package:chatcore/chat-core.dart';

/// Generic user search manager that handles both local and remote user searches
/// with support for different user model types through conversion
class UserSearchManager<T> {
  final SearchManager<T> _searchManager;
  List<UserDBISAR> _allUsers = [];
  bool _isLoading = false;

  // Track remote search users for dynamic updates
  final Set<String> _remoteSearchUserPubkeys = {};
  final Map<String, void Function()> _userUpdateListeners = {};

  // Conversion functions
  final T Function(UserDBISAR) _convertToTargetModel;
  final String Function(T) _getUserId;
  final String Function(T) _getUserDisplayName;

  static UserSearchManager<UserDBISAR> defaultCreate({
    Duration debounceDelay = const Duration(milliseconds: 300),
    int minSearchLength = 1,
    int maxResults = 50,
  }) => _DefaultUserSearchManager(
    debounceDelay: debounceDelay,
    minSearchLength: minSearchLength,
    maxResults: maxResults,
  );

  /// Constructor for custom user models
  /// Use this when your user model is different from UserDBISAR
  UserSearchManager.custom({
    required T Function(UserDBISAR) convertToTargetModel,
    required String Function(T) getUserId,
    required String Function(T) getUserDisplayName,
    Duration debounceDelay = const Duration(milliseconds: 300),
    int minSearchLength = 1,
    int maxResults = 50,
  })  : _convertToTargetModel = convertToTargetModel,
        _getUserId = getUserId,
        _getUserDisplayName = getUserDisplayName,
        _searchManager = SearchManager<T>(
          debounceDelay: debounceDelay,
          minSearchLength: minSearchLength,
          maxResults: maxResults,
        );

  /// Get the underlying search manager's result notifier
  ValueNotifier<SearchResult<T>> get resultNotifier =>
      _searchManager.resultNotifier;

  /// Get current search results
  List<T> get results => _searchManager.results;

  /// Get current search state
  SearchState get state => _searchManager.state;

  /// Get current search query
  String get currentQuery => _searchManager.currentQuery;

  /// Check if currently loading users
  bool get isLoading => _isLoading;

  /// Initialize and load user data
  Future<void> initialize({List<String>? excludeUserPubkeys}) async {
    if (_isLoading) return;

    _isLoading = true;
    try {
      // Use Account class to get all users from cache
      final account = Account.sharedInstance;
      _allUsers =
          account.userCache.values.map((notifier) => notifier.value).toList();
      
      // Filter out excluded users if provided
      if (excludeUserPubkeys != null && excludeUserPubkeys.isNotEmpty) {
        _allUsers = _allUsers.where((user) => 
          !excludeUserPubkeys.contains(user.pubKey)
        ).toList();
      }
    } catch (e) {
      print('Error loading users: $e');
      _allUsers = [];
    } finally {
      _isLoading = false;
    }
  }

  /// Get all loaded users converted to target model
  List<T> get allUsers => _allUsers.map(_convertToTargetModel).toList();

  /// Perform search with the given query
  void search(String query) {
    _searchManager.search(
      query,
      localSearch: _performLocalSearch,
      remoteSearch: _performRemoteSearch,
      isDuplicate: (local, remote) => _getUserId(local) == _getUserId(remote),
    );
  }

  /// Perform immediate search without debouncing
  Future<void> searchImmediate(String query) async {
    await _searchManager.searchImmediate(
      query,
      localSearch: _performLocalSearch,
      remoteSearch: _performRemoteSearch,
      isDuplicate: (local, remote) => _getUserId(local) == _getUserId(remote),
    );
  }

  /// Clear search results
  void clear() {
    _searchManager.clear();
  }

  /// Dispose resources
  void dispose() {
    _removeAllUserUpdateListeners();
    _searchManager.dispose();
  }

  /// Perform local search on loaded users
  Future<List<T>> _performLocalSearch(String query) async {
    final lowerQuery = query.toLowerCase();
    return _allUsers
        .where((user) {
          final name = (user.name ?? '').toLowerCase();
          final nickName = (user.nickName ?? '').toLowerCase();
          final encodedPubkey = user.encodedPubkey.toLowerCase();

          return name.contains(lowerQuery) ||
              nickName.contains(lowerQuery) ||
              encodedPubkey.contains(lowerQuery);
        })
        .map(_convertToTargetModel)
        .toList();
  }

  /// Perform remote search for users by pubkey or DNS (public method)
  Future<List<T>> performRemoteSearch(String query) async {
    return _performRemoteSearch(query);
  }

  /// Perform remote search for users by pubkey or DNS
  Future<List<T>> _performRemoteSearch(String query) async {
    final isPubkeyFormat = query.startsWith('npub');
    final isDnsFormat = query.contains('@');

    if (!isPubkeyFormat && !isDnsFormat) {
      return [];
    }

    String pubkey = '';
    if (isPubkeyFormat) {
      pubkey = UserDBISAR.decodePubkey(query) ?? '';
    } else if (isDnsFormat) {
      pubkey = await Account.getDNSPubkey(
            query.substring(0, query.indexOf('@')),
            query.substring(query.indexOf('@') + 1),
          ) ??
          '';
    }

    if (pubkey.isNotEmpty) {
      UserDBISAR? user = await Account.sharedInstance.getUserInfo(pubkey);
      if (user != null) {
        // Add to local users if not already present
        if (!_allUsers.any((u) => u.pubKey == user.pubKey)) {
          _allUsers.add(user);
        }

        // Add listener for user info updates for remote search users
        // This allows real-time updates when user info is fetched from remote
        Account.sharedInstance.reloadProfileFromRelay(user.pubKey,);
        _addUserUpdateListener(pubkey);

        return [_convertToTargetModel(user)];
      }
    }

    return [];
  }

  /// Get user display name from target model
  String getUserDisplayName(T user) {
    return _getUserDisplayName(user);
  }

  /// Add listener for user info updates from remote search
  void _addUserUpdateListener(String pubkey) {
    if (_userUpdateListeners.containsKey(pubkey)) return;

    final userNotifier = Account.sharedInstance.getUserNotifier(pubkey);
    final listener = () {
      _onRemoteUserInfoUpdated(pubkey, userNotifier.value);
    };

    userNotifier.addListener(listener);
    _userUpdateListeners[pubkey] = listener;
    _remoteSearchUserPubkeys.add(pubkey);
  }

  /// Remove listener for specific user
  void _removeUserUpdateListener(String pubkey) {
    final listener = _userUpdateListeners.remove(pubkey);
    if (listener != null) {
      final userNotifier = Account.sharedInstance.getUserNotifier(pubkey);
      userNotifier.removeListener(listener);
    }
    _remoteSearchUserPubkeys.remove(pubkey);
  }

  /// Remove all user update listeners
  void _removeAllUserUpdateListeners() {
    for (final pubkey in _userUpdateListeners.keys.toList()) {
      _removeUserUpdateListener(pubkey);
    }
  }

  /// Handle remote user info updates
  void _onRemoteUserInfoUpdated(String pubkey, UserDBISAR updatedUser) {
    // Update the user in _allUsers list
    final index = _allUsers.indexWhere((user) => user.pubKey == pubkey);
    if (index != -1) {
      _allUsers[index] = updatedUser;

      // If this user is in current search results, refresh the search
      final currentResults = _searchManager.results;
      final updatedUserModel = _convertToTargetModel(updatedUser);
      if (currentResults
          .any((user) => _getUserId(user) == _getUserId(updatedUserModel))) {
        _refreshCurrentSearchResults();
      }
    }
  }

  /// Refresh current search results without changing the query
  void _refreshCurrentSearchResults() {
    final currentQuery = _searchManager.currentQuery;
    if (currentQuery.isNotEmpty) {
      // Trigger a new search with the same query to update results
      _searchManager.searchImmediate(
        currentQuery,
        localSearch: _performLocalSearch,
        remoteSearch: _performRemoteSearch,
        isDuplicate: (local, remote) => _getUserId(local) == _getUserId(remote),
      );
    }
  }
}

/// Default UserSearchManager for UserDBISAR
/// Use this when your user model is UserDBISAR (no conversion needed)
class _DefaultUserSearchManager extends UserSearchManager<UserDBISAR> {
  _DefaultUserSearchManager({
    Duration debounceDelay = const Duration(milliseconds: 300),
    int minSearchLength = 1,
    int maxResults = 50,
  }) : super.custom(
          convertToTargetModel: defaultConvertToTargetModel,
          getUserId: defaultGetUserId,
          getUserDisplayName: defaultGetUserDisplayName,
          debounceDelay: debounceDelay,
          minSearchLength: minSearchLength,
          maxResults: maxResults,
        );

  static UserDBISAR defaultConvertToTargetModel(UserDBISAR user) => user;

  static String defaultGetUserId(UserDBISAR user) => user.pubKey;

  static String defaultGetUserDisplayName(UserDBISAR user) {
    final name = user.name ?? '';
    final nickName = user.nickName ?? '';

    if (name.isNotEmpty && nickName.isNotEmpty) {
      return '$name($nickName)';
    } else if (name.isNotEmpty) {
      return name;
    } else if (nickName.isNotEmpty) {
      return nickName;
    }
    return 'Unknown';
  }
}
