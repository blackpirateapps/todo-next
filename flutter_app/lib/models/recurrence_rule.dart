enum RecurrenceUnit { d, w, m, y, weekday, mwf }
enum RecurrenceMode { completion, strict }

class RecurrenceRule {
  final String raw;
  final int interval;
  final RecurrenceUnit unit;
  final RecurrenceMode mode;

  RecurrenceRule({
    required this.raw,
    required this.interval,
    required this.unit,
    required this.mode,
  });
}
