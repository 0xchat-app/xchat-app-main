import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_image.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.px),
      child: Column(
        children: [
          CommonImage(
            iconName: 'image_home_emtyp_circle.png',
            size: 280.px,
            package: 'ox_home',
          ),

          // Title
          CLText.headlineSmall(
            Localized.text('ox_home.join_or_create_circle_now'),
          ),

          SizedBox(height: 8.px),

          // Subtitle
          CLText.titleSmall(
            Localized.text('ox_home.unlock_advanced_model'),
          ),

          SizedBox(height: 40.px),

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

          const Spacer(),
        ],
      ),
    );
  }
} 