import 'package:bitchat_flutter_plugin/bitchat_core.dart' as BitChat;
import 'package:chatcore/chat-core.dart';
import '../model/bitchat_user_state.dart';

class BitchatUserHelper {
  /// Memory storage for user states that aren't stored in UserDBISAR
  /// Key: Peer.id (should be pubkey), Value: BitchatUserState
  static final Map<String, BitchatUserState> _userStateCache = {};

  /// Convert single Peer to UserDBISAR
  ///
  /// This creates a UserDBISAR with all required fields, setting non-peer
  /// fields to appropriate default values as requested.
  ///
  /// [peer] The bitchat Peer object to convert
  /// Returns UserDBISAR object
  static UserDBISAR _convertSinglePeer(BitChat.Peer peer) {
    final userDB = peer.asChatCoreUser();

    // Cache additional peer states for later management
    _cacheUserState(peer);

    return userDB;
  }

  /// Cache user state that's not stored in UserDBISAR
  ///
  /// Stores isBlocked, isFavorite, and connection information in memory
  /// for later retrieval and management operations.
  ///
  /// [peer] The peer whose state should be cached
  static void _cacheUserState(BitChat.Peer peer) {
    _userStateCache[peer.id] = peer.toBitchatUserState();
  }

  /// Get all current users as UserDBISAR objects
  ///
  /// Automatically gets current peers from BitchatService and converts them
  /// to UserDBISAR format without any filtering.
  ///
  /// Returns list of all discovered users as UserDBISAR objects
  static List<UserDBISAR> getCurrentUsers({
    bool includeBlocked = true,
    bool includeDisconnected = true,
    bool favoritesOnly = false,
  }) {
    // Get current peers from BitchatService
    final peers = BitchatService().getPeers();

    return peers.where((peer) {
      if (!includeBlocked && peer.isBlocked) return false;
      if (!includeDisconnected && !peer.isConnected) return false;
      if (favoritesOnly && !peer.isFavorite) return false;
      return true;
    }).map((peer) => _convertSinglePeer(peer)).toList();
  }
}

/// Extension methods for Peer to BitchatUserState conversion
extension PeerToBitchatUserState on BitChat.Peer {
  /// Convert Peer to BitchatUserState
  /// 
  /// Creates a new BitchatUserState instance with all the peer's state information
  /// cached at the current timestamp.
  BitchatUserState toBitchatUserState() {
    final now = DateTime.now();
    return BitchatUserState(
      isBlocked: isBlocked,
      isFavorite: isFavorite,
      isConnected: isConnected,
      rssi: rssi,
      lastSeen: lastSeen,
      cachedAt: now,
    );
  }

  UserDBISAR asChatCoreUser() {
    final user = UserDBISAR(
      // Basic identity fields
      pubKey: id, // Map Peer.id to pubKey (assuming it's pubkey format)
      name: nickname, // Map nickname to name as requested
      nickName: null, // Keep null to distinguish from name
      lastUpdatedTime: lastSeen.millisecondsSinceEpoch,

      // Authentication & encryption fields - default to empty
      encryptedPrivKey: '',
      privkey: '',
      defaultPassword: '',

      // Profile fields - default to empty
      mainRelay: '',
      dns: '',
      lnurl: '',
      badges: '',
      gender: '',
      area: '',
      about: '',
      picture: '',
      banner: '',

      // Private chat fields - default to empty
      aliasPubkey: '',
      toAliasPubkey: '',
      toAliasPrivkey: '',

      // Lists fields - default to null (will be initialized as empty lists)
      friendsList: null,
      channelsList: null,
      groupsList: null,
      relayGroupsList: null,
      badgesList: null,
      blockedList: null,
      blockedHashTags: null,
      blockedWords: null,
      blockedThreads: null,
      followingList: null,
      followersList: null,
      relayList: null,
      dmRelayList: null,
      inboxRelayList: null,
      outboxRelayList: null,

      // Timestamp fields - set to 0 as requested
      lastFriendsListUpdatedTime: 0,
      lastChannelsListUpdatedTime: 0,
      lastGroupsListUpdatedTime: 0,
      lastRelayGroupsListUpdatedTime: 0,
      lastBadgesListUpdatedTime: 0,
      lastBlockListUpdatedTime: 0,
      lastRelayListUpdatedTime: 0,
      lastFollowingListUpdatedTime: 0,
      lastDMRelayListUpdatedTime: 0,

      // Settings fields
      mute: false,
      otherField: '{}', // Default empty JSON object
      nwcURI: null,
      remoteSignerURI: null,
      clientPrivateKey: null,
      remotePubkey: null,
      encodedKeyPackage: null,
      keyPackageEventListJson: null,
      encodedKeyPackageJson: null,
      settings: null,
    );

    user.updateEncodedPubkey('');
    return user;
  }
} 