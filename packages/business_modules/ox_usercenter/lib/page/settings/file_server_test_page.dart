import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/model/file_server_model.dart';
import 'package:ox_common/upload/file_type.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/upload/void_cat.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';

/// Fixed list of servers to test. Edit here when the list changes.
final List<_TestServerEntry> _kTestServers = [
  _TestServerEntry(name: 'filedrop.besoeasy.com', url: 'https://filedrop.besoeasy.com', type: FileServerType.filedrop, isVoidCat: false),
  _TestServerEntry(name: 'mockingyou.com', url: 'https://mockingyou.com', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'pomf2.lain.la', url: 'https://pomf2.lain.la', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'nostr.build', url: 'https://nostr.build', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'nosto.re', url: 'https://nosto.re', type: FileServerType.blossom, isVoidCat: false),
  _TestServerEntry(name: 'void.cat', url: 'https://void.cat', type: FileServerType.nip96, isVoidCat: true),
  _TestServerEntry(name: 'blossom.band', url: 'https://blossom.band', type: FileServerType.blossom, isVoidCat: false),
  _TestServerEntry(name: 'nostrcheck.me', url: 'https://nostrcheck.me', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'nostrmedia.com', url: 'https://nostrmedia.com', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'files.sovbit.host', url: 'https://files.sovbit.host', type: FileServerType.nip96, isVoidCat: false),
  _TestServerEntry(name: 'nostpic.com', url: 'https://nostpic.com', type: FileServerType.nip96, isVoidCat: false),
];

class _TestServerEntry {
  final String name;
  final String url;
  final FileServerType type;
  final bool isVoidCat;
  _TestServerEntry({required this.name, required this.url, required this.type, required this.isVoidCat});
}

class _ServerTestResult {
  String? plainFileResult; // null = not run, '' = success, else error message
  String? imageResult;
}

/// Minimal 1x1 PNG bytes for image test.
final List<int> _kMinimalPngBytes = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0xF8, 0x0F, 0x00, 0x00,
  0x01, 0x01, 0x00, 0x05, 0x18, 0xD8, 0x4E, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class FileServerTestPage extends StatefulWidget {
  const FileServerTestPage({super.key});

  @override
  State<FileServerTestPage> createState() => _FileServerTestPageState();
}

class _FileServerTestPageState extends State<FileServerTestPage> {
  final Map<String, _ServerTestResult> _results = {};
  bool _testing = false;

  Future<File> _createTestFile(String name, List<int> bytes) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String> _uploadPlainFile(File file, _TestServerEntry entry) async {
    if (entry.isVoidCat) {
      try {
        final url = await VoidCatUploader.upload(file.path, fileName: 'testfile.txt');
        return url != null && url.isNotEmpty ? '' : 'No URL returned';
      } catch (e) {
        return e.toString();
      }
    }
    final server = FileServerModel(id: 0, type: entry.type, url: entry.url, name: entry.name);
    final r = await UploadUtils.uploadFile(
      file: file,
      filename: 'testfile.txt',
      fileType: FileType.text,
      fileServer: server,
      autoStoreImage: false,
    );
    return r.isSuccess ? '' : (r.errorMsg ?? 'Unknown error');
  }

  Future<String> _uploadImageFile(File file, _TestServerEntry entry) async {
    if (entry.isVoidCat) {
      try {
        final url = await VoidCatUploader.upload(file.path, fileName: 'testimage.png');
        return url != null && url.isNotEmpty ? '' : 'No URL returned';
      } catch (e) {
        return e.toString();
      }
    }
    final server = FileServerModel(id: 0, type: entry.type, url: entry.url, name: entry.name);
    final r = await UploadUtils.uploadFile(
      file: file,
      filename: 'testimage.png',
      fileType: FileType.image,
      fileServer: server,
      autoStoreImage: false,
    );
    return r.isSuccess ? '' : (r.errorMsg ?? 'Unknown error');
  }

