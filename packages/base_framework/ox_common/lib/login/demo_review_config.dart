// Demo account config for App Store review (Guideline 2.1(a)).
// Provide a demo account so reviewers can access all features including report/block.
//
// Demo relay: wss://relay.damus.io (data is seeded locally only).
//
// Apple test account nsec (provide this in App Store Connect > App Review Information):
//   nsec1vl029mgpspedva04g90vltkh6fvh240zqtv9k0t9af8935ke9laqsnlfe5

/// Demo circle relay URL. Reviewers using the demo account will auto-join this circle.
const String kDemoRelayUrl = 'wss://relay.damus.io';

/// Demo account pubkey (hex, 64 chars). Login with the corresponding nsec is treated as demo account.
/// Derived from nsec1vl029mgpspedva04g90vltkh6fvh240zqtv9k0t9af8935ke9laqsnlfe5
const String kDemoAccountPubkey =
    '7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e';

/// Demo friend pubkey (hex) for pre-populated contact and chat. Can be any valid pubkey.
const String kDemoFriendPubkey =
    'c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5';

/// Avatar URL for demo account (me). Shown in profile and chat.
const String kDemoAccountAvatarUrl =
    'https://ui-avatars.com/api/?name=Demo&background=4A90D9&color=fff&size=256';

/// Avatar URL for demo friend (XChat Demo). Shown in contacts and chat.
const String kDemoFriendAvatarUrl =
    'https://ui-avatars.com/api/?name=XC&background=50C878&color=fff&size=256';

/// Storage key to mark that demo seed has been applied for current circle (avoid re-seeding).
const String kDemoSeedDoneKey = 'demo_review_seed_done';
