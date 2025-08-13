import 'dart:math';
import 'package:nostr_core_dart/nostr.dart';

/// Random username generator for new accounts
/// 
/// Generates unique and interesting usernames based on npub (public key)
/// Each username is consistent for the same public key
class UsernameGenerator {
  UsernameGenerator._();
  
  static final UsernameGenerator instance = UsernameGenerator._();
  
  // Adjective lists for generating interesting usernames
  static const List<String> _adjectives = [
    'Swift', 'Bright', 'Cosmic', 'Digital', 'Ethereal', 'Fierce', 'Gentle',
    'Hidden', 'Infinite', 'Jovial', 'Keen', 'Luminous', 'Mystic', 'Noble',
    'Oceanic', 'Peaceful', 'Quantum', 'Radiant', 'Serene', 'Timeless',
    'Unique', 'Vibrant', 'Wise', 'Xenial', 'Youthful', 'Zealous',
    'Adventurous', 'Bold', 'Creative', 'Dynamic', 'Energetic', 'Friendly',
    'Graceful', 'Harmonious', 'Innovative', 'Joyful', 'Kind', 'Lively',
    'Magical', 'Natural', 'Optimistic', 'Playful', 'Quirky', 'Resilient',
    'Spirited', 'Thoughtful', 'Upbeat', 'Versatile', 'Whimsical', 'Zesty'
  ];
  
  // Noun lists for generating interesting usernames
  static const List<String> _nouns = [
    'Explorer', 'Voyager', 'Pioneer', 'Navigator', 'Discoverer', 'Adventurer',
    'Dreamer', 'Thinker', 'Creator', 'Builder', 'Artist', 'Scientist',
    'Philosopher', 'Scholar', 'Sage', 'Mentor', 'Guide', 'Teacher',
    'Warrior', 'Guardian', 'Protector', 'Defender', 'Champion', 'Hero',
    'Wanderer', 'Traveler', 'Nomad', 'Pilgrim', 'Seeker', 'Finder',
    'Observer', 'Witness', 'Spectator', 'Audience', 'Listener', 'Speaker',
    'Writer', 'Reader', 'Learner', 'Student', 'Master', 'Apprentice',
    'Companion', 'Friend', 'Partner', 'Ally', 'Supporter', 'Helper'
  ];
  
  // Animal names for variety
  static const List<String> _animals = [
    'Dragon', 'Phoenix', 'Wolf', 'Eagle', 'Lion', 'Tiger', 'Bear',
    'Fox', 'Owl', 'Hawk', 'Falcon', 'Raven', 'Crow', 'Sparrow',
    'Butterfly', 'Bee', 'Ant', 'Spider', 'Scorpion', 'Snake',
    'Dolphin', 'Whale', 'Shark', 'Octopus', 'Squid', 'Crab',
    'Elephant', 'Giraffe', 'Zebra', 'Gorilla', 'Chimpanzee', 'Orangutan'
  ];
  
  // Tech-related terms
  static const List<String> _techTerms = [
    'Byte', 'Bit', 'Pixel', 'Vector', 'Matrix', 'Array', 'String',
    'Function', 'Class', 'Object', 'Variable', 'Constant', 'Parameter',
    'Algorithm', 'Protocol', 'Interface', 'Module', 'Package', 'Library',
    'Framework', 'Platform', 'System', 'Network', 'Database', 'Cache',
    'Server', 'Client', 'Router', 'Gateway', 'Firewall', 'Proxy'
  ];
  
  /// Generate a random username based on npub
  /// 
  /// [npub] The npub public key to generate username from
  /// Returns a unique username string
  String generateUsername(String npub) {
    final hash = _hashString(npub);
    final random = Random(hash);
    
    // Choose username style based on hash
    final style = random.nextInt(4);
    
    switch (style) {
      case 0:
        return _generateAdjectiveNoun(random);
      case 1:
        return _generateAnimalAdjective(random);
      case 2:
        return _generateTechAdjective(random);
      case 3:
        return _generateNumberedName(random);
      default:
        return _generateAdjectiveNoun(random);
    }
  }
  
  /// Generate adjective + noun combination
  String _generateAdjectiveNoun(Random random) {
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    return '$adjective$noun';
  }
  
  /// Generate animal + adjective combination
  String _generateAnimalAdjective(Random random) {
    final animal = _animals[random.nextInt(_animals.length)];
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    return '$adjective$animal';
  }
  
  /// Generate tech term + adjective combination
  String _generateTechAdjective(Random random) {
    final techTerm = _techTerms[random.nextInt(_techTerms.length)];
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    return '$adjective$techTerm';
  }
  
  /// Generate numbered name
  String _generateNumberedName(Random random) {
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final number = random.nextInt(999) + 1;
    return '$adjective$number';
  }
  
  /// Generate multiple username options
  List<String> generateUsernameOptions(String npub, {int count = 5}) {
    final usernames = <String>{};
    final baseHash = _hashString(npub);
    
    // Generate base username
    usernames.add(generateUsername(npub));
    
    // Generate variations
    for (int i = 1; i < count; i++) {
      final variationHash = baseHash + i;
      final random = Random(variationHash);
      
      final style = random.nextInt(4);
      String username;
      
      switch (style) {
        case 0:
          username = _generateAdjectiveNoun(random);
          break;
        case 1:
          username = _generateAnimalAdjective(random);
          break;
        case 2:
          username = _generateTechAdjective(random);
          break;
        case 3:
          username = _generateNumberedName(random);
          break;
        default:
          username = _generateAdjectiveNoun(random);
      }
      
      usernames.add(username);
    }
    
    return usernames.toList();
  }
  
  /// Simple hash function for consistent random generation
  int _hashString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash;
  }
}
