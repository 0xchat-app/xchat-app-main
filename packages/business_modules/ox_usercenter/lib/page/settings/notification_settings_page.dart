import 'package:flutter/widgets.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_loading.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/push/push_notification_manager.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({
    super.key,
    this.previousPageTitle,
  });

  final String? previousPageTitle;

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(
        title: Localized.text('ox_usercenter.notification'),
        previousPageTitle: widget.previousPageTitle,
      ),
      isSectionListPage: true,
      body: CLSectionListView(
        items: [
          SectionListViewItem(data: [
            SwitcherItemModel(
              icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
              title: Localized.text('ox_usercenter.allow_send_notification'),
              subtitle: Localized.text('ox_usercenter.allow_send_notification_tips'),
              value$: CLPushNotificationManager.instance.allowSendNotificationNotifier,
              onChanged: (value) async {
                OXLoading.show();
                await CLPushNotificationManager.instance.setAllowSendNotification(value);
                OXLoading.dismiss();
              },
            ),
            SwitcherItemModel(
              icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
              title: Localized.text('ox_usercenter.allow_receive_notification'),
              subtitle: Localized.text('ox_usercenter.allow_receive_notification_tips'),
              value$: CLPushNotificationManager.instance.allowReceiveNotificationNotifier,
              onChanged: (value) async {
                OXLoading.show();
                final isSuccess = await CLPushNotificationManager.instance.setAllowReceiveNotification(
                  value,
                );
                OXLoading.dismiss();
                if (!isSuccess) {
                  CommonToast.instance.show(
                    context, 
                    Localized.text('ox_usercenter.notification_setting_failed'),
                  );
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}
