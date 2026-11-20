import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/prism_ui.dart';

import 'profile_detail.dart';

/// The palette of the Igallta subscription mockup: paper white surfaces, a navy
/// serif wordmark and the artwork's blue.
abstract final class IgalltaColors {
  static const blue = Color(0xFF3275CC);
  static const blueDeep = Color(0xFF2060B8);
  static const blueSoft = Color(0xFF82B9F0);
  static const navy = Color(0xFF142742);
  static const ink = Color(0xFF24344B);
  static const muted = Color(0xFF75859B);
  static const line = Color(0xFFE3EAF3);
  static const mist = Color(0xFFF5F8FC);
  static const ice = Color(0xFFEAF3FF);
  static const green = Color(0xFF438568);
  static const greenSoft = Color(0xFFEAF7F1);
}

class IgalltaPalette {
  const IgalltaPalette({
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.track,
    required this.ice,
    required this.shadow,
  });

  factory IgalltaPalette.of(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (colorScheme.brightness == Brightness.dark) {
      return IgalltaPalette(
        card: colorScheme.surfaceContainerHigh,
        ink: colorScheme.onSurface,
        muted: colorScheme.onSurfaceVariant,
        line: colorScheme.outlineVariant.withValues(alpha: 0.45),
        track: colorScheme.surfaceContainerHighest,
        ice: colorScheme.primary.withValues(alpha: 0.16),
        shadow: const Color(0x33000000),
      );
    }
    return const IgalltaPalette(
      card: Color(0xFFFFFFFF),
      ink: IgalltaColors.ink,
      muted: IgalltaColors.muted,
      line: IgalltaColors.line,
      track: Color(0xFFEAF0F7),
      ice: IgalltaColors.ice,
      shadow: Color(0x12345B8C),
    );
  }

  final Color card;
  final Color ink;
  final Color muted;
  final Color line;
  final Color track;
  final Color ice;
  final Color shadow;
}

const _serif = 'serif';
const _mono = 'JetBrainsMono';

/// The bar the mockup puts above the page: the Igallta wordmark, the
/// "PROXY CONTROL" tag and the live core status.
class IgalltaBrandBar extends ConsumerWidget {
  const IgalltaBrandBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = IgalltaPalette.of(context);
    final status = ref.watch(coreStatusProvider);
    final appLocalizations = context.appLocalizations;
    final (dot, label) = switch (status) {
      CoreStatus.connected => (const Color(0xFF72BD9A), appLocalizations.connected),
      CoreStatus.connecting => (const Color(0xFFE0A93F), appLocalizations.connecting),
      CoreStatus.disconnected => (
        const Color(0xFFC9D2DE),
        appLocalizations.disconnected,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 14),
      child: Row(
        children: [
          Text(
            'IGALLTA',
            style: TextStyle(
              fontFamily: _serif,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.3,
              color: palette.ink,
            ),
          ),
          const SizedBox(width: 13),
          Container(width: 1, height: 22, color: palette.line),
          const SizedBox(width: 13),
          Text(
            'PROXY CONTROL',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.3,
              color: palette.muted,
            ),
          ),
          const Spacer(),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dot.withValues(alpha: 0.22),
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, color: palette.muted)),
          const SizedBox(width: 6),
          Text('·', style: TextStyle(fontSize: 11, color: palette.line)),
          const SizedBox(width: 6),
          Text('Android', style: TextStyle(fontSize: 11, color: palette.muted)),
        ],
      ),
    );
  }
}

/// The subscription card of the mockup: usage, quota and the artwork.
class IgalltaSubscriptionCard extends ConsumerWidget {
  const IgalltaSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    final wide = density.isDesktop;
    final palette = IgalltaPalette.of(context);
    final profile = ref.watch(currentProfileProvider);
    final info = profile?.subscriptionInfo;
    final used = info == null ? null : info.upload + info.download;
    final total = (info?.total ?? 0) > 0 ? info!.total : null;
    final share = (used != null && total != null && total > 0)
        ? (used / total).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final art = _Artwork(palette: palette, wide: wide);
    final details = _Details(
      palette: palette,
      profile: profile,
      used: used,
      total: total,
      share: share,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.line),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _RingsPainter(color: palette.ice, stroke: palette.line),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 32 : 20,
                wide ? 29 : 20,
                wide ? 24 : 20,
                wide ? 27 : 20,
              ),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 12, child: details),
                        const SizedBox(width: 12),
                        Expanded(flex: 9, child: art),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        art,
                        const SizedBox(height: 8),
                        details,
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.palette, required this.wide});

  final IgalltaPalette palette;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/igallta-crisp-lineart.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.medium,
    );
    // The drawing is white paper with blue line work, so it keeps its own
    // white panel: on the white card it disappears into the page, and on a
    // dark theme it reads as a framed portrait instead of a white block.
    return SizedBox(
      height: wide ? null : 168,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.all(8), child: image),
        ),
      ),
    );
  }
}

class _Details extends ConsumerStatefulWidget {
  const _Details({
    required this.palette,
    required this.profile,
    required this.used,
    required this.total,
    required this.share,
  });

