import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Centralized business-timezone conversions for booking UI and availability.
class BusinessClock {
  BusinessClock._();

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    _initialized = true;
  }

  static tz.Location locationFor(String timeZone) {
    _ensureInitialized();
    try {
      return tz.getLocation(timeZone);
    } catch (_) {
      return tz.getLocation('Asia/Dubai');
    }
  }

  static tz.TZDateTime now(String timeZone) {
    return tz.TZDateTime.now(locationFor(timeZone));
  }

  static tz.TZDateTime wallClock(DateTime value, String timeZone) {
    final location = locationFor(timeZone);
    return tz.TZDateTime(
      location,
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
    );
  }

  /// Converts an existing instant to the business timezone without changing it.
  static tz.TZDateTime inTimeZone(DateTime value, String timeZone) {
    return tz.TZDateTime.from(value, locationFor(timeZone));
  }

  /// DatePicker-friendly calendar date representing "today" at the business.
  static DateTime calendarToday(String timeZone) {
    final current = now(timeZone);
    return DateTime(current.year, current.month, current.day);
  }
}
