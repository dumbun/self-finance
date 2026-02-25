import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/chart_model.dart';
import 'package:self_finance/providers/chart_tab_providers.dart';
import 'package:self_finance/providers/monthly_chart_provider.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/drill_sheet_widget.dart';

class MonthlyChartSection extends StatefulWidget {
  const MonthlyChartSection({super.key});

  @override
  State<MonthlyChartSection> createState() => _MonthlyChartSectionState();
}

class _MonthlyChartSectionState extends State<MonthlyChartSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_anim),
        child: const _Content(),
      ),
    );
  }
}

// =============================================================================
// CONTENT  (header + tabs + animated body switcher)
// =============================================================================

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeChartTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.sp, 16.sp, 16.sp, 0),
          child: Row(
            children: [
              Expanded(
                child: BodyTwoDefaultText(text: _title(tab), bold: true),
              ),
              const _LegendDot(
                color: AppColors.getPrimaryColor,
                label: 'Received',
              ),
              SizedBox(width: 14.sp),
              const _LegendDot(
                color: AppColors.getErrorColor,
                label: 'Disbursed',
              ),
            ],
          ),
        ),

        SizedBox(height: 14.sp),

        // ── Tab bar ────────────────────────────────────────────────────────
        _TabBar(
          active: tab,
          onChanged: (t) {
            HapticFeedback.selectionClick();
            ref.read(activeChartTabProvider.notifier).setTab(t);
          },
        ),

        SizedBox(height: 4.sp),

        // ── Animated body ──────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: switch (tab) {
              ChartTab.yearly => const _YearlyBody(),
              ChartTab.monthly => const _MonthlyBody(),
              ChartTab.weekly => const _WeeklyBody(),
              ChartTab.today => const _TodayBody(),
            },
          ),
        ),
      ],
    );
  }

  String _title(ChartTab t) => switch (t) {
    ChartTab.yearly => 'Last 12 Months',
    ChartTab.monthly => 'Last 6 Months',
    ChartTab.weekly => 'Last 7 Days',
    ChartTab.today => "Today's Overview",
  };
}

// =============================================================================
// SEGMENTED TAB BAR
// =============================================================================

class _TabBar extends StatelessWidget {
  const _TabBar({required this.active, required this.onChanged});

  final ChartTab active;
  final ValueChanged<ChartTab> onChanged;

