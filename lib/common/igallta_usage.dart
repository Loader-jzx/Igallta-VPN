import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three traffic totals the Igallta home shows.
@immutable
class IgalltaUsageSnapshot {
  const IgalltaUsageSnapshot({this.day = 0, this.month = 0, this.total = 0});

  final int day;
  final int month;
  final int total;

  IgalltaUsageSnapshot copyWith({int? day, int? month, int? total}) {
    return IgalltaUsageSnapshot(
      day: day ?? this.day,
      month: month ?? this.month,
      total: total ?? this.total,
    );
  }
}

/// Accumulates the Core's monotonically increasing traffic counter into
/// today / this month / all-time totals that survive app restarts.
///
/// The Core reports a session total. This turns changes of that number into
/// deltas, so restarting the app (and the Core) does not throw the totals away
/// or count the same bytes twice.
class IgalltaUsage {
  IgalltaUsage._();

  static final IgalltaUsage instance = IgalltaUsage._();

  static const _dayKey = 'igallta.usage.day';
  static const _monthKey = 'igallta.usage.month';
  static const _totalKey = 'igallta.usage.total';
  static const _dayStampKey = 'igallta.usage.dayStamp';
  static const _monthStampKey = 'igallta.usage.monthStamp';

  final ValueNotifier<IgalltaUsageSnapshot> notifier = ValueNotifier(
    const IgalltaUsageSnapshot(),
  );

  bool _loaded = false;
  int? _lastCoreTotal;
  String? _loadedDay;
  String? _loadedMonth;
  Timer? _saveTimer;

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dayStamp(DateTime.now());
      final thisMonth = _monthStamp(DateTime.now());
      var day = prefs.getInt(_dayKey) ?? 0;
      var month = prefs.getInt(_monthKey) ?? 0;
      var total = prefs.getInt(_totalKey) ?? 0;
      if (prefs.getString(_dayStampKey) != today) {
        day = 0;
      }
      if (prefs.getString(_monthStampKey) != thisMonth) {
        month = 0;
      }
      _loadedDay = today;
      _loadedMonth = thisMonth;
      notifier.value = IgalltaUsageSnapshot(
        day: day,
        month: month,
        total: total,
      );
    } catch (_) {
      // Preferences are an optional cache; the UI can still show zeros.
    }
  }

  Future<void> record(num coreTotal) async {
    await ensureLoaded();
    final now = DateTime.now();
    final snapshot = notifier.value;
    final today = _dayStamp(now);
    final thisMonth = _monthStamp(now);
    var day = snapshot.day;
    var month = snapshot.month;
    var total = snapshot.total;
    if (_loadedDay != null && _loadedDay != today) {
      day = 0;
    }
    if (_loadedMonth != null && _loadedMonth != thisMonth) {
      month = 0;
    }
    _loadedDay = today;
    _loadedMonth = thisMonth;

    final current = coreTotal.round();
    final last = _lastCoreTotal;
    if (last != null && current > last) {
      final delta = current - last;
      day += delta;
      month += delta;
      total += delta;
    }
    _lastCoreTotal = current;

    notifier.value = IgalltaUsageSnapshot(day: day, month: month, total: total);
    _scheduleSave(now);
  }

  void _scheduleSave(DateTime now) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 3), () {
      unawaited(_save(now));
    });
  }

  Future<void> _save(DateTime now) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshot = notifier.value;
      await prefs.setInt(_dayKey, snapshot.day);
      await prefs.setInt(_monthKey, snapshot.month);
      await prefs.setInt(_totalKey, snapshot.total);
      await prefs.setString(_dayStampKey, _dayStamp(now));
      await prefs.setString(_monthStampKey, _monthStamp(now));
    } catch (_) {
      // Ignore a failed cache write; the next save retries it.
    }
  }

  static String _dayStamp(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static String _monthStamp(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}';
  }
}

String igalltaBytes(num bytes) {
  if (bytes <= 0) {
    return '0 B';
  }
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final digits = value >= 100
      ? 0
      : value >= 10
      ? 1
      : 2;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}
