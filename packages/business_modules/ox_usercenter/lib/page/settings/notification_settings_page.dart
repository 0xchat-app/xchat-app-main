import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:chatcore/chat-core.dart';

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
  late ValueNotifier<bool> allowSendNotificationNty;
  late ValueNotifier<bool> allowReceiveNotificationNty;

  @override
  void initState() {
    super.initState();
    
    // Initialize notification settings from NotificationHelper
    final notificationHelper = NotificationHelper.sharedInstance;
    allowSendNotificationNty = ValueNotifier<bool>(notificationHelper.allowSendNotification);
    allowReceiveNotificationNty = ValueNotifier<bool>(notificationHelper.allowReceiveNotification);
    
    // Add listeners to update NotificationHelper when settings change
    allowSendNotificationNty.addListener(() {
      notificationHelper.setAllowSendNotification(allowSendNotificationNty.value);
    });
    
    allowReceiveNotificationNty.addListener(() {
      notificationHelper.setAllowReceiveNotification(allowReceiveNotificationNty.value);
    });
  }

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
              value$: allowSendNotificationNty,
            ),
            SwitcherItemModel(
              icon: ListViewIcon(iconName: 'icon_setting_notification.png', package: 'ox_usercenter'),
              title: Localized.text('ox_usercenter.allow_receive_notification'),
              subtitle: Localized.text('ox_usercenter.allow_receive_notification_tips'),
              value$: allowReceiveNotificationNty,
            ),
          ]),
        ],
      ),
    );
  }

  @override
  void dispose() {
    allowSendNotificationNty.dispose();
    allowReceiveNotificationNty.dispose();
    super.dispose();
  }
}
