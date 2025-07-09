import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/repository/file_server_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_localizable/ox_localizable.dart';

class FileServerHelper {
  FileServerHelper._();

  /// Returns the current circle's selected [FileServerModel] asynchronously.
  /// Returns `null` when no server is configured.
  static Future<FileServerModel?> currentFileServer() async {
    final circle = LoginManager.instance.currentCircle;
    final url = circle?.selectedFileServerUrl;
    if (url == null || url.isEmpty) return null;

    final repo = FileServerRepository(DBISAR.sharedInstance.isar);
    final list = await repo.watchAll().first;
    try {
      return list.firstWhere((e) => e.url == url);
    } catch (_) {
      return null;
    }
  }

  /// Ensure current circle has configured file server.
  ///
  /// Returns `true` when already configured.
  /// When not configured, shows an alert dialog. If the user chooses to go to
  /// settings, the optional [onGoToSettings] callback will be invoked.
  /// In all not-configured cases, returns `false` so caller can early bail out.
  static Future<bool> ensureFileServerConfigured(
    BuildContext context, {
    VoidCallback? onGoToSettings,
  }) async {
    final circle = LoginManager.instance.currentCircle;
    if (circle != null && circle.selectedFileServerUrl.isNotEmpty) {
      return true;
    }

    final result = await CLAlertDialog.show<bool>(
      context: context,
              title: Localized.text('ox_common.require_file_server_title'),
        content: Localized.text('ox_common.require_file_server'),
      actions: [
        CLAlertAction.cancel(),
        CLAlertAction<bool>(
          label: Localized.text('ox_common.str_go_to_settings'),
          value: true,
          isDefaultAction: true,
        ),
      ],
    );

    if (result == true) {
      onGoToSettings?.call();
    }

    return false;
  }
} 