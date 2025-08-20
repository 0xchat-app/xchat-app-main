import 'package:flutter/widgets.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_localizable/ox_localizable.dart';

abstract class ReportTarget {
  Future<String> reportAction(String reason);
}

class ReportDialog extends StatefulWidget {
  ReportDialog(this.target);

  final ReportTarget target;

  @override
  State<StatefulWidget> createState() => ReportDialogState();

  static Future<bool?> show(BuildContext context, {required ReportTarget target}) {
    return OXNavigator.pushPage(
      context,
      (_) => ReportDialog(target),
      type: OXPushPageType.present
    );
  }
}

class ReportDialogState extends State<ReportDialog> {
  List<String> modelList = [
    Localized.text('ox_chat.report_reason_spam'),
    Localized.text('ox_chat.report_reason_violence'),
    Localized.text('ox_chat.report_reason_child_abuse'),
    Localized.text('ox_chat.report_reason_pornography'),
    Localized.text('ox_chat.report_reason_copyright'),
    Localized.text('ox_chat.report_reason_illegal_drugs'),
    Localized.text('ox_chat.report_reason_personal_details'),
  ];

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_chat.message_menu_report'),
        actions: [
          CLButton.text(
            text: Localized.text('ox_common.cancel'),
            onTap: () => OXNavigator.pop(context),
          )
        ],
      ),
      body: CLSectionListView(
        items: [
          SectionListViewItem(
            header: Localized.text('ox_chat.report_reason_title'),
            data: modelList.map((value) => LabelItemModel(
              title: value,
              onTap: () => _doneButtonPressHandler(value),
            )).toList()
          ),
        ],
      ),
    );
  }

  void _doneButtonPressHandler(String reason) async {
    if (reason.isEmpty) return;

    OXLoading.show();
    final failMessage = await widget.target.reportAction(reason);
    OXLoading.dismiss();

    if (failMessage.isEmpty) {
      OXNavigator.pop(context, true);
    } else {
      CLAlertDialog.show(
        context: context,
        content: failMessage,
        actions: [
          CLAlertAction.ok(),
        ],
      );
    }
  }
}