
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/ox_userinfo_manager.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';

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

class HomeHeaderComponents {
  HomeHeaderComponents({
    required this.circles,
    required this.selectedCircle$,
    this.onCircleSelected,
    this.avatarOnTap,
    this.nameOnTap,
    this.addOnTap,
    this.joinOnTap,
    this.paidOnTap,
    required this.isShowExtendBody$,
    required this.extendBodyDuration,
  });

  /// List of circle items for the sub-bar
  final List<CircleItem> circles;
  /// Currently selected circle value
  final ValueNotifier<CircleItem?> selectedCircle$;
  /// Called when a circle is selected
  final ValueChanged<CircleItem>? onCircleSelected;

  GestureTapCallback? avatarOnTap;
  GestureTapCallback? nameOnTap;
  GestureTapCallback? addOnTap;
  GestureTapCallback? joinOnTap;
  GestureTapCallback? paidOnTap;

  LoginUserNotifier user = LoginUserNotifier.instance;
  ValueNotifier<bool> isShowExtendBody$;
  Duration extendBodyDuration;

  AppBar buildAppBar(BuildContext ctx) => AppBar(
    leadingWidth: 280.px,
    leading: Row(
      children: [
        _buildAvatar(),
        Expanded(child: _buildUserName()),
      ],
    ),
    actions: [
      if (PlatformStyle.isUseMaterial)
        CLButton.icon(
          iconName: 'icon_common_search.png',
          package: 'ox_common',
          size: 48.px,
          onTap: onSearchTap,
        ),
      CLButton.icon(
        iconName: 'icon_common_add.png',
        package: 'ox_common',
        size: 48.px,
        onTap: addOnTap,
      ).setPaddingOnly(right: 4.px),
    ],
    backgroundColor: ColorToken.surface.of(ctx),
  );

  Widget _buildAvatar() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: avatarOnTap,
      child: Padding(
        padding: EdgeInsets.all(12.px),
        child: ValueListenableBuilder(
          valueListenable: user.avatarUrl$,
          builder: (_, avatarUrl, __) {
            return OXUserAvatar(
              imageUrl: avatarUrl,
              size: 32.px,
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return GestureDetector(
      onTap: nameOnTap,
      child: Row(
        children: [
          Flexible(
            child: ValueListenableBuilder(
              valueListenable: user.name$,
              builder: (_, name, __) {
                return CLText.titleLarge(
                  name,
                  maxLines: 1,
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: isShowExtendBody$,
            builder: (context, isShowExtendBody, _) {
              return AnimatedRotation(
                turns: isShowExtendBody ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: ColorToken.onSurface.of(context),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget buildCircleList(BuildContext ctx) => Container(
    decoration: BoxDecoration(
      color: ColorToken.surface.of(ctx),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 36.px,
            alignment: Alignment.centerLeft,
            child: CLText.titleSmall('Circles').setPaddingOnly(left: 16.px)
        ),
        ValueListenableBuilder(
          valueListenable: selectedCircle$,
          builder: (context, selectedCircle, __) {
            return CLListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              items: circles.map((circle) =>
                  _circleItemListTileMapper(circle, selectedCircle)).toList(),
            );
          }
        ),
        _buildOptionButtons(),
      ],
    ),
  );

  ListViewItem _circleItemListTileMapper(CircleItem item, CircleItem? selectedCircle) {
    final selected = item == selectedCircle;
    return CustomItemModel(
      leading: CircleAvatar(
        child: Text(item.name[0]),
      ),
      titleWidget: CLText(item.name),
      subtitleWidget: Text.rich(
          TextSpan(
              children: [
                if (selected)
                  const TextSpan(text: '--ms · '),
                TextSpan(text: item.relayUrl),
              ]
          )
      ),
      trailing: CLRadio(
        value: item,
        groupValue: selectedCircle,
      ),
      onTap: () => onCircleSelected?.call(item),
    );
  }

  Widget _buildOptionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.px,
        vertical: 12.px,
      ),
      child: Row(
        children: [
          Expanded(
            child: CLButton.filled(
              padding: EdgeInsets.symmetric(vertical: 12.px),
              text: Localized.text('ox_home.join_circle'),
              onTap: joinOnTap,
            ),
          ),
          SizedBox(width: 10.px,),
          Expanded(
            child: CLButton.tonal(
              padding: EdgeInsets.symmetric(vertical: 12.px),
              text: Localized.text('ox_home.new_paid_circle'),
              onTap: paidOnTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMask() => ValueListenableBuilder(
    valueListenable: isShowExtendBody$,
    builder: (_, isShowExtendBody, __) {
      return IgnorePointer(
        ignoring: !isShowExtendBody,
        child: AnimatedOpacity(
          opacity: isShowExtendBody ? 1 : 0,
          duration: extendBodyDuration,
          child: GestureDetector(
            onTap: () {
              isShowExtendBody$.value = false;
            },
            child: Container(
              height: Adapt.screenH,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      );
    },
  );

  void onSearchTap() {

  }
}