  final IgalltaPalette palette;
  final Profile? profile;
  final int? used;
  final int? total;
  final double share;

  @override
  ConsumerState<_Details> createState() => _DetailsState();
}

class _DetailsState extends ConsumerState<_Details>
    with ConfigCountsWatch<_Details> {
  @override
  Widget build(BuildContext context) {
    watchConfigCounts();
    final palette = widget.palette;
    final profile = widget.profile;
    final used = widget.used;
    final total = widget.total;
    final share = widget.share;
    final appLocalizations = context.appLocalizations;
    final expiry = _expiryOf(profile);
    final updated = profile?.lastUpdateDate;
    final providers = ref.watch(providersProvider);
    final stats = configCounts == null
        ? null
        : profileStatsOf(configCounts!, providers);
    final proxyCount = stats?.proxies;
    final name = (profile?.realLabel ?? '').isEmpty
        ? appLocalizations.addProfile
        : profile!.realLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: palette.ice,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: const Text(
                '▤',
                style: TextStyle(fontSize: 16, color: IgalltaColors.blue),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _serif,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: palette.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (profile != null) const _Pill(text: '使用中'),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  updated == null
                      ? '—'
                      : appLocalizations.profileUpdatedAt(
                          updated.getLastUpdateTimeDesc(context),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: palette.muted),
                ),
              ),
              if (profile != null)
                _TextButton(
                  label: '⟳ ${appLocalizations.update}',
                  palette: palette,
                  onTap: () => syncProfile(ref, profile!),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: palette.line),
        const SizedBox(height: 16),
        _UsageNumber(palette: palette, used: used, total: total),
        const SizedBox(height: 13),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            height: 9,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: palette.track)),
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: share.clamp(0.02, 1.0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [IgalltaColors.blueSoft, IgalltaColors.blue],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 7),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(share * 100).round()}%',
            style: TextStyle(fontFamily: _mono, fontSize: 11, color: palette.muted),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Stat(
                palette: palette,
                label: appLocalizations.usedTraffic,
                value: used == null ? '—' : dashboardTraffic(used!),
              ),
            ),
            Expanded(
              child: _Stat(
                palette: palette,
                label: appLocalizations.totalTraffic,
                value: total == null ? '—' : dashboardTraffic(total!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Stat(
                palette: palette,
                label: appLocalizations.expireTime,
                value: expiry == null ? '—' : expiry.show,
              ),
            ),
            Expanded(
              child: _Stat(
                palette: palette,
                label: appLocalizations.nodes,
                value: proxyCount == null ? '—' : '$proxyCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _Button(
              palette: palette,
              label: '管理配置',
              primary: true,
              onTap: () => showProfilesSheet(context),
            ),
            _Button(
              palette: palette,
              label: appLocalizations.nodes,
              onTap: () {
                ref
                    .read(currentPageLabelProvider.notifier)
                    .toPage(PageLabel.proxies);
              },
            ),
            if (profile != null)
              _Button(
                palette: palette,
                label: appLocalizations.update,
                onTap: () => showProfileDetailSheet(context),
              ),
          ],
        ),
      ],
    );
  }
}

DateTime? _expiryOf(Profile? profile) {
  final expire = profile?.subscriptionInfo?.expire ?? 0;
  return expire > 0 ? DateTime.fromMillisecondsSinceEpoch(expire * 1000) : null;
}

class _UsageNumber extends StatelessWidget {
  const _UsageNumber({
    required this.palette,
    required this.used,
    required this.total,
  });

  final IgalltaPalette palette;
  final int? used;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final big = TextStyle(
      fontFamily: _mono,
      fontSize: 32,
      height: 1,
      letterSpacing: -2,
      fontWeight: FontWeight.w500,
      color: palette.ink,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(used == null ? '—' : dashboardTraffic(used!), style: big),
        const SizedBox(width: 8),
        Text(
          total == null ? '' : '/ ${dashboardTraffic(total!)}',
          style: TextStyle(fontFamily: _mono, fontSize: 12, color: palette.muted),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: IgalltaColors.greenSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: IgalltaColors.green),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.palette, required this.label, required this.value});

  final IgalltaPalette palette;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: palette.muted)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: _mono, fontSize: 13, color: palette.ink),
        ),
      ],
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({required this.label, required this.palette, this.onTap});

  final String label;
  final IgalltaPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: IgalltaColors.blue),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.palette,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IgalltaPalette palette;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 104),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: primary ? IgalltaColors.blue : palette.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary ? IgalltaColors.blue : palette.line),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: IgalltaColors.blue.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: primary ? const Color(0xFFFFFFFF) : palette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// The faint concentric rings the mockup draws behind the subscription card.
class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.color, required this.stroke});

  final Color color;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 1.04, size.height * -0.22);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final radius in [
      size.height * 1.05,
      size.height * 1.28,
      size.height * 1.5,
    ]) {
      canvas.drawCircle(
        center,
        radius,
        paint..color = stroke.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stroke != stroke;
}
