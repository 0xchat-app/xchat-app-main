
import 'package:flutter/material.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/navigator/navigator.dart';

class ComponentDemoPage extends StatefulWidget {
  ComponentDemoPage([this.index = 0]);
  final int index;

  @override
  State<StatefulWidget> createState() => ComponentDemoPageState();
}

class ComponentDemoPageState extends State<ComponentDemoPage> with TickerProviderStateMixin {

  dynamic radioValue;
  bool? checkboxValue = false;
  bool switchValue = false;
  dynamic tabBarValue;

  late CLTabBarController tabBarController; 
  
  @override
  void initState() {
    super.initState();

    final tabItems = [
      CLTabItem(value: 'TabA', pageBuilder: (_) => Container(color: Colors.cyan,)),
      CLTabItem(value: 'TabBBBBBBB', pageBuilder: (_) => Container(color: Colors.lightGreen,)),
    ];
    tabBarController = CLTabBarController(items: tabItems, initialItem: tabItems.first, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: CLScaffold(
        appBar: CLAppBar(title: widget.index),
        body: SizedBox.expand(
          child: CustomScrollView(
            slivers: [
              // CLAppBar.sliver(barType: MaterialBarType.small, title: widget.index),
              SliverToBoxAdapter(child: SafeArea(child: buildComponentWidgets())),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildComponentWidgets() {
    return Column(
      children: [
        CLText.titleSmall(
          'Next, you’ll need to join a Circle — this is your private space where only people on the same Circle server can message each other. You can: 1. Create a Circle using the default 0xchat paid server(circle.0xchat.com). 2. Join a Circle if you have an invite or your own private server.',
          colorToken: ColorToken.onPrimaryContainer,
        ),
        CLButton.elevated(text: 'Play', onTap: onTap, expanded: true,),
        CLButton.filled(text: 'Play', onTap: onTap, expanded: true,),
        CLButton.tonal(text: 'Play', onTap: onTap, expanded: true,),
        CLButton.outlined(text: 'Play', onTap: onTap, expanded: true,),
        CLButton.text(text: 'Play', onTap: onTap, expanded: true,),
        CLTextField(placeholder: 'test hint'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CLRadio(value: 1, groupValue: radioValue, onChanged: (value) {setState(() { radioValue = value; });},),
            CLRadio(value: 2, groupValue: radioValue, onChanged: (value) {setState(() { radioValue = value; });},)
          ],
        ),
        CLCheckbox(
          value: checkboxValue,
          onChanged: (value) {
            setState(() {
              checkboxValue = value;
            });
          },
        ),
        CLSwitch(
          value: switchValue,
          onChanged: (value) {
            setState(() {
              switchValue = value;
            });
          },
        ),
        Container(
          height: 350,
          child: CLTabBar(
            dataController: tabBarController,
          ),
        ),
        CLProgressIndicator.circular(progress: 0.5),
        CLProgressIndicator.linear(progress: 0.5,width: 300),
        CLButton.icon(iconName: 'icon_qrcode.png', package: 'ox_usercenter', onTap: onTap,),
        CLListView(
          shrinkWrap: true,
          items: [
            LabelItemModel(
              title: 'LabelItemModel',
              value$: ValueNotifier('AAA'),
            ),
            SwitcherItemModel(
              title: 'SwitcherItemModel',
              value$: ValueNotifier(false),
            ),
            CustomItemModel(
              title: 'CustomItemModel',
              subtitle: 'Subtitle',
              icon: ListViewIcon(iconName: 'icon_qrcode.png', package: 'ox_usercenter'),
              trailing: Container(color: Colors.cyan, height: 10, width: 20,),
            ),
          ],
        ),
        SizedBox(height: 400,),
      ],
    );
  }

  void onTap() {
    OXNavigator.pushPage(null, (_) => ComponentDemoPage(widget.index + 1));
  }
}