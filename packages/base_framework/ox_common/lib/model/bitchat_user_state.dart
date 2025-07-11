/// Model representing cached state for bitchat users
/// 
/// This model stores additional user information that exists in bitchat Peer
/// objects but not in UserDBISAR objects.
class BitchatUserState {
  /// Whether the user is blocked
  final bool isBlocked;
  
  /// Whether the user is marked as favorite
  final bool isFavorite;
  
  /// Whether the user is currently connected
  final bool isConnected;
  
  /// Signal strength (RSSI value, typically -100 to 0)
  final int rssi;
  
  /// Last time the user was seen
  final DateTime lastSeen;
  
  /// When this state was cached
  final DateTime cachedAt;
  
  /// When this state was last updated
  final DateTime? updatedAt;

  const BitchatUserState({
    required this.isBlocked,
    required this.isFavorite,
    required this.isConnected,
    required this.rssi,
    required this.lastSeen,
    required this.cachedAt,
    this.updatedAt,
  });



  /// Create a copy with updated values
  BitchatUserState copyWith({
    bool? isBlocked,
    bool? isFavorite,
    bool? isConnected,
    int? rssi,
    DateTime? lastSeen,
    DateTime? cachedAt,
    DateTime? updatedAt,
  }) {
    return BitchatUserState(
      isBlocked: isBlocked ?? this.isBlocked,
      isFavorite: isFavorite ?? this.isFavorite,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
      cachedAt: cachedAt ?? this.cachedAt,
      updatedAt: updatedAt ?? this.updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON for serialization (if needed)
  Map<String, dynamic> toJson() {
    return {
      'isBlocked': isBlocked,
      'isFavorite': isFavorite,
      'isConnected': isConnected,
      'rssi': rssi,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'cachedAt': cachedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from JSON
  factory BitchatUserState.fromJson(Map<String, dynamic> json) {
    return BitchatUserState(
      isBlocked: json['isBlocked'] as bool,
      isFavorite: json['isFavorite'] as bool,
      isConnected: json['isConnected'] as bool,
      rssi: json['rssi'] as int,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] as int),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  /// Get signal strength description
  String get signalStrengthDescription {
    if (rssi >= -30) return 'Excellent';
    if (rssi >= -50) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -90) return 'Poor';
    return 'Very Poor';
  }

  /// Check if user is recently seen (within last 5 minutes)
  bool get isRecentlySeen {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    return difference.inMinutes <= 5;
  }

  /// Check if cached data is stale (older than 30 minutes)
  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);
    return difference.inMinutes > 30;
  }

  @override
  String toString() {
    return 'BitchatUserState('
        'isBlocked: $isBlocked, '
        'isFavorite: $isFavorite, '
        'isConnected: $isConnected, '
        'rssi: $rssi, '
        'lastSeen: $lastSeen, '
        'cachedAt: $cachedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BitchatUserState &&
        other.isBlocked == isBlocked &&
        other.isFavorite == isFavorite &&
        other.isConnected == isConnected &&
        other.rssi == rssi &&
        other.lastSeen == lastSeen &&
        other.cachedAt == cachedAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      isBlocked,
      isFavorite,
      isConnected,
      rssi,
      lastSeen,
      cachedAt,
      updatedAt,
    );
  }
} 