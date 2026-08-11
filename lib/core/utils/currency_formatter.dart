class CurrencyFormatter {
  static String format(double price,
      {String currency = 'AED', bool includeDecimals = false}) {
    final formattedPrice = includeDecimals || price % 1 != 0
        ? price.toStringAsFixed(2)
        : price.toInt().toString();
    return '$currency $formattedPrice';
  }
}
