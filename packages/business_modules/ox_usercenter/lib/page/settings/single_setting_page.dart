
import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_localizable/ox_localizable.dart';

class SingleSettingPage extends StatelessWidget {
  SingleSettingPage({
    super.key,
    this.previousPageTitle,
    this.title,
    this.initialValue = '',
    required this.saveAction,
  });

  final String? previousPageTitle;
  final String? title;
  final String initialValue;

  final Function(BuildContext ctx, String value) saveAction;

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = initialValue;
    controller.selection = TextSelection.collapsed(offset: initialValue.length);
    return CLScaffold(
      appBar: CLAppBar(
        title: title,
        previousPageTitle: previousPageTitle,
        autoTrailing: false,
        actions: [
          if (!PlatformStyle.isUseMaterial)
            CLButton.text(
              text: 'Save',
              onTap: () => saveAction(context, controller.text),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.px,
            vertical: 12.px,
          ),
          children: [
            CLTextField(
              controller: controller,
              autofocus: true,
              placeholder: title,
            ),
            SizedBox(height: 20.px,),
            if (PlatformStyle.isUseMaterial)
              CLButton.filled(
                padding: EdgeInsets.symmetric(vertical: 12.px),
                text: Localized.text('ox_common.save'),
                onTap: () => saveAction(context, controller.text),
              )
          ],
        ),
      ),
    );
  }
}