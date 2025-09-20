import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_AR', // Argentina locale for Spanish formatting
    symbol: '\$', // Dollar symbol
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.compactSimpleCurrency(
    locale: 'es_AR',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('es_AR');

  /// Formatea un número como moneda con símbolo y separadores
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formatea un número como moneda compacta (ej. $1.5K)
  static String formatCompactCurrency(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  /// Formatea un número con separadores de miles
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  /// Formatea un número como porcentaje
  static String formatPercentage(double value) {
    final percentFormat = NumberFormat.percentPattern('es_AR');
    return percentFormat.format(value);
  }

  /// Formatea un número con decimales fijos
  static String formatDecimal(double value, {int decimalDigits = 2}) {
    final decimalFormat = NumberFormat()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return decimalFormat.format(value);
  }
}