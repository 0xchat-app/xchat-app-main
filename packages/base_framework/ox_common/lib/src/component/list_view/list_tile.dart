
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ox_common/utils/adapt.dart';
import 'package:ox_common/utils/widget_tool.dart';

import '../../../component.dart';

class CLListTile extends StatelessWidget {
  CLListTile({
    super.key,
    required this.model,
  });

  factory CLListTile.custom({
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return CLListTile(
      model: CustomItemModel(
        leading: leading,
        titleWidget: title,
        subtitleWidget: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  final ListViewItem model;

  @override
  Widget build(BuildContext context) {
    final model = this.model;
    if (model is LabelItemModel) return _ListViewLabelItemWidget(model);
    if (model is SwitcherItemModel) return _ListViewSwitcherItemWidget(model);
    if (model is SelectedItemModel) return _ListViewSelectedItemWidget(model);
    if (model is CustomItemModel) return _ListViewCustomItemWidget(model);
    throw Exception('Unknown item model type');
  }

  static Widget buildDefaultTrailing(GestureTapCallback? onTap) {
    if (PlatformStyle.isUseMaterial) return const SizedBox.shrink();;
    if (onTap == null) return const SizedBox.shrink();;
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Icon(
        CupertinoIcons.chevron_forward,
        size: 20,
        color: CupertinoColors.systemGrey,
      ),
    );
  }
}

class _ListViewItemBaseWidget extends StatelessWidget {
  const _ListViewItemBaseWidget({
    required this.model,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final ListViewItem model;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  bool get isThemeStyle => model.style == ListViewItemStyle.theme;

  @override
  Widget build(BuildContext context) {
    if (PlatformStyle.isUseMaterial || model.isUseMaterial == true) {
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
      title: title ?? _buildTitle(),
      subtitle: subtitle ?? _buildSubtitle(),
      leading: leading ?? _buildLeading(),
      trailing: trailing,
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
        title: title ?? _buildTitle(),
        subtitle: subtitle ?? _buildSubtitle(),
        leading: leading ?? _buildLeading(),
        trailing: Row(
          children: [
            trailing ?? const SizedBox.shrink(),
            if (model.isCupertinoAutoTrailing)
              CLListTile.buildDefaultTrailing(onTap),
          ],
        ).setPaddingOnly(left: 16.px),
        onTap: onTap,
      );
    } else {
      return CupertinoListTile.notched(
        title: title ?? _buildTitle(),
        subtitle: subtitle ?? _buildSubtitle(),
        leading: leading ?? _buildLeading(),
        trailing: Row(
          children: [
            trailing ?? const SizedBox.shrink(),
            if (model.isCupertinoAutoTrailing)
              CLListTile.buildDefaultTrailing(onTap),
          ],
        ).setPaddingOnly(left: 16.px),
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
    trailing: buildValueListenable(),
    onTap: model.onTap,
  );

  Widget? buildValueListenable() {
    final valueNty = model.value$;
    if (valueNty == null) {
      return null;
    }

    return ValueListenableBuilder(
      valueListenable: valueNty,
      builder: (_, value, child) {
        String label = model.getValueMapData(value);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 150.px),
          child: CLText(label),
        );
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
    trailing: buildValueListenable(),
  );

  Widget? buildValueListenable() {
    final valueNty = model.value$;
    return ValueListenableBuilder(
      valueListenable: valueNty,
      builder: (_, value, child) {
        return CLSwitch(
          value: value,
          onChanged: (newValue) {
            model.value$.value = newValue;
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
      trailing: buildValueListenable(),
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
    final valueNty = model.value$;
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
    model.selected$.value = model.value;
  }
}

class _ListViewCustomItemWidget extends StatelessWidget {
  const _ListViewCustomItemWidget(this.model);

  final CustomItemModel model;

  @override
  Widget build(BuildContext context) => model.customWidgetBuilder?.call(context) ??
      _ListViewItemBaseWidget(
        model: model,
        leading: model.leading,
        title: model.titleWidget,
        subtitle: model.subtitleWidget,
        trailing: model.trailing,
        onTap: model.onTap,
      );
}