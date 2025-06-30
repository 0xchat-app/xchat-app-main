import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/login/login_manager.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';
import 'package:ox_common/widgets/avatar.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_common/utils/ping_utils.dart';

class CircleItem {
  CircleItem({
    required this.id,
    required this.name,
    this.iconUrl = '',
    required this.relayUrl,
  });

  final String id;
  final String name;
  final String iconUrl;
  final String relayUrl;
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
  }) {
    _initializeLatencyMeasurement();
  }

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

  // Cache for measured latency of relay URLs
  final Map<String, ValueNotifier<String>> _latencyCache = {};
  Timer? _latencyTimer;
  Duration _measurementInterval = const Duration(minutes: 1);

  void _startMeasureLatency(String url) {
    if (_latencyCache.containsKey(url)) return;
    final notifier = ValueNotifier<String>('--');
    _latencyCache[url] = notifier;

    // initial measure
    _measureLatency(url);
  }

  void _measureLatency(String url) async {
    final host = Uri.parse(url).host.isNotEmpty
        ? Uri.parse(url).host
        : url.replaceAll(RegExp(r'^(wss?:\/\/)?'), '').split('/').first;

    final latency = await PingUtils.ping(host);
    final notifier = _latencyCache[url]!;
    notifier.value = latency != null ? '$latency' : '--';
  }

  void _initializeLatencyMeasurement() {
    // Listen to list expand/collapse status and adjust interval.
    isShowExtendBody$.addListener(_updateTimerInterval);
    // When selected circle changes, trigger immediate measure.
    selectedCircle$.addListener(() {
      final current = selectedCircle$.value;
      if (current != null) {
        _startMeasureLatency(current.relayUrl);
      }
    });
    _updateTimerInterval();
  }

  void _updateTimerInterval() {
    final desired = isShowExtendBody$.value
        ? const Duration(seconds: 5)
        : const Duration(minutes: 1);

    if (_measurementInterval == desired && _latencyTimer != null) return;

    _measurementInterval = desired;
    _latencyTimer?.cancel();
    _latencyTimer = Timer.periodic(_measurementInterval, (_) => _measureAll());
  }

  void _measureAll() {
    final circle = selectedCircle$.value;
    if (circle == null) return;
    _measureLatency(circle.relayUrl);
  }

  AppBar buildAppBar(BuildContext ctx) => AppBar(
    leadingWidth: 280.px,
    leading: ValueListenableBuilder(
      valueListenable: LoginManager.instance.state$,
      builder: (_, __, ___) {
        return Row(
          children: [
            _buildAvatar(),
            Expanded(child: _buildCircleName()),
          ],
        );
      }
    ),
    actions: [
      if (PlatformStyle.isUseMaterial)
        CLButton.icon(
          iconName: 'icon_common_search.png',
          package: 'ox_common',
          iconSize: 24.px,
          onTap: onSearchTap,
        ),
      CLButton.icon(
        iconName: PlatformStyle.isUseMaterial
            ? 'icon_common_add.png'
            : 'icon_common_add_cupertino.png',
        package: 'ox_common',
        iconSize: 24.px,
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

  Widget _buildCircleName() {
    return ValueListenableBuilder(
      valueListenable: selectedCircle$,
      builder: (_, selectedCircle, __) {
        return GestureDetector(
          onTap: circles.isNotEmpty ? nameOnTap : null,
          child: Row(
            children: [
              Flexible(
                child: CLText.titleLarge(
                  selectedCircle?.name ?? '',
                  maxLines: 1,
                ),
              ),
              if (circles.isNotEmpty)
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
    final selected = item.id == selectedCircle?.id;

    // Ensure notifier exists
    final latency$ = _latencyCache.putIfAbsent(item.relayUrl, () => ValueNotifier<String>('--'));

    // Only measure latency for selected circle
    if (selected) {
      _startMeasureLatency(item.relayUrl);
    }

    return CustomItemModel(
      leading: CircleAvatar(
        child: Text(item.name[0]),
      ),
      titleWidget: CLText(item.name),
      subtitleWidget: ValueListenableBuilder(
        valueListenable: latency$,
        builder: (_, latencyStr, __) {
          final msText = latencyStr;
          return Text.rich(
            TextSpan(
              children: [
                if (selected)
                  TextSpan(text: '$msText ms · '),
                TextSpan(text: item.relayUrl),
              ],
            ),
          );
        },
      ),
      trailing: CLRadio(
        value: item.id,
        groupValue: selectedCircle?.id,
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
              text: Localized.text('ox_home.add_circle'),
              onTap: joinOnTap,
            ),
          ),
          // SizedBox(width: 10.px,),
          // Expanded(
          //   child: CLButton.tonal(
          //     padding: EdgeInsets.symmetric(vertical: 12.px),
          //     text: Localized.text('ox_home.new_paid_circle'),
          //     onTap: paidOnTap,
          //   ),
          // ),
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