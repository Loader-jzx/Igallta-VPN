import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/icons/app_glyphs.dart';
import 'package:fl_clash/views/config/advanced.dart';
import 'package:fl_clash/views/config/rules.dart';
import 'package:fl_clash/views/views.dart';

class Navigation implements NavigationPort {
  static Navigation? _instance;

  @override
  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        glyph: AppGlyphs.dashboard,
        label: PageLabel.dashboard,
        builder: (_) => const DashboardView(),
      ),
      NavigationItem(
        glyph: AppGlyphs.layers,
        label: PageLabel.proxies,
        builder: (_) => const ProxiesView(),
        modes: hasProxies
            ? [NavigationItemMode.mobile, NavigationItemMode.desktop]
            : [],
      ),
      NavigationItem(
        glyph: AppGlyphs.sliders,
        label: PageLabel.rules,
        builder: (_) => const AddedRulesView(title: '规则'),
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        glyph: AppGlyphs.sync,
        label: PageLabel.subscriptions,
        builder: (_) => const ProfilesView(title: '订阅'),
        modes: [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        glyph: AppGlyphs.profiles,
        label: PageLabel.profiles,
        builder: (_) => const AdvancedConfigView(title: '配置'),
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        glyph: AppGlyphs.settings,
        label: PageLabel.settings,
        builder: (_) => const ToolsView(title: '设置'),
        modes: [NavigationItemMode.mobile, NavigationItemMode.desktop],
      ),
      NavigationItem(
        glyph: AppGlyphs.info,
        label: PageLabel.about,
        builder: (_) => const AboutView(),
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        glyph: AppGlyphs.requests,
        label: PageLabel.requests,
        builder: (_) => const RequestsView(),
        modes: [NavigationItemMode.moreFull],
      ),
      NavigationItem(
        glyph: AppGlyphs.dns,
        label: PageLabel.dns,
        builder: (_) => const DnsQueriesView(),
        modes: [NavigationItemMode.moreFull],
      ),
      NavigationItem(
        glyph: AppGlyphs.resources,
        label: PageLabel.resources,
        builder: (_) => const ResourcesView(),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        glyph: AppGlyphs.logs,
        label: PageLabel.logs,
        builder: (_) => const LogsView(),
        modes: openLogs ? [NavigationItemMode.more] : [],
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();
