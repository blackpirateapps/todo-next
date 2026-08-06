import 'package:intl/intl.dart';

const List<String> monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

const List<String> weekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

String formatDateISO(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

List<DateTime> getMonthDays(int year, int monthIndex) {
  final List<DateTime> days = [];
  final firstDayOfMonth = DateTime(year, monthIndex + 1, 1);
  final startDayOfWeek = firstDayOfMonth.weekday % 7; // 0 (Sun) to 6 (Sat)

  final startDate = DateTime(year, monthIndex + 1, 1 - startDayOfWeek);

  for (int i = 0; i < 42; i++) {
    days.add(DateTime(startDate.year, startDate.month, startDate.day + i));
  }

  return days;
}

List<DateTime> getWeekDays(DateTime referenceDate) {
  final List<DateTime> days = [];
  final dayOfWeek = referenceDate.weekday % 7; // 0 (Sun) to 6 (Sat)
  final sunday = DateTime(referenceDate.year, referenceDate.month, referenceDate.day - dayOfWeek);

  for (int i = 0; i < 7; i++) {
    days.add(DateTime(sunday.year, sunday.month, sunday.day + i));
  }

  return days;
}
