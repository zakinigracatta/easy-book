import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
