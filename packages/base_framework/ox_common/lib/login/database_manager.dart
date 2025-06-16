import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:chatcore/chat-core.dart';
import 'account_file_utils.dart';
import 'login_models.dart';
import 'account_models.dart';

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
      if (!await AccountPathUtils.ensureAccountFolderExists(pubkey)) {
        debugPrint('Failed to create account folder for $pubkey');
        return null;
      }

      // Get account database path using AccountPathUtils
      final accountDbPath = await AccountPathUtils.getAccountDbPath(pubkey);
      final accountDir = accountDbPath.substring(0, accountDbPath.lastIndexOf('/'));

      // Create own Isar instance with account schemas
      final accountIsar = Isar.getInstance('account_$pubkey') ??
        await Isar.open(
          AccountSchemas.schemas,
          directory: accountDir,
          name: 'account_$pubkey',
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
      if (!await AccountPathUtils.ensureCircleFolderExists(pubkey, circle.id)) {
        debugPrint('Failed to create circle folder for pubkey: $pubkey circleId: ${circle.id}');
        return null;
      }

      final circleFolder = await AccountPathUtils.getCircleFolderPath(pubkey, circle.id);
      await DBISAR.sharedInstance.open(
        pubkey,
        circleId: circle.id,
        dbPath: circleFolder,
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

  /// Close circle database  
  static Future<void> closeCircleDatabase() async {
    try {
      // For now, this relates to DBISAR.sharedInstance
      await DBISAR.sharedInstance.closeDatabase();
      debugPrint('Circle database closed');
    } catch (e) {
      debugPrint('Error closing circle database: $e');
    }
  }

  /// Create circle database file
  /// 
  /// [pubkey] User's public key
  /// [circle] Circle to create database for
  static Future<bool> createCircleDatabase(String pubkey, Circle circle) async {
    try {
      // Use DBISAR to create the database, it handles file creation internally
      await DBISAR.sharedInstance.open(pubkey, circleId: circle.id);
      
      debugPrint('Circle database created for ${circle.id}');
      return true;

    } catch (e) {
      debugPrint('Failed to create circle database for ${circle.id}: $e');
      return false;
    }
  }

  /// Delete circle database
  /// 
  /// [pubkey] User's public key  
  /// [circleId] Circle ID to delete database for
  static Future<bool> deleteCircleDatabase(String pubkey, String circleId) async {
    try {
      // Use DBISAR to delete the database
      return await DBISAR.sharedInstance.delete(pubkey, circleId: circleId);

    } catch (e) {
      debugPrint('Failed to delete circle database for $circleId: $e');
      return false;
    }
  }

  /// Get account database path
  static Future<String> getAccountDatabasePath(String pubkey) async {
    return await AccountPathUtils.getAccountDbPath(pubkey);
  }

  /// Check if account database exists
  static Future<bool> accountDatabaseExists(String pubkey) async {
    return await AccountPathUtils.accountDbExists(pubkey);
  }

  /// Check if circle database exists
  static Future<bool> circleDatabaseExists(String pubkey, String circleId) async {
    return await DBISAR.sharedInstance.exists(pubkey, circleId: circleId);
  }
} 