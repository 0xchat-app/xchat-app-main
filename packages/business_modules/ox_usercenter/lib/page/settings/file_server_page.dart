import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/extension.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/repository/file_server_repository.dart';
import 'add_file_server_page.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/login/login_manager.dart';
import 'dart:async';

import 'package:ox_common/model/file_server_model.dart';

/// File Server Settings page.
class FileServerPage extends StatefulWidget {
  const FileServerPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<FileServerPage> createState() => _FileServerPageState();
}

class _FileServerPageState extends State<FileServerPage> {
  final ValueNotifier<List<FileServerModel>> _servers$ =
  ValueNotifier<List<FileServerModel>>([]);
  // Holds selected server relay URL.
  final ValueNotifier<String?> _selected$ = ValueNotifier(null);
  bool _isEditing = false;
  late final FileServerRepository _repo;

  /// Subscription for the repo stream, used to cancel listening when the page is disposed.
  late final StreamSubscription<List<FileServerModel>> _repoSub;

  // Holds the url selected in circle config before servers list is loaded.
  String? _pendingSelectedUrl;

  String get _title => Localized.text('ox_usercenter.file_server_setting');

  @override
  void initState() {
    super.initState();

    prepareData();
    _loadInitialSelection();
    addListener();
  }

  void prepareData() {
    _repo = FileServerRepository(DBISAR.sharedInstance.isar);
    final fileServers = _repo.fetch();
    _servers$.value = fileServers;

    final selectedFileServerUrl = LoginManager.instance.currentCircle?.selectedFileServerUrl;
    if (selectedFileServerUrl != null && selectedFileServerUrl.isNotEmpty) {
      _selected$.value = selectedFileServerUrl;
    }
  }

  void _loadInitialSelection() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) return;
    if (circle.selectedFileServerUrl.isNotEmpty) {
      _pendingSelectedUrl = circle.selectedFileServerUrl;
    }
  }

  void addListener() {
    // Listen list changes
    _repoSub = _repo.watchAll().listen((servers) {

      if (!mounted) return;

      _servers$.safeUpdate(servers);

      // Apply pending selection from circle config once list is available.
      if (_pendingSelectedUrl != null) {
        FileServerModel? matched;
        for (final fs in servers) {
          if (fs.url == _pendingSelectedUrl) {
            matched = fs;
            break;
          }
        }
        matched ??= servers.isNotEmpty ? servers.first : null;

        if (matched != null) {
          _selected$.safeUpdate(matched.url);
        }
        _pendingSelectedUrl = null;
      }

      // If current selection has been removed, select the first available one.
      final selectedUrl = _selected$.value;
      final isSelected = servers.any((e) => e.url == selectedUrl);
      if (selectedUrl != null && !isSelected) {
        _selected$.safeUpdate(servers.isNotEmpty ? servers.first.url : null);
      }
    });

    // Listen to selection changes and persist into circle config.
    _selected$.addListener(() {
      final selectedUrl = _selected$.value;
      final circle = LoginManager.instance.currentCircle;
      if (circle == null) return;

      // When url is null, clear selection.
      if (selectedUrl == null || selectedUrl.isEmpty) {
        circle.updateSelectedFileServerUrl('');
        return;
      }

      circle.updateSelectedFileServerUrl(selectedUrl);
    });
  }

  @override
  void dispose() {
    // Stop listening to repository changes before disposing the notifiers to
    // avoid attempting to update disposed objects.
    _repoSub.cancel();
    _servers$.dispose();
    _selected$.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidget = _buildBody(context);

    return CLScaffold(
      appBar: CLAppBar(
        title: _title,
        previousPageTitle: widget.previousPageTitle,
        actions: [
          CLButton.text(
            text: _isEditing ? Localized.text('ox_common.complete') : Localized.text('ox_usercenter.edit'),
            onTap: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      isSectionListPage: true,
      body: bodyWidget,
    );
  }

  Widget _buildBody(BuildContext context) {
    final listWidget = ValueListenableBuilder(
      valueListenable: _servers$,
      builder: (_, List<FileServerModel> list, __) {
        if (list.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 220.py),
            child: _buildEmptyBody(),
          );
        }

        return CLSectionListView(
          items: [
            SectionListViewItem(
              data: list.map((item) => SelectedItemModel<String?>(
                title: item.name,
                subtitle: item.url,
                value: item.url,
                selected$: _selected$,
              )).toList(),
              isEditing: _isEditing,
              onDelete: (item) async {
                final urlToDelete = (item as SelectedItemModel).value;
                if (urlToDelete is! String) return;

                final servers = [..._servers$.value];
                final target = servers.where((e) => e.url == urlToDelete).firstOrNull;
                if (target == null || target.id <= 0) return;

                _repo.delete(target.id);

                // Update UI immediately
                servers.removeWhere((e) => e.url == urlToDelete);
                _servers$.safeUpdate(servers);
              },
            ),
          ],
        );
      },
    );

    return Stack(
      children: [
        Positioned.fill(child: listWidget),
        if (PlatformStyle.isUseMaterial)
          Positioned(
            bottom: 24.px,
            right: 24.px,
            child: Visibility(
              visible: !_isEditing,
              child: FloatingActionButton(
                onPressed: _addServer,
                child: const Icon(Icons.add),
              ),
            ),
          )
        else
          Positioned(
            left: CLLayout.horizontalPadding,
            right: CLLayout.horizontalPadding,
            bottom: 12.px,
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: _isEditing ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: CLButton.filled(
                  text: Localized.text('ox_usercenter.add_server'),
                  expanded: true,
                  onTap: _addServer,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.cloud, size: 56.px, color: Colors.grey),
        SizedBox(height: 12.px),
        CLText.bodyLarge(Localized.text('ox_usercenter.no_file_server')),
      ],
    );
  }

  Future<void> _addServer() async {
    final type = await _selectType();
    if (type == null) return;

    final FileServerModel? newServer = await Navigator.push<FileServerModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFileServerPage(type: type, repo: _repo),
      ),
    );

    if (newServer != null) {
      // Ensure the server is selected and synced to LoginManager
      _selected$.safeUpdate(newServer.url);

      // Immediately update list for UI so user can see without waiting stream.
      if (!_servers$.value.any((e) => e.id == newServer.id)) {
        _servers$.safeUpdate([..._servers$.value, newServer]);
      }

      // Immediately sync to LoginManager to avoid timing issues
      final circle = LoginManager.instance.currentCircle;
      if (circle != null) {
        await circle.updateSelectedFileServerUrl(newServer.url);
      }
    }
  }

  Future<FileServerType?> _selectType() async {
    return await CLPicker.show<FileServerType>(
      context: context,
      title: Localized.text('ox_usercenter.add_server'),
      items: [
        CLPickerItem(label: 'NIP-96', value: FileServerType.nip96),
        CLPickerItem(label: 'Blossom', value: FileServerType.blossom),
        CLPickerItem(label: 'MinIO', value: FileServerType.minio),
      ],
    );
  }
}