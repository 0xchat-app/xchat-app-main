

import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/list_extension.dart';
import 'package:ox_common/widgets/common_image.dart';

class InputMoreItem {
  const InputMoreItem({required this.id, required this.title, required this.iconName, required this.action,});
  final String id;
  final String Function() title;
  final String iconName;
  final Function(BuildContext context) action;
}

class InputMoreEmptyItem extends InputMoreItem {
  InputMoreEmptyItem() : super(id: '', title: () => '', iconName: '', action: (_) {});
}

class InputMorePage extends StatefulWidget {
  const InputMorePage({super.key, required this.items});

  final List<InputMoreItem> items;

  @override
  State<InputMorePage> createState() => _InputMorePageState();
}

class _InputMorePageState extends State<InputMorePage> {

  int crossCount = 4;
  int rowCount = 2;

  double get iconSize => 56.px;
  EdgeInsets get iconPadding => EdgeInsets.only(
    bottom: 4.px,
    left: 10.px,
    right: 10.px,
  );

  double get runSpacing => 16.px;

  late List<InputMoreItem> items;

  @override
  void initState() {
    super.initState();

    final maxCount = crossCount * rowCount;
    assert(widget.items.length <= maxCount);

    items = [
      ...widget.items,
      ...List.generate(maxCount - widget.items.length, (_) => InputMoreEmptyItem())
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = items.chunk(crossCount);
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 26.px,
        vertical: 12.px,
      ),
      itemBuilder: (_, index) {
        final items = data[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) => itemBuilder(item)).toList(),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: runSpacing,),
      itemCount: data.length,
    );
  }

  Widget itemBuilder(InputMoreItem item) {
    if (item is InputMoreEmptyItem) return emptyItemBuilder();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorToken.onSecondary.of(context),
            ),
            margin: iconPadding,
            alignment: Alignment.center,
            child: CommonImage(
              iconName: item.iconName,
              size: 24.px,
              package: 'ox_chat_ui',
            ),
          ),
          SizedBox(
            width: iconSize + iconPadding.horizontal,
            child: CLText.bodyMedium(
              item.title(),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
      onTap: () => item.action(context),
    );
  }

  Widget emptyItemBuilder() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: iconSize,
        height: iconSize,
        margin: iconPadding,
      ),
      SizedBox(
        width: iconSize + iconPadding.horizontal,
        child: CLText.bodyMedium(
          '',
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    ],
  );
}
