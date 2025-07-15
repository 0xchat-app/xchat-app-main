import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';
import 'package:ox_common/page/circle_introduction_page.dart';
import 'package:ox_localizable/ox_localizable.dart';

class CircleEmptyWidget extends StatelessWidget {
  final VoidCallback? onJoinCircle;
  final VoidCallback? onCreatePaidCircle;

  const CircleEmptyWidget({
    Key? key,
    this.onJoinCircle,
    this.onCreatePaidCircle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
        return Transform.translate(
      offset: Offset(0, -120.px),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.px),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
          children: [
          // Empty state icon using Material Icons
          Icon(
            Icons.forum_outlined,
            size: 120.px,
            color: PlatformStyle.isUseMaterial
                ? Theme.of(context).textTheme.titleMedium?.color
                : CupertinoTheme.of(context).textTheme.actionSmallTextStyle?.color,
          ),

          SizedBox(height: 24.px),

          // Title
          CLText.headlineSmall(
            Localized.text('ox_home.join_or_create_circle_now'),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.px),

          // Subtitle
          CLText.titleSmall(
            Localized.text('ox_home.unlock_advanced_model'),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.px),

          // Circle Introduction Button
          GestureDetector(
            onTap: () => _showCircleIntroduction(context),
            child: CLText.labelMedium(
              Localized.text('ox_home.what_is_circle'),
              colorToken: ColorToken.primary,
            ),
          ),

          SizedBox(height: 20.px),

          // Join Circle Button
          CLButton.filled(
            text: Localized.text('ox_home.join_circle'),
            onTap: onJoinCircle,
            expanded: true,
            height: 52.px,
          ),

          SizedBox(height: 16.px),

          // New Paid Circle Button
          // CLButton.tonal(
          //   text: Localized.text('ox_home.new_paid_circle'),
          //   onTap: onCreatePaidCircle,
          //   expanded: true,
          //   height: 52.px,
          // ),
        ],
        ),
      ),
        ),
    );
  }

  /// Show Circle introduction page
  void _showCircleIntroduction(BuildContext context) {
    OXNavigator.pushPage(
      context,
      (context) => const CircleIntroductionPage(),
      type: OXPushPageType.present,
    );
  }
} 