import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/upload/upload_utils.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/upload/minio_uploader.dart';
import 'package:ox_common/upload/nip96_info_loader.dart';
import 'package:ox_common/upload/nip96_server_adaptation.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_common/widgets/common_loading.dart';

import '../../model/file_server_model.dart';
import '../../repository/file_server_repository.dart';

class AddFileServerPage extends StatefulWidget {
  const AddFileServerPage({super.key, required this.type, required this.repo});

  final FileServerType type;
  final FileServerRepository repo;

  @override
  State<AddFileServerPage> createState() => _AddFileServerPageState();
}

class _AddFileServerPageState extends State<AddFileServerPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _accessCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _bucketCtrl = TextEditingController();
  final _pubkeyCtrl = TextEditingController();

  String get _title {
    switch (widget.type) {
      case FileServerType.nip96:
        return Localized.text('ox_usercenter.add_nip96_server');
      case FileServerType.blossom:
        return Localized.text('ox_usercenter.add_blossom_server');
      case FileServerType.minio:
        return Localized.text('ox_usercenter.add_minio_server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: _title,
        autoTrailing: false,
      ),
      isSectionListPage: true,
      body: LoseFocusWrap(_buildBody()),
    );
  }

  Widget _buildBody() {
    List<Widget> rows = _buildFields();
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              if (PlatformStyle.isUseMaterial)
                ...rows
              else
                Form(
                  key: _formKey,
                  child: CupertinoListSection.insetGrouped(
                    additionalDividerMargin: 5,
                    children: rows,
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.px,
              right: 16.px,
              bottom: 12.px,
            ),
            child: CLButton.filled(
              text: Localized.text('ox_common.complete'),
              expanded: true,
              onTap: _submit,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFields() {
    List<Widget> widgets = [];

    widgets.add(_buildTextFormField(
      controller: _urlCtrl,
      label: Localized.text('ox_usercenter.url'),
      validator: _validateUrl,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
    ));

    switch (widget.type) {
      case FileServerType.blossom:
        widgets.add(_buildTextFormField(
          controller: _pubkeyCtrl,
          label: Localized.text('ox_usercenter.pubkey'),
          validator: _validateNotEmpty,
          textInputAction: TextInputAction.next,
        ));
        break;
      case FileServerType.minio:
        widgets.addAll([
          _buildTextFormField(
            controller: _accessCtrl,
            label: Localized.text('ox_usercenter.access_key'),
            validator: _validateNotEmpty,
            textInputAction: TextInputAction.next,
          ),
          _buildTextFormField(
            controller: _secretCtrl,
            label: Localized.text('ox_usercenter.secret_key'),
            validator: _validateNotEmpty,
            textInputAction: TextInputAction.next,
          ),
          _buildTextFormField(
            controller: _bucketCtrl,
            label: Localized.text('ox_usercenter.bucket_name'),
            validator: _validateNotEmpty,
            textInputAction: TextInputAction.next,
          ),
        ]);
        break;
      case FileServerType.nip96:
        break;
    }

    widgets.add(_buildTextFormField(
      controller: _nameCtrl,
      label: Localized.text('ox_usercenter.custom_name'),
      validator: null,
      requiredField: false,
      textInputAction: TextInputAction.done,
    ));

    return widgets;
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool requiredField = true,
    TextInputAction? textInputAction,
  }) {
    if (PlatformStyle.isUseMaterial) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.px),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          validator: requiredField ? (validator ?? _validateNotEmpty) : validator,
          keyboardType: keyboardType,
        ),
      );
    } else {
      return CupertinoTextFormFieldRow(
        prefix: CLText.titleMedium(
          label,
          colorToken: ColorToken.onSurface,
        ),
        controller: controller,
        validator: requiredField ? (validator ?? _validateNotEmpty) : validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textAlign: TextAlign.end,
      );
    }
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return Localized.text('ox_common.required');
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return Localized.text('ox_common.required');
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (!uri.hasScheme)) {
      return Localized.text('ox_common.invalid_url_format');
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _urlCtrl.text.trim();
    final name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : url;

    try {
      OXLoading.show();

      switch (widget.type) {
        case FileServerType.minio:
          final access = _accessCtrl.text.trim();
          final secret = _secretCtrl.text.trim();
          final bucket = _bucketCtrl.text.trim();

          bool exists = await MinioUploader.init(
            url: url,
            accessKey: access,
            secretKey: secret,
            bucketName: bucket,
          ).bucketExists();
          if (!exists) {
            _showError(Localized.text('ox_usercenter.str_bucket__name_tips_text'));
            return;
          }
          break;
        case FileServerType.nip96:
          Nip96ServerAdaptation? result = await NIP96InfoLoader.getInstance().pullServerAdaptation(url);
          if (result == null || result.apiUrl == null) {
            _showError(Localized.text('ox_usercenter.str_nip96_tips_text'));
            return;
          }
          break;
        case FileServerType.blossom:
          // Basic URL validation already done.
          break;
      }

      final model = FileServerModel(
        type: widget.type,
        url: url,
        name: name,
        accessKey: _accessCtrl.text.trim(),
        secretKey: _secretCtrl.text.trim(),
        bucketName: _bucketCtrl.text.trim(),
        pubkey: _pubkeyCtrl.text.trim(),
      );

      await widget.repo.create(model);
      if (!mounted) return;
      Navigator.pop(context, model);
    } catch (e) {
      UploadResult result = UploadExceptionHandler.handleException(e);
      _showError(result.errorMsg ?? 'Minio Error');
    } finally {
      OXLoading.dismiss();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    CommonToast.instance.show(context, message);
  }
} 