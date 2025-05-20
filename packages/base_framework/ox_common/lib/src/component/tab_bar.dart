import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/widgets/keep_alive_wrapper.dart';

import 'platform_style.dart';
import 'tabs/tab_bar_controller.dart';

class CLTabBar<T> extends StatelessWidget {
  const CLTabBar({
    super.key,
    required this.dataController,
  });

  final CLTabBarController<T> dataController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(context),
        Expanded(child: _buildTabBarPage(context)),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return TabBar(
        controller: dataController.asMaterial,
        tabs: dataController.items
            .map((item) => Tab(text: item.text))
            .toList(),
      );
    } else {
      return ValueListenableBuilder<CLTabItem<T>>(
        valueListenable: dataController.selectedItemNty,
        builder: (context, selected, _) {
          return SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<CLTabItem<T>>(
              children: {for (final item in dataController.items) item: Text(item.text)},
              onValueChanged: dataController.onValueChanged,
              groupValue: selected,
            ),
          );
        },
      );
    }
  }

  Widget _buildTabBarPage(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return TabBarView(
        controller: dataController.asMaterial,
        children: dataController.items
            .map((item) => KeepAliveWrapper(child: item.pageBuilder(context)))
            .toList(),
      );
    } else {
      return ValueListenableBuilder<CLTabItem<T>>(
        valueListenable: dataController.selectedItemNty,
        builder: (context, selected, _) {
          final index = dataController.items.indexOf(selected);
          return IndexedStack(
            index: index,
            children: dataController.items
                .map((item) => KeepAliveWrapper(child: item.pageBuilder(context)))
                .toList(),
          );
        },
      );
    }
  }
}
