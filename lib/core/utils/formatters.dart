import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();
  static String points(int value) =>
      NumberFormat.decimalPattern().format(value);
  static String rewardPoints(int value) =>
      '${points(value.clamp(0, 1 << 62))} pts';
  static String leaderboardScore(num value) =>
      NumberFormat.decimalPattern().format(value);
  static String dateTime(DateTime? value) => value == null
      ? 'Not available'
      : DateFormat.yMMMd().add_jm().format(value.toLocal());
  static String greeting(DateTime now) => now.hour < 12
      ? 'Good morning'
      : now.hour < 18
      ? 'Good afternoon'
      : 'Good evening';
  static String weight(String value, {String unit = 'KG'}) {
    final normalized = value.contains('.')
        ? value
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : value;
    return '$normalized ${unit == 'KG' ? 'kg' : unit.toLowerCase()}';
  }

  static String pointsPerUnit(int? value, String unit) => value == null
      ? 'Rate unavailable'
      : '${points(value)} pts/${unit == 'KG' ? 'kg' : unit.toLowerCase()}';

  static String videoDuration(Duration value) {
    final safe = value.isNegative ? Duration.zero : value;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0
        ? '$hours:$minutes:$seconds'
        : '${safe.inMinutes}:$seconds';
  }

  static String progressPercentage(int value) => '${value.clamp(0, 100)}%';
  static String pointReward(int? value) => value == null
      ? 'Reward unavailable'
      : value == 1
      ? '1 point'
      : '${points(value)} points';
  static String completionDate(DateTime? value) => dateTime(value);
  static String gameScore(int value) =>
      NumberFormat.decimalPattern().format(value);
  static String playCount(int value) => value == 1
      ? '1 play'
      : '${NumberFormat.decimalPattern().format(value)} plays';
  static String dailyGameProgress(int earned, int limit) =>
      '${points(earned)} of ${points(limit)} points';
  static String challengeValue(num value, String unit) =>
      '${NumberFormat.decimalPattern().format(value)} $unit';
  static String challengeDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Schedule unavailable';
    return '${DateFormat.yMMMd().format(start)} – ${DateFormat.yMMMd().format(end)}';
  }

  static String challengePercentage(double value) =>
      '${value.clamp(0, 100).toStringAsFixed(value % 1 == 0 ? 0 : 1)}%';
}
