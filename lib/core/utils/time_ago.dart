// ─────────────────────────────────────────────────────────────────────────────
// File    : lib/core/utils/time_ago.dart
// Layer   : Core
// Purpose : Formats a millisecond timestamp as relative time.
//           shortAgo -> "now", "5m", "3h", "2d"   (comments)
//           longAgo  -> "Just now", "3h ago"      (post footer)
// ─────────────────────────────────────────────────────────────────────────────

String shortAgo(int timestampMs) {
  final minutes = DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(timestampMs))
      .inMinutes;
  if (minutes < 1) return 'now';
  if (minutes < 60) return '${minutes}m';
  if (minutes < 1440) return '${minutes ~/ 60}h';
  return '${minutes ~/ 1440}d';
}

String longAgo(int timestampMs) {
  final short = shortAgo(timestampMs);
  return short == 'now' ? 'Just now' : '$short ago';
}
