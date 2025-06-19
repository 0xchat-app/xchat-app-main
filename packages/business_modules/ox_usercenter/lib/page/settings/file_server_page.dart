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
  final ValueNotifier<FileServerModel?> _selected$ = ValueNotifier(null);
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
    _repo = FileServerRepository(DBISAR.sharedInstance.isar);

    _loadInitialSelection();

    // Listen list changes
    _repoSub = _repo.watchAll().listen((event) {
      if (!mounted) return; // 防止页面释放后仍尝试更新已释放的 ValueNotifier

      _servers$.safeUpdate(event);

      // Apply pending selection from circle config once list is available.
      if (_pendingSelectedUrl != null) {
        FileServerModel? matched;
        for (final fs in event) {
          if (fs.url == _pendingSelectedUrl) {
            matched = fs;
            break;
          }
        }
        matched ??= event.isNotEmpty ? event.first : null;

        if (matched != null) {
          _selected$.value = matched;
        }
        _pendingSelectedUrl = null;
      }

      // If current selection has been removed, select the first available one.
      if (_selected$.value != null &&
          !event.any((e) => e.id == _selected$.value!.id)) {
        _selected$.value = event.isNotEmpty ? event.first : null;
      }
    });

    // Listen to selection changes and persist into circle config.
    _selected$.addListener(() {
      final sel = _selected$.value;
      final circle = LoginManager.instance.currentCircle;
      circle?.updateSelectedFileServerUrl(sel?.url ?? '');
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
      builder: (_, list, __) {
        if (list.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 220.py),
            child: _buildEmptyBody(),
          );
        }

        return CLSectionListView(
          items: [
            SectionListViewItem(
              data: list.map((item) => SelectedItemModel(
                title: item.name,
                subtitle: item.url,
                value: item,
                selected$: _selected$,
              )).toList(),
              isEditing: _isEditing,
              onDelete: (item) async {
                final modelToDelete = (item as SelectedItemModel).value;
                await _repo.delete(modelToDelete.id);
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
            left: 16.px,
            right: 16.px,
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
  }

  Future<void> _loadInitialSelection() async {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) return;
    if (circle.selectedFileServerUrl.isNotEmpty) {
      _pendingSelectedUrl = circle.selectedFileServerUrl;
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