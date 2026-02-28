import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:ox_common/repository/file_server_repository.dart';
import 'package:ox_common/utils/extension.dart';
import 'package:ox_common/utils/file_server_helper.dart';
import 'package:ox_localizable/ox_localizable.dart';

import 'add_file_server_page.dart';
import 'file_server_test_page.dart';

/// Set to true to show the "Test" entry that opens the file server test page.
const bool _showFileServerTestEntry = false;

/// File Server Settings page.
/// When [readOnlyForPaidCircle] is true, only the current circle's file server (S3) is shown
/// and the page is read-only (no add/edit/delete/selection).
class FileServerPage extends StatefulWidget {
  const FileServerPage({
    super.key,
    this.previousPageTitle,
    this.readOnlyForPaidCircle = false,
  });

  final String? previousPageTitle;

  /// When true, only show the circle's file server info (for paid circles) and disable management.
  final bool readOnlyForPaidCircle;

  @override
  State<FileServerPage> createState() => _FileServerPageState();
}

class _FileServerPageState extends State<FileServerPage> {
  final ValueNotifier<List<FileServerModel>> _servers$ =
  ValueNotifier<List<FileServerModel>>([]);
  // Holds selected server relay URL.
  final ValueNotifier<String?> _selected$ = ValueNotifier(null);
  bool _isEditing = false;
  FileServerRepository? _repo;

  /// Subscription for the repo stream, used to cancel listening when the page is disposed.
  StreamSubscription<List<FileServerModel>>? _repoSub;

  // Holds the url selected in circle config before servers list is loaded.
  String? _pendingSelectedUrl;

  String get _title => Localized.text('ox_usercenter.file_server_setting');

  @override
  void initState() {
    super.initState();

    if (widget.readOnlyForPaidCircle) {
      _loadCircleFileServerForDisplay();
    } else {
      prepareData();
      _loadInitialSelection();
      addListener();
    }
  }

  void prepareData() {
    _repo = FileServerRepository(DBISAR.sharedInstance.isar);
    final fileServers = _repo!.fetch();
    _servers$.value = fileServers;

    final selectedFileServerUrl = LoginManager.instance.currentCircle?.selectedFileServerUrl;
    // Empty string means the default file server group is selected.
    _selected$.value = selectedFileServerUrl ?? '';
  }

  Future<void> _loadCircleFileServerForDisplay() async {
    final server = await FileServerHelper.getCircleFileServerForDisplay();
    if (!mounted) return;
    _servers$.value = server != null ? [server] : [];
  }

  void _loadInitialSelection() {
    final circle = LoginManager.instance.currentCircle;
    if (circle == null) return;
    if (circle.selectedFileServerUrl.isNotEmpty) {
      _pendingSelectedUrl = circle.selectedFileServerUrl;
    }
  }

  void addListener() {
    if (_repo == null) return;
    // Listen list changes
    _repoSub = _repo!.watchAll().listen((servers) {

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
        // If not found (e.g. deleted), fallback to default group.
        if (matched != null) {
          _selected$.safeUpdate(matched.url);
        } else {
          _selected$.safeUpdate('');
        }
        _pendingSelectedUrl = null;
      }

      // If current custom selection has been removed, fallback to default group.
      final selectedUrl = _selected$.value;
      if (selectedUrl != null && selectedUrl.isNotEmpty) {
        final isSelected = servers.any((e) => e.url == selectedUrl);
        if (!isSelected) {
          _selected$.safeUpdate('');
        }
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
    _repoSub?.cancel();
    _servers$.dispose();
    _selected$.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidget = _buildBody(context);
    final isReadOnly = widget.readOnlyForPaidCircle;

    return CLScaffold(
      appBar: CLAppBar(
        title: _title,
        previousPageTitle: widget.previousPageTitle,
        actions: isReadOnly
            ? const []
            : [
                if (_showFileServerTestEntry)
                  CLButton.text(
                    text: Localized.text('ox_usercenter.file_server_test_short'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FileServerTestPage(),
                      ),
                    ),
                  ),
                CLButton.text(
                  text: _isEditing ? Localized.text('ox_common.complete') : Localized.text('ox_usercenter.edit'),
                  onTap: () => setState(() => _isEditing = !_isEditing),
                ),
              ],
      ),
      isSectionListPage: true,
      body: bodyWidget,
      bottomWidget: isReadOnly
          ? null
          : AnimatedOpacity(
              opacity: _isEditing ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: CLButton.filled(
                text: Localized.text('ox_usercenter.add_server'),
                expanded: true,
                onTap: _addServer,
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.readOnlyForPaidCircle) {
      return ValueListenableBuilder<List<FileServerModel>>(
        valueListenable: _servers$,
        builder: (_, List<FileServerModel> list, __) {
          final data = list.isEmpty
              ? [
                  LabelItemModel(
                    title: Localized.text('ox_usercenter.file_server_info_empty'),
                  ),
                ]
              : list
                  .map((item) => LabelItemModel(
                        icon: ListViewIcon.data(CupertinoIcons.doc_fill),
                        title: item.name,
                        subtitle: item.url,
                        onTap: null,
                      ))
                  .toList();
          return CLSectionListView(
            items: [
              SectionListViewItem(
                data: data,
                isEditing: false,
              ),
            ],
          );
        },
      );
    }

    final listWidget = ValueListenableBuilder(
      valueListenable: _servers$,
      builder: (_, List<FileServerModel> list, __) {
        final defaultGroupItem = SelectedItemModel<String?>(
          title: Localized.text('ox_usercenter.default_file_server_group'),
          subtitle: Localized.text('ox_usercenter.default_file_server_group_subtitle'),
          value: '',
          selected$: _selected$,
        );

        final customItems = list
            .map((item) => SelectedItemModel<String?>(
                  title: item.name,
                  subtitle: item.url,
                  value: item.url,
                  selected$: _selected$,
                ))
            .toList();

        final sections = <SectionListViewItem>[
          SectionListViewItem(
            data: [defaultGroupItem],
            isEditing: false,
          ),
          if (customItems.isNotEmpty)
            SectionListViewItem(
              data: customItems,
              isEditing: _isEditing,
              onDelete: (item) async {
                final urlToDelete = (item as SelectedItemModel).value;
                if (urlToDelete is! String) return;

                final servers = [..._servers$.value];
                final target = servers.where((e) => e.url == urlToDelete).firstOrNull;
                if (target == null || target.id <= 0) return;

                _repo?.delete(target.id);

                // Update UI immediately
                servers.removeWhere((e) => e.url == urlToDelete);
                _servers$.safeUpdate(servers);
              },
            ),
        ];

        return CLSectionListView(
          items: sections,
        );
      },
    );

    return listWidget;
  }

  Future<void> _addServer() async {
    if (_repo == null) return;
    final type = await _selectType();
    if (type == null) return;

    final FileServerModel? newServer = await Navigator.push<FileServerModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFileServerPage(type: type, repo: _repo!),
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