  static const _labels = {
    ChartTab.yearly: 'Yearly',
    ChartTab.monthly: 'Monthly',
    ChartTab.weekly: 'Weekly',
    ChartTab.today: 'Today',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.getLigthGreyColor.withAlpha(35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ChartTab.values.map((tab) {
          final isActive = tab == active;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.getPrimaryColor : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.getPrimaryColor.withAlpha(75),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: BodySmallText(
                  color: isActive ? AppColors.getBackgroundColor : null,
                  text: _labels[tab]!,
                  textAlign: TextAlign.center,
                  bold: isActive,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// DRILL SHEET OPENER
// Capture provider container BEFORE bottom sheet so the sheet always has access
// to the correct Riverpod container.
// =============================================================================

void _openDrill(
  BuildContext context,
  WidgetRef ref,
  DrillTarget target,
  String title,
) {
  final container = ProviderScope.containerOf(context, listen: false);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: DrillSheet(target: target, title: title),
    ),
  );
}

// =============================================================================
// TAB BODIES
// =============================================================================

class _YearlyBody extends ConsumerWidget {
  const _YearlyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(yearlyChartProvider)
        .when(
          data: (MonthlyChartState state) => _LineChartBody(
            state: state,
            onPointTapped:
                (
                  ChartData data,
                  int index,
                  List<Map<String, dynamic>>? rawMaps,
                ) {
                  final raw = rawMaps != null && index < rawMaps.length
                      ? rawMaps[index]
                      : null;

                  final DateTime now = DateTime.now();
                  final int offset = state.data.length - 1 - index;
                  final DateTime date = DateTime(
                    now.year,
                    now.month - offset,
                    1,
                  );

                  final int month = raw?['_monthNum'] as int? ?? date.month;
                  final int year = raw?['_year'] as int? ?? date.year;

                  _openDrill(
                    context,
                    ref,
                    DrillMonth(month: month, year: year),
                    '${data.month} $year',
                  );
                },
            rawProvider: yearlyChartRawProvider,
          ),
          loading: () => const _Skeleton(),
          error: (_, _) => const _Err(),
        );
  }
}

class _MonthlyBody extends ConsumerWidget {
  const _MonthlyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(monthlyChartProvider)
        .when(
          data: (MonthlyChartState state) => _LineChartBody(
            state: state,
            onPointTapped: (data, index, _) {
              final now = DateTime.now();
              final offset = state.data.length - 1 - index;
              final date = DateTime(now.year, now.month - offset, 1);

              _openDrill(
                context,
                ref,
                DrillMonth(month: date.month, year: date.year),
                '${data.month} ${date.year}',
              );
            },
            rawProvider: null,
          ),
          loading: () => const _Skeleton(),
          error: (_, _) => const _Err(),
        );
  }
}

class _WeeklyBody extends ConsumerWidget {
  const _WeeklyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(weeklyChartProvider)
        .when(
          data: (MonthlyChartState state) => _LineChartBody(
            state: state,
            onPointTapped: (data, index, rawMaps) {
              final raw = rawMaps != null && index < rawMaps.length
                  ? rawMaps[index]
                  : null;
              if (raw == null) return;

              _openDrill(
                context,
                ref,
                DrillDay(
                  txnDate: raw['_txnDate'] as String,
                  payDate: raw['_payDate'] as String,
                ),
                data.month, // e.g. 'Mon'
              );
            },
            rawProvider: weeklyRawProvider,
          ),
          loading: () => const _Skeleton(),
          error: (_, _) => const _Err(),
        );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(todayChartProvider)
        .when(
          data: (TodayState s) => Padding(
            padding: EdgeInsets.fromLTRB(18.sp, 10.sp, 18.sp, 10.sp),
            child: Column(
              children: [
                SizedBox(height: 20.sp),
                _SplitGauge(state: s),
                SizedBox(height: 16.sp),
                _NetBanner(net: s.net),
                SizedBox(height: 16.sp),
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        label: 'Loans today',
                        count: s.disbursedCount,
                        amount: s.disbursed,
                        color: AppColors.getErrorColor,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CountCard(
                        label: 'Payments today',
                        count: s.receivedCount,
                        amount: s.received,
                        color: AppColors.getPrimaryColor,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const _Skeleton(),
          error: (_, _) => const _Err(),
        );
  }
}

// =============================================================================
// SHARED LINE CHART BODY
// =============================================================================

typedef _RawProvider =
    ProviderListenable<AsyncValue<List<Map<String, dynamic>>>>;

class _LineChartBody extends ConsumerStatefulWidget {
  const _LineChartBody({
    required this.state,
    required this.onPointTapped,
    required this.rawProvider,
  });

  final MonthlyChartState state;
  final void Function(ChartData, int, List<Map<String, dynamic>>?)
  onPointTapped;
  final _RawProvider? rawProvider;

  @override
  ConsumerState<_LineChartBody> createState() => _LineChartBodyState();
}

class _LineChartBodyState extends ConsumerState<_LineChartBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  int? _sel;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void didUpdateWidget(covariant _LineChartBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.data != widget.state.data) {
      _sel = null;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap(
    TapDownDetails details,
    double width,
    List<Map<String, dynamic>>? rawMaps,
  ) {
    final int n = widget.state.data.length;
    if (n == 0) return;

    final int idx = n == 1
        ? 0
        : (details.localPosition.dx / (width / (n - 1))).round().clamp(
            0,
            n - 1,
          );

    HapticFeedback.lightImpact();

    if (_sel == idx) {
      widget.onPointTapped(widget.state.data[idx], idx, rawMaps);
    } else {
      setState(() => _sel = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartData> data = widget.state.data;

    // Improvement: watch raw provider once per build (safer than reading on tap)
    final List<Map<String, dynamic>>? rawMaps = widget.rawProvider != null
        ? ref.watch(widget.rawProvider!).asData?.value
        : null;

    // Avoid recreating series twice for painter
    final List<double> receivedSeries = data
        .map((d) => d.received)
        .toList(growable: false);
    final List<double> disbursedSeries = data
        .map((d) => d.disbursed)
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tooltip / hint ─────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _sel != null && _sel! < data.length
                ? _Tooltip(
                    key: ValueKey(_sel),
                    label: data[_sel!].month,
                    received: data[_sel!].received,
                    disbursed: data[_sel!].disbursed,
                    onDetails: () {
                      widget.onPointTapped(data[_sel!], _sel!, rawMaps);
                    },
                  )
                : SizedBox(
                    key: const ValueKey('hint'),
                    height: 52,
                    child: Center(
                      child: BodySmallText(
                        italic: true,
                        text: 'Tap a point  ·  tap again for details',
                        color: AppColors.getLigthGreyColor.withAlpha(90),
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 6),

          // ── Chart canvas ───────────────────────────────────────────────
          LayoutBuilder(
            builder: (_, constraints) {
              final w = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _onTap(d, w, rawMaps),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, _) => RepaintBoundary(
                    child: CustomPaint(
                      size: Size(w, 180),
                      painter: _ChartPainter(
                        received: receivedSeries,
                        disbursed: disbursedSeries,
                        maxValue: widget.state.maxValue,
                        progress: _anim.value,
                        sel: _sel,
                        rcvColor: AppColors.getPrimaryColor,
                        disColor: AppColors.getErrorColor,
                        gridColor: AppColors.getLigthGreyColor.withAlpha(50),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── X-axis labels ──────────────────────────────────────────────
          SizedBox(height: 10.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((d) => BodySmallText(text: d.month)).toList(),
          ),

          SizedBox(height: 14.sp),

          // ── Summary strip ──────────────────────────────────────────────
          _SummaryStrip(
            totalReceived: widget.state.totalReceived,
            totalDisbursed: widget.state.totalDisbursed,
          ),
        ],
      ),
    );
  }
}

// raw stream provider for yearly (weeklyRawProvider assumed to already exist)
final yearlyChartRawProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => BackEnd.watchYearlyChartData(),
    );

// =============================================================================
// CUSTOM PAINTER
// =============================================================================

class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.received,
    required this.disbursed,
    required this.maxValue,
    required this.progress,
    required this.sel,
    required this.rcvColor,
    required this.disColor,
    required this.gridColor,
  });

  final List<double> received;
  final List<double> disbursed;
  final double maxValue;
  final double progress;
  final int? sel;
  final Color rcvColor;
  final Color disColor;
  final Color gridColor;

  static const double _top = 14.0;
  static const double _bot = 4.0;
  static const int _gridLines = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (received.isEmpty) return;

    final int n = received.length;
    final double dh = size.height - _top - _bot;
    final double eff = maxValue == 0 ? 1.0 : maxValue;
    final double stepX = n > 1 ? size.width / (n - 1) : size.width;

    // Grid
    final Paint gPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.6;

    for (int i = 0; i <= _gridLines; i++) {
      final double y = _top + dh * (1 - i / _gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gPaint);
    }

    double cy(double v) => _top + dh * (1 - v / eff);
    double cx(int i) => n == 1 ? size.width / 2 : i * stepX;

    final List<Offset> rPts = [
      for (int i = 0; i < n; i++) Offset(cx(i), cy(received[i])),
    ];
    final List<Offset> dPts = [
      for (int i = 0; i < n; i++) Offset(cx(i), cy(disbursed[i])),
    ];

    // Animated reveal
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    _fill(canvas, size, rPts, rcvColor, dh);
    _fill(canvas, size, dPts, disColor, dh);
    _line(canvas, rPts, rcvColor);
    _line(canvas, dPts, disColor);
    canvas.restore();

    // Selection overlay (always visible)
    if (sel != null && sel! < n) {
      final double x = cx(sel!);

      canvas.drawLine(
        Offset(x, _top),
        Offset(x, _top + dh),
        Paint()
          ..color = gridColor
          ..strokeWidth = 1.2,
      );

      canvas.drawCircle(
        rPts[sel!],
        16,
        Paint()..color = rcvColor.withAlpha(10),
      );

      _dot(canvas, rPts[sel!], rcvColor);
      _dot(canvas, dPts[sel!], disColor);
    }
  }

  Path _curve(List<Offset> pts) {
    if (pts.length == 1) {
      return Path()..moveTo(pts[0].dx, pts[0].dy);
    }

    final Path path = Path()..moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final double mx = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(
        mx,
        pts[i].dy,
        mx,
        pts[i + 1].dy,
        pts[i + 1].dx,
        pts[i + 1].dy,
      );
    }

    return path;
  }

  void _fill(Canvas c, Size sz, List<Offset> pts, Color col, double dh) {
    if (pts.isEmpty) return;

    final Path path = Path()
      ..addPath(_curve(pts), Offset.zero)
      ..lineTo(pts.last.dx, _top + dh)
      ..lineTo(pts.first.dx, _top + dh)
      ..close();

    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [col.withAlpha(50), col.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, _top, sz.width, dh)),
    );
  }

  void _line(Canvas c, List<Offset> pts, Color col) {
    if (pts.length < 2) return;

    c.drawPath(
      _curve(pts),
      Paint()
        ..color = col
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _dot(Canvas c, Offset pt, Color col) {
    c.drawCircle(pt, 6, Paint()..color = Colors.white);

    c.drawCircle(
      pt,
      6,
      Paint()
        ..color = col
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    c.drawCircle(pt, 3, Paint()..color = col);
  }

  bool _sameList(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sel != sel ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.rcvColor != rcvColor ||
        oldDelegate.disColor != disColor ||
        oldDelegate.gridColor != gridColor ||
        !_sameList(oldDelegate.received, received) ||
        !_sameList(oldDelegate.disbursed, disbursed);
  }
}

// =============================================================================
// TOOLTIP
// =============================================================================

class _Tooltip extends StatelessWidget {
  const _Tooltip({
    super.key,
    required this.label,
    required this.received,
    required this.disbursed,
    required this.onDetails,
  });

  final String label;
  final double received;
  final double disbursed;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.sp),
      height: 28.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.getLigthGreyColor.withAlpha(70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          BodySmallText(
            text: label,
            color: AppColors.getLigthGreyColor,
            bold: true,
          ),
          SizedBox(width: 14.sp),
          _TVal('In', received, AppColors.getGreenColor),
          SizedBox(width: 12.sp),
          _TVal('Out', disbursed, AppColors.getErrorColor),
          SizedBox(width: 12.sp),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDetails,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BodySmallText(
                    text: 'Details',
                    bold: true,
                    color: AppColors.getPrimaryColor,
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.getPrimaryColor,
                    size: 14,
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

class _TVal extends StatelessWidget {
  const _TVal(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodySmallText(text: label, color: AppColors.getLigthGreyColor),
        CurrencyWidget(
          amount: Utility.doubleFormate(value),
          smallText: true,
          color: color,
        ),
      ],
    );
  }
}

// =============================================================================
// SUMMARY STRIP
// =============================================================================

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.totalReceived,
    required this.totalDisbursed,
  });

  final double totalReceived;
  final double totalDisbursed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Total Received',
            value: totalReceived,
            color: AppColors.getPrimaryColor,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: _SummaryTile(
            label: 'Total Disbursed',
            value: totalDisbursed,
            color: AppColors.getErrorColor,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            width: 22.sp,
            height: 22.sp,
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 0.25.dp),
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodySmallText(text: label, bold: true),
                SizedBox(height: 2.sp),
                CurrencyWidget(
                  amount: value.toStringAsFixed(2),
                  color: color,
                  smallText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TODAY WIDGETS
// =============================================================================

class _SplitGauge extends StatelessWidget {
  const _SplitGauge({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final double total = state.received + state.disbursed;
    final double ratio = total == 0 ? 0.0 : state.received / total;

    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: _AmountTile(
                label: 'Received',
                amount: state.received,
                color: AppColors.getPrimaryColor,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: _AmountTile(
                label: 'Disbursed',
                amount: state.disbursed,
                color: AppColors.getErrorColor,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12.sp,
            child: LayoutBuilder(
              builder: (_, c) {
                return Stack(
                  children: [
                    Container(color: AppColors.getErrorColor.withAlpha(32)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      width: c.maxWidth * ratio,
                      color: AppColors.getPrimaryColor,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(height: 6.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodySmallText(
              text: '${(ratio * 100).toStringAsFixed(0)}% received',
              color: AppColors.getPrimaryColor,
            ),
            BodySmallText(
              text: '${((1 - ratio) * 100).toStringAsFixed(0)}% disbursed',
              error: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              SizedBox(width: 8.sp),
              BodySmallText(text: label, color: color, bold: true),
            ],
          ),
          SizedBox(height: 12.sp),
          CurrencyWidget(
            amount: Utility.doubleFormate(amount),
            color: color,
            smallText: true,
          ),
        ],
      ),
    );
  }
}

class _NetBanner extends StatelessWidget {
  const _NetBanner({required this.net});

  final double net;

  @override
  Widget build(BuildContext context) {
    final bool isPos = net >= 0;
    final Color color = isPos
        ? AppColors.getGreenColor
        : AppColors.getErrorColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        children: [
          Icon(
            isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 16.sp,
          ),
          const SizedBox(width: 8),
          BodySmallText(
            text: 'Net ${isPos ? 'Profit' : 'Deficit'}',
            color: color,
            bold: true,
          ),
          const Spacer(),
          CurrencyWidget(
            amount: Utility.doubleFormate(net),
            color: color,
            smallText: true,
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(height: 12.sp),
          TitleWidget(text: '$count', color: color, bold: true),
          BodySmallText(text: label, color: AppColors.getLigthGreyColor),
          SizedBox(height: 8.sp),
          CurrencyWidget(amount: Utility.doubleFormate(amount), color: color),
        ],
      ),
    );
  }
}

// =============================================================================
// LEGEND DOT
// =============================================================================

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 12.sp, color: color),
        SizedBox(width: 8.sp),
        BodySmallText(text: label, color: AppColors.getLigthGreyColor),
      ],
    );
  }
}

// =============================================================================
// SKELETON + ERROR
// =============================================================================

class _Skeleton extends StatefulWidget {
  const _Skeleton();

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color base = AppColors.getLigthGreyColor.withAlpha(5);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final double op = 0.3 + 0.7 * _ctrl.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _Bone(52, op, base),
              SizedBox(height: 14.sp),
              _Bone(180, op, base),
              SizedBox(height: 14.sp),
              Row(
                children: [
                  Expanded(child: _Bone(58, op, base)),
                  SizedBox(width: 12.sp),
                  Expanded(child: _Bone(58, op, base)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone(this.h, this.op, this.base);

  final double h;
  final double op;
  final Color base;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: base.withAlpha((op * 100).toInt()),
        borderRadius: BorderRadius.circular(12.sp),
      ),
    );
  }
}

class _Err extends StatelessWidget {
  const _Err();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: AppColors.getLigthGreyColor,
            ),
            SizedBox(height: 8),
            BodyTwoDefaultText(text: 'Could not load chart data'),
          ],
        ),
      ),
    );
  }
}
