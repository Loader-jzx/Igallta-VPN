import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/igallta_usage.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

/// Palette sampled from the supplied JZX-Proxy / Igallta reference.
abstract final class IgalltaViolet {
  static const accent = Color(0xFF9B7BFF);
  static const accentSoft = Color(0xFFC4B5FD);
  static const accentDeep = Color(0xFF6D3FE0);
  static const bgTop = Color(0xFF120C25);
  static const bgBottom = Color(0xFF080510);
  static const heroBg = Color(0xFF120C24);
  static const card = Color(0xE61C1438);
  static const cardBorder = Color(0x3D7556B8);
  static const field = Color(0xCC120C24);
  static const text = Color(0xFFF1EDFF);
  static const muted = Color(0xFF9A92B4);
  static const ok = Color(0xFF4ADE80);
  static const info = Color(0xFF67E8F9);
  static const warn = Color(0xFFF5B544);
  static const danger = Color(0xFFF87171);
}

class IgalltaHomeView extends ConsumerStatefulWidget {
  const IgalltaHomeView({super.key});

  @override
  ConsumerState<IgalltaHomeView> createState() => _IgalltaHomeViewState();
}

class _IgalltaHomeViewState extends ConsumerState<IgalltaHomeView> {
  final _search = TextEditingController();
  String _query = '';
  String? _groupName;

