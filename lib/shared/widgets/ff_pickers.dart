import 'package:flutter/material.dart';

/// The app's date and time pickers. Calling these instead of the Material
/// functions directly keeps every picker on the same theme (dialog shape and
/// colours come from `FfTheme`) and gives one place to change picker
/// behaviour.

/// Lets the user pick one day. Resolves to null when cancelled.
Future<DateTime?> pickFfDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? helpText,
}) {
  return showDatePicker(
    context: context,
    initialDate: _clamp(initialDate, firstDate, lastDate),
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
  );
}

/// Lets the user pick a start and end day. Resolves to null when cancelled.
Future<DateTimeRange?> pickFfDateRange(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  String? helpText,
}) {
  return showDateRangePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    helpText: helpText,
  );
}

/// Lets the user pick a time of day. Resolves to null when cancelled.
Future<TimeOfDay?> pickFfTime(
  BuildContext context, {
  required TimeOfDay initialTime,
  String? helpText,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
  );
}

// showDatePicker asserts that initialDate is inside the range. Some callers
// derive the range from other fields (a due date must follow its start date),
// so clamp instead of crashing when the stored value falls outside it.
DateTime _clamp(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) return first;
  if (value.isAfter(last)) return last;
  return value;
}
