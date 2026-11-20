import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/icons/icons.dart';
import 'package:prism_ui/surface.dart';

/// The fixed, fully expanded sidebar of the Igallta reference design.
///
/// The upstream sidebar collapses and animates its width; this one is drawn for
/// the tablet/desktop layout only, where the reference keeps the labels
/// visible. The mobile and laptop layouts still use the upstream sidebar.
class IgalltaSidebar extends StatelessWidget {
  const IgalltaSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.width = 240,
  });

  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double width;

  static const _bgTop = Color(0xFF18112F);
  static const _bgBottom = Color(0xFF0A0715);
  static const _text = Color(0xFFEDE9FE);
  static const _muted = Color(0xFF8F88A8);

  String _labelOf(NavigationItem item) {
    return switch (item.label) {
      PageLabel.dashboard => '首页',
      PageLabel.proxies => '节点列表',
      PageLabel.rules => '规则',
      PageLabel.subscriptions => '订阅',
      PageLabel.profiles => '配置',
      PageLabel.settings => '设置',
      PageLabel.about => '关于',
      _ => item.label.label,
    };
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;
    return Surface.transparent(
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
          border: BorderDirectional(end: BorderSide(color: Color(0x2A5E4A94))),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              right: -80,
              height: 320,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6D3FE0).withValues(alpha: 0.26),
                        const Color(0x006D3FE0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 178,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.92,
                  child: Image.asset(
                    'assets/images/igallta-sidebar-chibi.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 160,
              width: 34,
              height: 92,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.78,
                  child: Image.asset(
                    'assets/images/igallta-crystal.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: safeTop + 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: _Brand(),
                ),
                const SizedBox(height: 54),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 18, bottom: 184),
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = index == selectedIndex;
                      return _SidebarItem(
                        item: item,
                        label: _labelOf(item),
                        selected: selected,
                        onTap: () => onSelected(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: CustomPaint(painter: _CrestPainter()),
        ),
        const SizedBox(height: 14),
        const Text(
          'Igallta',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 21,
            height: 1.05,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: IgalltaSidebar._text,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'PROXY CONTROL',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: 2.3,
            color: IgalltaSidebar._muted,
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final NavigationItem item;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF8B63F6), Color(0xFF6D3FE0)],
                    )
                  : null,
              color: selected ? null : const Color(0x00000000),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x4D8B5CF6),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                GlyphIcon(
                  item.glyph,
                  size: 20,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFB2AAC9),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.1,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFFC9C3DD),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CrestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.04, h * 0.92)
      ..lineTo(w * 0.33, h * 0.08)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.67, h * 0.08)
      ..lineTo(w * 0.96, h * 0.92)
      ..lineTo(w * 0.72, h * 0.92)
      ..lineTo(w * 0.67, h * 0.80)
      ..lineTo(w * 0.50, h * 0.80)
      ..lineTo(w * 0.33, h * 0.92)
      ..close();
    final bounds = path.getBounds();
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC4B5FD), Color(0xFF8B5CF6), Color(0xFF4C2A9E)],
    ).createShader(bounds);
    canvas.drawShadow(path, const Color(0xAA6D3FE0), 12, false);
    canvas.drawPath(path, Paint()..shader = shader);
    final shine = Path()
      ..moveTo(w * 0.33, h * 0.08)
      ..lineTo(w * 0.50, h * 0.48)
      ..lineTo(w * 0.40, h * 0.40)
      ..close();
    canvas.drawPath(shine, Paint()..color = const Color(0x55FFFFFF));
    final facet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x55DDD6FE);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.78),
      facet,
    );
    final glow = Paint()
      ..color = const Color(0x668B5CF6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), math.min(w, h) * 0.30, glow);
  }

  @override
  bool shouldRepaint(_CrestPainter oldDelegate) => false;
}
