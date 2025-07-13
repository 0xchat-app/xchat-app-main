import 'dart:async';
import 'package:flutter/foundation.dart';

/// Search state enumeration
enum SearchState {
  idle,         // idle state
  typing,       // typing
  debouncing,   // debouncing wait
  searching,    // searching
  completed,    // search completed
  error,        // search error
}

/// Search result wrapper
class SearchResult<T> {
  final List<T> results;
  final SearchState state;
  final String? error;
  final bool hasMore;

  const SearchResult({
    required this.results,
    required this.state,
    this.error,
    this.hasMore = false,
  });

  SearchResult<T> copyWith({
    List<T>? results,
    SearchState? state,
    String? error,
    bool? hasMore,
  }) {
    return SearchResult<T>(
      results: results ?? this.results,
      state: state ?? this.state,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Search manager with debouncing and state management
class SearchManager<T> {
  SearchManager({
    this.debounceDelay = const Duration(milliseconds: 300),
    this.minSearchLength = 1,
    this.maxResults = 100,
  });

  final Duration debounceDelay;
  final int minSearchLength;
  final int maxResults;

  Timer? _debounceTimer;
  String _currentQuery = '';
  final ValueNotifier<SearchResult<T>> _resultNotifier = ValueNotifier(
    const SearchResult(results: [], state: SearchState.idle),
  );

  /// Search result notifier
  ValueNotifier<SearchResult<T>> get resultNotifier => _resultNotifier;

  /// Current search query
  String get currentQuery => _currentQuery;

  /// Search state
  SearchState get state => _resultNotifier.value.state;

  /// Search results
  List<T> get results => _resultNotifier.value.results;

  /// Perform search with debouncing
  void search(
    String query, {
    required Future<List<T>> Function(String) localSearch,
    Future<List<T>> Function(String)? remoteSearch,
  }) {
    _currentQuery = query.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (_currentQuery.isEmpty) {
      _updateResult(const SearchResult(results: [], state: SearchState.idle));
      return;
    }

    if (_currentQuery.length < minSearchLength) {
      _updateResult(const SearchResult(results: [], state: SearchState.typing));
      return;
    }

    // Show typing state immediately
    _updateResult(SearchResult(
      results: _resultNotifier.value.results,
      state: SearchState.typing,
    ));

    // Start debounce timer
    _debounceTimer = Timer(debounceDelay, () async {
      await _performSearch(localSearch, remoteSearch);
    });
  }

  /// Perform immediate search without debouncing
  Future<void> searchImmediate(
    String query, {
    required Future<List<T>> Function(String) localSearch,
    Future<List<T>> Function(String)? remoteSearch,
  }) async {
    _currentQuery = query.trim();
    _debounceTimer?.cancel();
    
    if (_currentQuery.isEmpty) {
      _updateResult(const SearchResult(results: [], state: SearchState.idle));
      return;
    }

    await _performSearch(localSearch, remoteSearch);
  }

  /// Internal search implementation
  Future<void> _performSearch(
    Future<List<T>> Function(String) localSearch,
    Future<List<T>> Function(String)? remoteSearch,
  ) async {
    if (_currentQuery.isEmpty) return;

    try {
      // Set searching state
      _updateResult(SearchResult(
        results: _resultNotifier.value.results,
        state: SearchState.searching,
      ));

      // Perform local search first
      final localResults = await localSearch(_currentQuery);
      
      // Update with local results
      _updateResult(SearchResult(
        results: localResults.take(maxResults).toList(),
        state: SearchState.completed,
        hasMore: localResults.length > maxResults,
      ));

      // Perform remote search if available and needed
      if (remoteSearch != null && localResults.length < maxResults) {
        try {
          final remoteResults = await remoteSearch(_currentQuery);
          
          // Merge results, avoiding duplicates
          final mergedResults = <T>[...localResults];
          for (final result in remoteResults) {
            if (!mergedResults.contains(result)) {
              mergedResults.add(result);
            }
          }
          
          _updateResult(SearchResult(
            results: mergedResults.take(maxResults).toList(),
            state: SearchState.completed,
            hasMore: mergedResults.length > maxResults,
          ));
        } catch (e) {
          // Remote search failed, but local results are still valid
          debugPrint('Remote search failed: $e');
        }
      }
    } catch (e) {
      _updateResult(SearchResult(
        results: [],
        state: SearchState.error,
        error: e.toString(),
      ));
    }
  }

  /// Update search result
  void _updateResult(SearchResult<T> result) {
    _resultNotifier.value = result;
  }

  /// Clear search results
  void clear() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _updateResult(const SearchResult(results: [], state: SearchState.idle));
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _resultNotifier.dispose();
  }
} 