  @override
  void initState() {
    super.initState();
    unawaited(IgalltaUsage.instance.ensureLoaded());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [IgalltaViolet.bgTop, IgalltaViolet.bgBottom],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final horizontal = compact ? 18.0 : 24.0;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 18 + padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(compact: compact),
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 17,
                        child: CustomPaint(painter: _WavePainter()),
                      ),
                      const SizedBox(height: 8),
                      if (compact) ...[
                        const _ModeCard(),
                        const SizedBox(height: 14),
                        _NodesCard(
                          controller: _search,
                          query: _query,
                          groupName: _groupName,
                          onGroup: (name) => setState(() => _groupName = name),
                          onQuery: (value) => setState(() => _query = value),
                        ),
                        const SizedBox(height: 14),
                        const _TrafficCard(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 46,
                              child: Column(
                                children: [
                                  SizedBox(height: 198, child: _ModeCard()),
                                  SizedBox(height: 14),
                                  SizedBox(height: 206, child: _TrafficCard()),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 54,
                              child: SizedBox(
                                height: 418,
                                child: _NodesCard(
                                  controller: _search,
                                  query: _query,
                                  groupName: _groupName,
                                  onGroup: (name) =>
                                      setState(() => _groupName = name),
                                  onQuery: (value) =>
                                      setState(() => _query = value),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      const SizedBox(height: 110, child: _LogsCard()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding, this.radius = 16});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(17, 14, 17, 14),
      decoration: BoxDecoration(
        color: IgalltaViolet.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: IgalltaViolet.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.icon, required this.title, this.trailing});

  final Glyph icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: IgalltaViolet.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GlyphIcon(icon, size: 15, color: IgalltaViolet.accentSoft),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            height: 1.1,
            fontWeight: FontWeight.w600,
            color: IgalltaViolet.text,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final connected = status == CoreStatus.connected;
    final traffics = ref.watch(trafficsProvider).list;
    final last = traffics.isEmpty ? null : traffics.last;
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final firstGroup = groups.isEmpty ? null : groups.first;
    final proxyName = firstGroup == null
        ? null
        : ref.watch(selectedProxyNameProvider(firstGroup.name));
    final delay = (firstGroup == null || proxyName == null)
        ? null
        : ref.watch(
            delayProvider(proxyName: proxyName, testUrl: firstGroup.testUrl),
          );
    final label = switch (status) {
      CoreStatus.connected => '已连接',
      CoreStatus.connecting => '连接中',
      CoreStatus.disconnected => '未连接',
    };
    final height = compact ? 274.0 : 330.0;
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heroWidth = compact ? 520.0 : constraints.maxWidth * 0.66;
          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: IgalltaViolet.heroBg),
                Positioned(
                  right: compact ? -110 : -6,
                  top: compact ? -44 : -6,
                  width: heroWidth,
                  child: AspectRatio(
                    aspectRatio: 972 / 355,
                    child: Image.asset(
                      'assets/images/igallta-hero.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        IgalltaViolet.heroBg,
                        IgalltaViolet.heroBg,
                        Color(0x00120C24),
                      ],
                      stops: [0, 0.34, 0.72],
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF120C24), Color(0x00120C24)],
                      stops: [0, 0.42],
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 20 : 54,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _PowerRing(
                      connected: connected,
                      size: compact ? 112 : 154,
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 148 : 242,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: compact ? 23 : 30,
                                height: 1.06,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                                color: IgalltaViolet.text,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: connected
                                    ? IgalltaViolet.ok
                                    : status == CoreStatus.connecting
                                    ? IgalltaViolet.warn
                                    : IgalltaViolet.muted,
                                boxShadow: connected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x884ADE80),
                                          blurRadius: 9,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '延迟',
                              style: TextStyle(
                                fontSize: 12,
                                color: IgalltaViolet.muted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              delay == null
                                  ? '—'
                                  : delay < 0
                                  ? '超时'
                                  : '$delay',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: compact ? 19 : 23,
                                fontWeight: FontWeight.w500,
                                color: delay == null || delay < 0
                                    ? IgalltaViolet.muted
                                    : IgalltaViolet.accentSoft,
                              ),
                            ),
                            if (delay != null && delay >= 0) ...[
                              const SizedBox(width: 4),
                              const Text(
                                'ms',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: IgalltaViolet.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: compact ? 8 : 11),
                        Row(
                          children: [
                            _Speed(
                              label: '上传',
                              value: last == null
                                  ? '0 B'
                                  : last.up.shortTraffic.show,
                            ),
                            SizedBox(width: compact ? 18 : 24),
                            _Speed(
                              label: '下载',
                              value: last == null
                                  ? '0 B'
                                  : last.down.shortTraffic.show,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 18 : 52,
                  bottom: 0,
                  child: SizedBox(
                    height: 14,
                    width: compact ? 160 : 240,
                    child: CustomPaint(painter: _HeroWavePainter()),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Speed extends StatelessWidget {
  const _Speed({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: IgalltaViolet.muted),
        ),
        const SizedBox(width: 6),
        Text(
          '$value/s',
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 12,
            color: IgalltaViolet.text,
          ),
        ),
      ],
    );
  }
}

class _PowerRing extends ConsumerWidget {
  const _PowerRing({required this.connected, required this.size});

  final bool connected;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glyphSize = size * 0.35;
    return Semantics(
      button: true,
      label: connected ? '断开连接' : '连接',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(commonActionProvider.notifier).toggleRunning();
        },
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(2.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: connected
                  ? const [
                      Color(0xFFD8CCFF),
                      Color(0xFF9B7BFF),
                      Color(0xFF4C2A9E),
                      Color(0xFFD8CCFF),
                    ]
                  : const [
                      Color(0xFF51456F),
                      Color(0xFF2B2344),
                      Color(0xFF51456F),
                    ],
            ),
            boxShadow: connected
                ? const [
                    BoxShadow(
                      color: Color(0x889B7BFF),
                      blurRadius: 38,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Color(0x339B7BFF),
                      blurRadius: 84,
                      spreadRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFF221741), Color(0xFF0D081B)],
                radius: 0.82,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(size * 0.095),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: connected
                      ? const Color(0x559B7BFF)
                      : const Color(0x223D3358),
                ),
              ),
              child: CustomPaint(
                painter: _PowerGlyph(
                  color: connected
                      ? IgalltaViolet.accentSoft
                      : IgalltaViolet.muted,
                  size: glyphSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PowerGlyph extends CustomPainter {
  const _PowerGlyph({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = canvasSize.center(Offset.zero);
    final radius = size * 0.36;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.6, size * 0.075)
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + 0.72,
      math.pi * 2 - 1.44,
      false,
      paint,
    );
    canvas.drawLine(
      center + Offset(0, -radius * 1.56),
      center + Offset(0, -radius * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PowerGlyph oldDelegate) =>
      oldDelegate.color != color || oldDelegate.size != size;
}

class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i <= size.width; i++) {
      final x = i.toDouble();
      final y =
          size.height * 0.55 +
          math.sin(i / size.width * math.pi * 2.4) * 3.4 +
          math.sin(i / size.width * math.pi * 7.1) * 0.9;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = const LinearGradient(
          colors: [
            Color(0x009B7BFF),
            Color(0x999B7BFF),
            Color(0x229B7BFF),
            Color(0x009B7BFF),
          ],
          stops: [0, 0.35, 0.72, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}

class _HeroWavePainter extends CustomPainter {
  const _HeroWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.05,
        size.width * 0.45,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 1.15,
        size.width,
        size.height * 0.4,
      );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..shader = const LinearGradient(
          colors: [Color(0x009B7BFF), Color(0xAA9B7BFF), Color(0x009B7BFF)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_HeroWavePainter oldDelegate) => false;
}

class _ModeCard extends ConsumerWidget {
  const _ModeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(patchClashConfigProvider).mode;
    void change(Mode next) {
      if (mode == next) {
        return;
      }
      HapticFeedback.selectionClick();
      ref.read(setupActionProvider.notifier).changeMode(next);
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(icon: AppGlyphs.sliders, title: '代理模式'),
          const SizedBox(height: 12),
          Row(
            children: [
              _ModeChip(
                label: '自动选择',
                icon: AppGlyphs.bolt,
                selected: mode == Mode.rule,
                onTap: () => change(Mode.rule),
              ),
              const SizedBox(width: 8),
              _ModeChip(
                label: '全局模式',
                selected: mode == Mode.global,
                onTap: () => change(Mode.global),
              ),
              const SizedBox(width: 8),
              _ModeChip(
                label: '直连模式',
                selected: mode == Mode.direct,
                onTap: () => change(Mode.direct),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref
                .read(currentPageLabelProvider.notifier)
                .toPage(PageLabel.rules),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: IgalltaViolet.field,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '当前规则',
                        style: TextStyle(
                          fontSize: 9,
                          color: IgalltaViolet.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        switch (mode) {
                          Mode.rule => 'Rule',
                          Mode.global => 'Global',
                          Mode.direct => 'Direct',
                        },
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 12,
                          color: IgalltaViolet.text,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const GlyphIcon(
                    AppGlyphs.chevronForward,
                    size: 14,
                    color: IgalltaViolet.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Glyph? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9B7BFF), Color(0xFF6D3FE0)],
                  )
                : null,
            color: selected ? null : IgalltaViolet.field,
            border: Border.all(
              color: selected
                  ? const Color(0x66D8CCFF)
                  : const Color(0x1AFFFFFF),
            ),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x559B7BFF),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                GlyphIcon(
                  icon!,
                  size: 13,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : IgalltaViolet.muted,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFB7AECB),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrafficCard extends ConsumerWidget {
  const _TrafficCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traffics = ref.watch(trafficsProvider).list;
    final samples = [
      for (final item in traffics) (item.up + item.down).toDouble(),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(icon: AppGlyphs.dataUsage, title: '流量统计'),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<IgalltaUsageSnapshot>(
              valueListenable: IgalltaUsage.instance.notifier,
              builder: (context, usage, _) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _TrafficStat(
                        label: '今日用量',
                        value: igalltaBytes(usage.day),
                      ),
                    ),
                    Expanded(
                      child: _TrafficStat(
                        label: '本月用量',
                        value: igalltaBytes(usage.month),
                      ),
                    ),
                    Expanded(
                      child: _TrafficStat(
                        label: '总用量',
                        value: igalltaBytes(usage.total),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 52,
                      child: CustomPaint(
                        painter: _SparkPainter(samples: samples),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficStat extends StatelessWidget {
  const _TrafficStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: IgalltaViolet.muted),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: IgalltaViolet.text,
          ),
        ),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.samples});

  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (samples.length < 2) {
      path
        ..moveTo(0, size.height * 0.72)
        ..lineTo(size.width, size.height * 0.72);
    } else {
      final maxValue = samples.reduce(math.max);
      final safeMax = maxValue <= 0 ? 1.0 : maxValue;
      for (var i = 0; i < samples.length; i++) {
        final x = size.width * i / (samples.length - 1);
        final y = size.height - (samples[i] / safeMax) * size.height * 0.86;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            IgalltaViolet.accent.withValues(alpha: 0.28),
            IgalltaViolet.accent.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = IgalltaViolet.accent,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) => true;
}

class _NodesCard extends ConsumerWidget {
  const _NodesCard({
    required this.controller,
    required this.query,
    required this.groupName,
    required this.onGroup,
    required this.onQuery,
  });

  final TextEditingController controller;
  final String query;
  final String? groupName;
  final ValueChanged<String?> onGroup;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(visibleGroupsStateProvider).value;
    Group? activeGroup;
    for (final item in groups) {
      if (item.name == groupName) {
        activeGroup = item;
        break;
      }
    }
    if (activeGroup == null && groups.isNotEmpty) {
      activeGroup = groups.first;
    }
    final group = activeGroup;
    final isCompact = MediaQuery.sizeOf(context).width < 760;
    final visible = <Proxy>[
      if (group != null)
        for (final proxy in group.all)
          if (query.isEmpty ||
              proxy.name.toLowerCase().contains(query.toLowerCase()))
            proxy,
    ];
    final selectedName = group == null
        ? null
        : ref.watch(selectedProxyNameProvider(group.name));
    final testing = group == null
        ? false
        : ref.watch(
            delayTestingGroupsProvider.select(
              (state) => state.contains(group.name),
            ),
          );
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelHeader(icon: AppGlyphs.layers, title: '节点列表'),
              const Spacer(),
              if (!isCompact && groups.length > 1 && group != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final index = groups.indexOf(group!);
                    onGroup(groups[(index + 1) % groups.length].name);
                  },
                  child: Container(
                    height: 25,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: IgalltaViolet.field,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: IgalltaViolet.cardBorder),
                    ),
                    child: Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: IgalltaViolet.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const GlyphIcon(
                          AppGlyphs.chevronDown,
                          size: 10,
                          color: IgalltaViolet.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: group == null || testing
                    ? null
                    : () => ref
                          .read(proxiesActionProvider.notifier)
                          .delayTestPageGroup(group.name),
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: testing
                      ? const Center(
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: IgalltaViolet.accent,
                            ),
                          ),
                        )
                      : const GlyphIcon(
                          AppGlyphs.refresh,
                          size: 15,
                          color: IgalltaViolet.muted,
                        ),
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: isCompact ? 128 : 168,
                height: 28,
                child: _SearchField(controller: controller, onChanged: onQuery),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const _TableHeader(),
          const SizedBox(height: 3),
          Expanded(
            child: group == null
                ? const _NodesEmpty()
                : visible.isEmpty
                ? Center(
                    child: Text(
                      query.isEmpty ? '代理组暂时没有节点' : '没有匹配的节点',
                      style: const TextStyle(
                        fontSize: 11,
                        color: IgalltaViolet.muted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemExtent: 55,
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final proxy = visible[index];
                      return _NodeRow(
                        group: group!,
                        proxy: proxy,
                        selected: selectedName == proxy.name,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                group == null
                    ? '未加载配置'
                    : '${group.name} · ${visible.length} 个节点',
                style: const TextStyle(fontSize: 9, color: IgalltaViolet.muted),
              ),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref
                    .read(currentPageLabelProvider.notifier)
                    .toPage(PageLabel.proxies),
                child: const Row(
                  children: [
                    Text(
                      '查看全部',
                      style: TextStyle(
                        fontSize: 9,
                        color: IgalltaViolet.accentSoft,
                      ),
                    ),
                    SizedBox(width: 3),
                    GlyphIcon(
                      AppGlyphs.chevronForward,
                      size: 10,
                      color: IgalltaViolet.accentSoft,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 9, color: IgalltaViolet.muted);
    return const Padding(
      padding: EdgeInsets.only(left: 7, right: 5),
      child: Row(
        children: [
          SizedBox(width: 31),
          Expanded(child: Text('名称', style: style)),
          SizedBox(width: 66, child: Text('延迟', style: style)),
          SizedBox(width: 50, child: Text('负载', style: style)),
          SizedBox(width: 36, child: Text('信号', style: style)),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: IgalltaViolet.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: IgalltaViolet.cardBorder),
      ),
      child: Row(
        children: [
          const GlyphIcon(
            AppGlyphs.search,
            size: 12,
            color: IgalltaViolet.muted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (value.text.isEmpty)
                      const Text(
                        '搜索节点...',
                        style: TextStyle(
                          fontSize: 9,
                          color: IgalltaViolet.muted,
                        ),
                      ),
                    TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: const TextStyle(
                        fontSize: 9,
                        color: IgalltaViolet.text,
                      ),
                      cursorColor: IgalltaViolet.accentSoft,
                      decoration: null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NodesEmpty extends StatelessWidget {
  const _NodesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: IgalltaViolet.field,
              border: Border.all(color: IgalltaViolet.cardBorder),
            ),
            child: const GlyphIcon(
              AppGlyphs.layers,
              size: 18,
              color: IgalltaViolet.muted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暂无节点',
            style: TextStyle(fontSize: 12, color: IgalltaViolet.text),
          ),
          const SizedBox(height: 2),
          const Text(
            '导入配置后即可选择节点',
            style: TextStyle(fontSize: 9, color: IgalltaViolet.muted),
          ),
        ],
      ),
    );
  }
}

class _NodeRow extends ConsumerWidget {
  const _NodeRow({
    required this.group,
    required this.proxy,
    required this.selected,
  });

  final Group group;
  final Proxy proxy;
  final bool selected;

  void _select(WidgetRef ref) {
    final type = group.type;
    if (!type.isComputedSelected && type != GroupType.Selector) {
      return;
    }
    HapticFeedback.selectionClick();
    ref
        .read(proxiesActionProvider.notifier)
        .changeProxyDebounce(group.name, proxy.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: proxy.name, testUrl: group.testUrl),
    );
    final hasDelay = delay != null && delay >= 0;
    final color = !hasDelay
        ? IgalltaViolet.danger
        : delay < 100
        ? IgalltaViolet.ok
        : delay < 200
        ? IgalltaViolet.warn
        : IgalltaViolet.danger;
    final load = !hasDelay ? 0 : (12 + delay * 0.32).clamp(8, 96).round();
    final level = !hasDelay
        ? 0
        : delay < 100
        ? 4
        : delay < 160
        ? 3
        : delay < 240
        ? 2
        : 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _select(ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.only(left: 7, right: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: selected
              ? IgalltaViolet.accent.withValues(alpha: 0.18)
              : const Color(0x00000000),
          border: Border.all(
            color: selected
                ? IgalltaViolet.accent.withValues(alpha: 0.28)
                : const Color(0x00000000),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 31,
              child: Text(
                _flagOf(proxy.name),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proxy.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFFFFFFFF)
                          : IgalltaViolet.text,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    proxy.type.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 7.5,
                      letterSpacing: 0.5,
                      color: IgalltaViolet.muted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 66,
              child: Text(
                hasDelay ? '$delay ms' : '超时',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  color: color,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                hasDelay ? '$load%' : '—',
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  color: IgalltaViolet.muted,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: _SignalBars(color: color, level: level),
            ),
            SizedBox(
              width: 20,
              child: selected
                  ? const GlyphIcon(
                      AppGlyphs.check,
                      size: 13,
                      color: IgalltaViolet.accentSoft,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.color, required this.level});

  final Color color;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 1; i <= 4; i++)
          Container(
            width: 3,
            height: 4.0 + i * 2.4,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: i <= level ? color : const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

String _flagOf(String name) {
  const map = {
    '日本': '🇯🇵',
    '东京': '🇯🇵',
    '大阪': '🇯🇵',
    'japan': '🇯🇵',
    'tokyo': '🇯🇵',
    '美国': '🇺🇸',
    '洛杉矶': '🇺🇸',
    'us': '🇺🇸',
    'usa': '🇺🇸',
    'america': '🇺🇸',
    '香港': '🇭🇰',
    'hong': '🇭🇰',
    'hk': '🇭🇰',
    '新加坡': '🇸🇬',
    'singapore': '🇸🇬',
    'sg': '🇸🇬',
    '德国': '🇩🇪',
    'germany': '🇩🇪',
    '台湾': '🇨🇳',
    '台北': '🇨🇳',
    'taiwan': '🇨🇳',
    '韩国': '🇰🇷',
    '首尔': '🇰🇷',
    'korea': '🇰🇷',
    '英国': '🇬🇧',
    '伦敦': '🇬🇧',
    'uk': '🇬🇧',
    'london': '🇬🇧',
  };
  final lower = name.toLowerCase();
  for (final entry in map.entries) {
    if (lower.contains(entry.key)) {
      return entry.value;
    }
  }
  return '◈';
}

class _LogsCard extends ConsumerWidget {
  const _LogsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider).list.reversed.take(4).toList();
    final connected = ref.watch(coreStatusProvider) == CoreStatus.connected;
    final groups = ref.watch(visibleGroupsStateProvider).value;
    final group = groups.isEmpty ? null : groups.first;
    final proxyName = group == null
        ? null
        : ref.watch(selectedProxyNameProvider(group.name));
    final delay = (group == null || proxyName == null)
        ? null
        : ref.watch(
            delayProvider(proxyName: proxyName, testUrl: group.testUrl),
          );
    final mode = ref.watch(patchClashConfigProvider).mode;
    final time = _nowTime();
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 11, 12, 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PanelHeader(icon: AppGlyphs.logs, title: '运行日志'),
              const Spacer(),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(logsProvider.notifier).clear(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Row(
                    children: [
                      GlyphIcon(
                        AppGlyphs.broom,
                        size: 11,
                        color: IgalltaViolet.muted,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '清空日志',
                        style: TextStyle(
                          fontSize: 9,
                          color: IgalltaViolet.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: logs.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LogLine(
                        time: time,
                        level: 'INFO',
                        payload:
                            '${switch (mode) {
                              Mode.rule => '规则模式',
                              Mode.global => '全局模式',
                              Mode.direct => '直连模式',
                            }}已生效',
                        color: IgalltaViolet.info,
                      ),
                      if (group != null)
                        _LogLine(
                          time: time,
                          level: 'INFO',
                          payload: '代理组: ${group.name}',
                          color: IgalltaViolet.info,
                        ),
                      if (proxyName != null)
                        _LogLine(
                          time: time,
                          level: 'INFO',
                          payload: '当前节点: $proxyName',
                          color: IgalltaViolet.info,
                        ),
                      if (connected)
                        _LogLine(
                          time: time,
                          level: 'INFO',
                          payload:
                              '连接成功，延迟 ${delay == null ? '—' : '$delay ms'}',
                          color: IgalltaViolet.ok,
                        ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final log in logs)
                        _LogLine(
                          time: log.dateTime.split(' ').last,
                          level: log.logLevel.name.toUpperCase(),
                          payload: log.payload,
                          color: switch (log.logLevel) {
                            LogLevel.error => IgalltaViolet.danger,
                            LogLevel.warning => IgalltaViolet.warn,
                            LogLevel.info => IgalltaViolet.info,
                            _ => IgalltaViolet.muted,
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({
    required this.time,
    required this.level,
    required this.payload,
    required this.color,
  });

  final String time;
  final String level;
  final String payload;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8,
              height: 1.2,
              color: IgalltaViolet.muted,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '[$level]',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8,
              height: 1.2,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              payload,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                height: 1.2,
                color: IgalltaViolet.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
