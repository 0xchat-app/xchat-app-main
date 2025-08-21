import 'package:flutter/cupertino.dart';
import 'package:ox_common/component.dart';
import 'package:ox_common/widgets/common_toast.dart';
import 'package:ox_localizable/ox_localizable.dart';
import 'package:ox_module_service/ox_module_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutXChatPage extends StatefulWidget {
  final String previousPageTitle;

  const AboutXChatPage({
    super.key,
    required this.previousPageTitle,
  });

  @override
  State<AboutXChatPage> createState() => _AboutXChatPageState();
}

class _AboutXChatPageState extends State<AboutXChatPage> {
  String get title => Localized.text('ox_usercenter.about_xchat');
  
  late ValueNotifier<String> versionItemNty;

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  void _prepareData() {
    versionItemNty = ValueNotifier<String>('');
    _loadAppVersion();
  }

  @override
  void dispose() {
    versionItemNty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CLScaffold(
      appBar: CLAppBar(title: title),
      isSectionListPage: true,
      body: CLSectionListView(
        items: [
          SectionListViewItem(data: [
            LabelItemModel(
              icon: ListViewIcon.data(CupertinoIcons.chat_bubble_2),
              title: Localized.text('ox_usercenter.contact_us'),
              onTap: _contactUsOnTap,
            )
          ]),

          SectionListViewItem(
            header: Localized.text('ox_usercenter.about_xchat'),
            data: [
              LabelItemModel(
                icon: ListViewIcon(iconName: 'icon_setting_version.png', package: 'ox_usercenter'),
                title: Localized.text('ox_usercenter.version'),
                value$: versionItemNty,
              ),
              LabelItemModel(
                icon: ListViewIcon.data(CupertinoIcons.link),
                title: 'GitHub',
                onTap: _githubProjectOnTap,
              ),
              LabelItemModel(
                icon: ListViewIcon.data(CupertinoIcons.doc_text),
                title: Localized.text('ox_login.terms_of_service'),
                onTap: _termsOfServiceOnTap,
              ),
              LabelItemModel(
                icon: ListViewIcon.data(CupertinoIcons.shield),
                title: Localized.text('ox_login.privacy_policy'),
                onTap: _privacyPolicyOnTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _contactUsOnTap() {
    // TODO: Replace with actual contact URL
    const contactUrl = 'https://primal.net/p/nprofile1qqs9ajjs5p904ml92evlkayppdpx2n3zdrq6ejnw2wqphxrzmd62swswfwcse';
    
    try {
      OXModuleService.invoke('ox_common', 'gotoWebView', [
        context, 
        contactUrl, 
        null, 
        null, 
        null, 
        null
      ]);
    } catch (e) {
      CommonToast.instance.show(context, 'Failed to open contact page: $e');
    }
  }

  void _termsOfServiceOnTap() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [
      context, 
      'https://0xchat.com/protocols/xchat-terms-of-use.html', 
      null, 
      null, 
      null, 
      null
    ]);
  }

  void _privacyPolicyOnTap() {
    OXModuleService.invoke('ox_common', 'gotoWebView', [
      context, 
      'https://0xchat.com/protocols/xchat-privacy-policy.html', 
      null, 
      null, 
      null, 
      null
    ]);
  }

  void _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;
      versionItemNty.value = '$version+$buildNumber';
    } catch (_) {
      versionItemNty.value = '';
    }
  }

  void _githubProjectOnTap() {
    const githubUrl = 'https://github.com/0xchat-app/xchat-app-main';
    
    try {
      OXModuleService.invoke('ox_common', 'gotoWebView', [
        context, 
        githubUrl, 
        null, 
        null, 
        null, 
        null
      ]);
    } catch (e) {
      CommonToast.instance.show(context, 'Failed to open GitHub project: $e');
    }
  }
}
