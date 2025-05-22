import 'package:flutter/material.dart';

import 'package:chatcore/chat-core.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';

class HomeHeaderBar extends StatefulWidget {
  /// Title of the hub (dropdown text)
  final UserDBISAR? user;

  /// Callback when the hub dropdown is tapped
  final VoidCallback? onHubTap;

  /// Callback when avatar is tapped
  final VoidCallback? onAvatarTap;

  /// Callback when search icon is tapped
  final VoidCallback? onSearchTap;

  /// Callback when add icon is tapped
  final VoidCallback? onAddTap;

  final VoidCallback? onJoinTap;
  final VoidCallback? onPaidTap;

  /// List of circle items for the sub-bar
  final List<CircleItem> circles;

  /// Currently selected circle value
  final CircleItem? selectedCircle;

  /// Called when a circle is selected
  final ValueChanged<CircleItem>? onCircleSelected;

  static double get height => 64.px;

  const HomeHeaderBar({
    Key? key,
    required this.user,
    this.onHubTap,
    this.onAvatarTap,
    this.onSearchTap,
    this.onAddTap,
    this.onJoinTap,
    this.onPaidTap,
    this.circles = const [],
    this.selectedCircle,
    this.onCircleSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeHeaderBarState();
}

class HomeHeaderBarState extends State<HomeHeaderBar> with TickerProviderStateMixin {

  List<CircleItem> get circles => widget.circles;

  bool isShowCircleList = false;

  Duration get animationDuration => const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMainBar(),
        ClipRect(
          child: Stack(
            children: [
              buildMask(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  offset: isShowCircleList ? Offset.zero : Offset(0, -1),
                  duration: animationDuration,
                  child: buildCircleList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMainBar() {
    return Container(
      color: ColorToken.surface.of(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: HomeHeaderBar.height,
            child: Row(
              children: [
                buildAvatar().setPaddingOnly(right: 4.px),
                Expanded(child: buildUserName()),
                CLButton.icon(
                  iconName: 'icon_common_search.png',
                  package: 'ox_common',
                  size: 48.px,
                  onTap: widget.onSearchTap,
                ),
                CLButton.icon(
                  iconName: 'icon_common_add.png',
                  package: 'ox_common',
                  size: 48.px,
                  onTap: widget.onAddTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUserName() {
    return GestureDetector(
      onTap: toggle,
      child: SizedBox(
        height: double.infinity,
        child: Row(
          children: [
            CLText.titleLarge(
              widget.user?.name ?? '',
            ),
            Icon(
              Icons.arrow_drop_down,
              color: ColorToken.onSurface.of(context),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
  
  Widget buildAvatar() {
    return GestureDetector(
      onTap: widget.onAvatarTap,
      child: Padding(
        padding: EdgeInsets.all(8.px),
        child: OXUserAvatar(
          user: widget.user,
        ),
      ),
    );
  }

  Widget buildCircleList() {
    return Container(
      decoration: BoxDecoration(
        color: ColorToken.surface.of(context),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36.px,
            alignment: Alignment.centerLeft,
            child: CLText.titleSmall('Circles').setPaddingOnly(left: 16.px)
          ),
          CLListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            items: circles.map((circle) => circleItemListTileMapper(circle)).toList(),
          ),
          buildOptionButtons(),
        ],
      ),
    );
  }

  Widget buildMask() {
    return IgnorePointer(
      ignoring: !isShowCircleList,
      child: AnimatedOpacity(
        opacity: isShowCircleList ? 1 : 0,
        duration: animationDuration,
        child: GestureDetector(
          onTap: toggle,
          child: Container(
            height: Adapt.screenH,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  ListViewItem circleItemListTileMapper(CircleItem item) {
    final selected = item == widget.selectedCircle;
    return CustomItemModel(
      leading: CircleAvatar(
        child: Text(item.name[0]),
      ),
      titleWidget: CLText(item.name),
      subtitleWidget: Text.rich(
        TextSpan(
          children: [
            if (selected)
              TextSpan(text: '--ms · '),
            TextSpan(text: item.relayUrl),
          ]
        )
      ),
      trailing: CLRadio(
        value: item,
        groupValue: widget.selectedCircle,
      ),
      onTap: () => widget.onCircleSelected?.call(item),
    );
  }

  Widget buildOptionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.px,
        vertical: 12.px,
      ),
      child: Row(
        children: [
          Expanded(
            child: CLButton.filled(
              height: 48.px,
              padding: EdgeInsets.zero,
              text: 'Join or Create Circle',
              onTap: widget.onJoinTap,
            ),
          ),
          SizedBox(width: 10.px,),
          Expanded(
            child: CLButton.tonal(
              height: 48.px,
              padding: EdgeInsets.zero,
              text: 'New Paid Circle',
              onTap: widget.onPaidTap,
            ),
          ),
        ],
      ),
    );
  }
  
  void toggle() {
    setState(() {
      isShowCircleList = !isShowCircleList;
    });
  }
}

/// Model for a circle item in the sub-bar
class CircleItem {
  CircleItem({
    required this.name,
    required this.level,
    required this.relayUrl,
    this.owner = '',
  });

  final String name;
  final int level;
  final String relayUrl;
  final String owner;
}
