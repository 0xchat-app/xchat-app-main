
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/widgets/keep_alive_wrapper.dart';

import 'platform_style.dart';
import 'tabs/tab_bar_controller.dart';

class CLTabScaffold extends StatelessWidget {
  const CLTabScaffold({
    required this.dataController,
  });

  final CLTabBarController dataController;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return ValueListenableBuilder(
          valueListenable: dataController.selectedItemNty,
          builder: (context, selected, _) {
          return Scaffold(
            body: KeepAliveWrapper(
              child: selected.pageBuilder(context),
            ),
            bottomNavigationBar: buildMaterialTabBar(),
          );
        }
      );
    } else {
      return CupertinoTabScaffold(
        tabBar: buildCupertinoTabBar(),
        tabBuilder: (BuildContext context, int index) {
          final items = [...dataController.items];
          final item = items[index];
          return item.pageBuilder(context);
        },
      );
    }
  }

  Widget buildMaterialTabBar() {
    final items = [...dataController.items];
    return NavigationBar(
      destinations: items.map((item) {
        return NavigationDestination(
          icon: buildIcon(item),
          label: item.text,
          enabled: true,
        );
      }).toList(),
      selectedIndex: dataController.selectedIndex,
      onDestinationSelected: selectedIndexOnChanged,
    );
  }

  CupertinoTabBar buildCupertinoTabBar() {
    final items = [...dataController.items];
    return CupertinoTabBar(
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: buildIcon(item),
          label: item.text,
        );
      }).toList(),
      onTap: selectedIndexOnChanged,
    );
  }

  Widget buildIcon(CLTabItem item) {
    final icon = item.icon;
    return icon == null ? ImageIcon(null) : ImageIcon(
      AssetImage('assets/images/${icon.assetName}', package: icon.package),
      size: 24,
    );
  }

  void selectedIndexOnChanged(int index) {
    final newSelected = dataController.items[index];
    dataController.onValueChanged(newSelected);
  }
}