  /// Runs plain then image upload for one server; reports each result via callbacks.
  Future<void> _testOneServer(
    _TestServerEntry entry,
    File plainFile,
    File imageFile,
    void Function(String url, String? plainErr) onPlainDone,
    void Function(String url, String? imageErr) onImageDone,
  ) async {
    final plainErr = await _uploadPlainFile(plainFile, entry);
    onPlainDone(entry.url, plainErr);

    final imageErr = await _uploadImageFile(imageFile, entry);
    onImageDone(entry.url, imageErr);
  }

  Future<void> _runTest() async {
    if (_testing) return;
    setState(() {
      _testing = true;
      _results.clear();
      for (final e in _kTestServers) {
        _results[e.url] = _ServerTestResult();
      }
    });

    final plainBytes = '0xChat file server test\n'.codeUnits;
    File? plainFile;
    File? imageFile;
    try {
      plainFile = await _createTestFile('file_server_test_plain.txt', plainBytes);
      imageFile = await _createTestFile('file_server_test_image.png', _kMinimalPngBytes);
    } catch (e) {
      if (mounted) setState(() => _testing = false);
      return;
    }

    void onPlainDone(String url, String? plainErr) {
      if (!mounted) return;
      setState(() {
        _results[url]?.plainFileResult = plainErr;
      });
    }

    void onImageDone(String url, String? imageErr) {
      if (!mounted) return;
      setState(() {
        _results[url]?.imageResult = imageErr;
      });
    }

    await Future.wait([
      for (final entry in _kTestServers)
        _testOneServer(entry, plainFile, imageFile, onPlainDone, onImageDone),
    ]);

    try {
      await plainFile.delete();
      await imageFile.delete();
    } catch (_) {}
    if (mounted) setState(() => _testing = false);
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.file_server_test_title'),
      ),
      isSectionListPage: true,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.px),
            child: CLButton.filled(
              text: Localized.text('ox_usercenter.file_server_test_start'),
              expanded: true,
              onTap: _testing ? null : _runTest,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24.px),
              itemCount: _kTestServers.length,
              itemBuilder: (context, index) {
                final entry = _kTestServers[index];
                final res = _results[entry.url];
                final plainRunning = res != null && res.plainFileResult == null && res.imageResult == null && _testing;
                final plainDone = res?.plainFileResult != null;
                final imageDone = res?.imageResult != null;
                final plainOk = plainDone && (res!.plainFileResult ?? '').isEmpty;
                final imageOk = imageDone && (res!.imageResult ?? '').isEmpty;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: CLLayout.horizontalPadding, vertical: 6.px),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12.px),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.px,
                            ),
                          ),
                          SizedBox(height: 8.px),
                          _ResultRow(
                            label: Localized.text('ox_usercenter.file_server_test_file_type_plain'),
                            running: plainRunning && !plainDone,
                            ok: plainOk,
                            error: res?.plainFileResult,
                          ),
                          SizedBox(height: 4.px),
                          _ResultRow(
                            label: Localized.text('ox_usercenter.file_server_test_file_type_image'),
                            running: plainDone && !imageDone && _testing,
                            ok: imageOk,
                            error: res?.imageResult,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.running,
    required this.ok,
    this.error,
  });

  final String label;
  final bool running;
  final bool ok;
  final String? error;

  @override
  Widget build(BuildContext context) {
    String status;
    Color color;
    if (running) {
      status = Localized.text('ox_usercenter.file_server_test_testing');
      color = Colors.grey;
    } else if (error == null) {
      status = '—';
      color = Colors.grey;
    } else if (error!.isEmpty) {
      status = Localized.text('ox_usercenter.file_server_test_result_ok');
      color = Colors.green;
    } else {
      status = '${Localized.text('ox_usercenter.file_server_test_result_fail')}: ${error!.length > 80 ? '${error!.substring(0, 80)}...' : error}';
      color = Colors.red;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72.px,
          child: Text(
            label,
            style: TextStyle(fontSize: 13.px, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            status,
            style: TextStyle(fontSize: 13.px, color: color),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
