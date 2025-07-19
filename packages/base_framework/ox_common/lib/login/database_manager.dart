import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:chatcore/chat-core.dart';
import 'account_path_manager.dart';
import 'login_models.dart';
import 'account_models.dart';
import '../secure/db_key_manager.dart';

/// Database utilities for handling account and circle databases
/// 
/// Provides static utility methods for database operations:
/// - Account database initialization and opening
/// - Circle database initialization and opening  
/// - Database path management using AccountPathUtils
/// - No state management - all operations are stateless
class DatabaseUtils {
  // Private constructor to prevent instantiation
  DatabaseUtils._();

  /// Initialize account database
  /// 
  /// Creates its own Isar instance instead of using DBISAR.sharedInstance
  /// [pubkey] User's public key
  /// Returns Isar instance if successful, null if failed
  static Future<Isar?> initAccountDatabase(String pubkey) async {
    try {
      // Ensure account folder exists
      if (!await AccountPathManager.ensureAccountFolderExists(pubkey)) {
        debugPrint('Failed to create account folder for $pubkey');
        return null;
      }

      // Get account database path using AccountPathManager
      final accountDbPath = await AccountPathManager.getAccountDbPath(pubkey);
      final accountDir = accountDbPath.substring(0, accountDbPath.lastIndexOf('/'));

      // Create own Isar instance with account schemas
      final String encKey = await DBKeyManager.getKey();
      final accountIsar = await Isar.openAsync(
        schemas: AccountSchemas.schemas,
        directory: accountDir,
        name: 'account_$pubkey',
        engine: IsarEngine.sqlite,
        encryptionKey: encKey,
      );

      debugPrint('Account database initialized for $pubkey with own Isar instance');
      return accountIsar;

    } catch (e) {
      debugPrint('Failed to initialize account database for $pubkey: $e');
      return null;
    }
  }

  /// Initialize circle database
  /// 
  /// Uses DBISAR.sharedInstance.open with internal path management
  /// [pubkey] User's public key
  /// [circle] Circle to initialize database for
  /// Returns Isar instance if successful, null if failed
  static Future<Isar?> initCircleDatabase(String pubkey, Circle circle) async {
    try {
      // Ensure circle folder exists
      if (!await AccountPathManager.ensureCircleFolderExists(pubkey, circle.id)) {
        debugPrint('Failed to create circle folder for pubkey: $pubkey circleId: ${circle.id}');
        return null;
      }

      final circleFolder = await AccountPathManager.getCircleFolderPath(pubkey, circle.id);
      final String encKey = await DBKeyManager.getKey();
      await DBISAR.sharedInstance.open(
        pubkey,
        circleId: circle.id,
        dbPath: circleFolder,
        encryptionKey: encKey,
      );
      
      debugPrint('Circle database initialized for ${circle.id}');
      return DBISAR.sharedInstance.isar;

    } catch (e) {
      debugPrint('Failed to initialize circle database for ${circle.id}: $e');
      return null;
    }
  }

  /// Close account database
  static Future<void> closeAccountDatabase(Isar db) async {
    try {
      if (db.isOpen) await db.close();
      debugPrint('Account database closed');
    } catch (e) {
      debugPrint('Error closing account database: $e');
    }
  }
} 