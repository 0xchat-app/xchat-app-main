
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/utils/adapt.dart';

class CLListView extends StatelessWidget {
  final ScrollController? controller;
  final List<ListViewItem> items;
  final bool shrinkWrap;

  final bool hasLeading;

  CLListView({
    super.key,
    this.controller,
    required this.items,
    this.shrinkWrap = false,
  }) : hasLeading = itemsHasIcon(items);

  static bool itemsHasIcon(List<ListViewItem> items) {
    return items.any((item) => item.icon != null);
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) => buildItemWidget(items[index]),
        separatorBuilder: (_, index) => buildSeparator(items[index]),
      );
    } else {
      return ListView(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        children: [
          CupertinoListSection(
            hasLeading: hasLeading,
            backgroundColor: CupertinoColors.systemBackground,
            children: asCupertinoSectionChildren(true),
          )
        ],
      );
    }
  }

  Widget buildSeparator(ListViewItem item) {
    if (PlatformStyle.isUseMaterial) {
      return SizedBox();
    } else {
      return SizedBox();
    }
  }

  Widget buildItemWidget(ListViewItem model) {
    if (model is LabelItemModel) return _ListViewLabelItemWidget(model);
    if (model is SwitcherItemModel) return _ListViewSwitcherItemWidget(model);
    if (model is SelectedItemModel) return _ListViewSelectedItemWidget(model);
    if (model is CustomItemModel) return _ListViewCustomItemWidget(model);
    throw Exception('Unknown item model type');
  }

  List<Widget> asCupertinoSectionChildren(bool isCupertinoListTileBaseStyle) {
    return items.map((e) {
      e.isCupertinoListTileBaseStyle = isCupertinoListTileBaseStyle;
      return buildItemWidget(e);
    }).toList();
  }
}

class _ListViewItemBaseWidget extends StatelessWidget {
  const _ListViewItemBaseWidget({
    required this.model,
    this.extensionWidget,
    this.onTap,
  });

  final ListViewItem model;
  final Widget? extensionWidget;
  final GestureTapCallback? onTap;

  bool get isThemeStyle => model.style == ListViewItemStyle.theme;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) {
      return _buildMaterialListTile(context);
    } else {
      return _buildCupertinoListTile();
    }
  }

  Widget _buildMaterialListTile(BuildContext context) {
    final isThemeStyle = model.style == ListViewItemStyle.theme;
    final labelLargeNoColor = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: null);
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      leading: _buildLeading(),
      trailing: extensionWidget,
      onTap: onTap,
      tileColor: isThemeStyle ? ColorToken.primary.of(context) : null,
      textColor: isThemeStyle ? ColorToken.onPrimary.of(context) : null,
      iconColor: isThemeStyle ? ColorToken.onPrimary.of(context) : null,
      titleTextStyle: labelLargeNoColor,
      leadingAndTrailingTextStyle: labelLargeNoColor,
    );
  }

  Widget _buildCupertinoListTile() {
    if (model.isCupertinoListTileBaseStyle) {
      return CupertinoListTile(
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        leading: _buildLeading(),
        trailing: extensionWidget,
        onTap: onTap,
      );
    } else {
      return CupertinoListTile.notched(
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        leading: _buildLeading(),
        trailing: extensionWidget,
        onTap: onTap,
      );
    }
  }

  Widget? _buildLeading() {
    final icon = model.icon;
    if (icon == null) return null;

    final iconData = icon.data;
    if (iconData != null) {
      return Icon(iconData);
    }

    return ImageIcon(
      AssetImage('assets/images/${icon.iconName}', package: icon.package),
    );
  }

  Widget _buildTitle() =>
      CLText(model.title);

  Widget? _buildSubtitle() {
    final subtitle = model.subtitle;
    if (subtitle == null) {
      return null;
    }
    return CLText(subtitle);
  }
}

class _ListViewLabelItemWidget extends StatelessWidget {
  const _ListViewLabelItemWidget(this.model);

  final LabelItemModel model;

  @override
  Widget build(BuildContext context) => _ListViewItemBaseWidget(
    model: model,
    extensionWidget: buildValueListenable(),
    onTap: model.onTap,
  );

  Widget? buildValueListenable() {
    final valueNty = model.valueNty;
    if (valueNty == null) {
      return null;
    }

    return ValueListenableBuilder(
      valueListenable: valueNty,
      builder: (_, value, child) {
        final label = model.getValueMapData(value);
        return CLText(label);
      },
    );
  }
}

class _ListViewSwitcherItemWidget extends StatelessWidget {
  const _ListViewSwitcherItemWidget(this.model);

  final SwitcherItemModel model;

  @override
  Widget build(BuildContext context) => _ListViewItemBaseWidget(
    model: model,
    extensionWidget: buildValueListenable(),
  );

  Widget? buildValueListenable() {
    final valueNty = model.valueNty;
    return ValueListenableBuilder(
      valueListenable: valueNty,
      builder: (_, value, child) {
        return CLSwitch(
          value: value,
          onChanged: (newValue) {
            model.valueNty.value = newValue;
          },
        );
      },
    );
  }
}

class _ListViewSelectedItemWidget extends StatelessWidget {
  const _ListViewSelectedItemWidget(this.model);

  final SelectedItemModel model;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial) return buildWithMaterial();

    return _ListViewItemBaseWidget(
      model: model,
      onTap: itemOnTap,
      extensionWidget: buildValueListenable(),
    );
  }

  Widget buildWithMaterial() {
    return InkWell(
      onTap: itemOnTap,
      child: Container(
        height: 72.px,
        padding: EdgeInsets.symmetric(horizontal: 16.px),
        child: Row(
          children: [
            CLText.bodyLarge(model.title),
            Spacer(),
            buildValueListenable(),
          ],
        ),
      ),
    );
  }

  Widget buildValueListenable() {
    final valueNty = model.valueNty;
    return ValueListenableBuilder(
      valueListenable: valueNty,
      builder: (_, value, child) {
        if (value != model.value) return const SizedBox();
        return ImageIcon(
          AssetImage('assets/images/icon_selected.png', package: 'ox_common'),
        );
      },
    );
  }

  void itemOnTap() {
    model.selectedValueNty.value = model.value;
  }
}

class _ListViewCustomItemWidget extends StatelessWidget {
  const _ListViewCustomItemWidget(this.model);

  final CustomItemModel model;

  @override
  Widget build(BuildContext context) => model.customWidgetBuilder?.call(context) ??
      _ListViewItemBaseWidget(
        model: model,
        extensionWidget: model.trailing,
        onTap: model.onTap,
      );
}