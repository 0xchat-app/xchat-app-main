import 'message_models.dart';

class NotificationPolicyConfig {
  final Duration coalesceWindow;     // aggregation window
  final PreviewPolicy previewPolicy; // lockscreen preview policy
  const NotificationPolicyConfig({
    this.coalesceWindow = const Duration(seconds: 2),
    this.previewPolicy = PreviewPolicy.summary,
  });
}