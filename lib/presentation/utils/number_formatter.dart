import 'package:intl/intl.dart';

class NumberFormatter {
  // Soporte para múltiples monedas
  static final Map<String, NumberFormat> _currencyFormats = {
    'CLP': NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$', // Símbolo de peso chileno
      decimalDigits: 0, // CLP no usa decimales
    ),
    'USD': NumberFormat.currency(
      locale: 'en_US',
      symbol: 'US\$', 
      decimalDigits: 2,
    ),
    'EUR': NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
      decimalDigits: 2,
    ),
    'ARS': NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    ),
  };

  // Formato de moneda compacta para CLP
  static final NumberFormat _compactCurrencyFormatCLP = NumberFormat.compactSimpleCurrency(
    locale: 'es_CL',
    decimalDigits: 0,
  );

  // Formato de moneda compacta para otras monedas
  static final NumberFormat _compactCurrencyFormat = NumberFormat.compactSimpleCurrency(
    locale: 'es_CL', // Usamos es_CL como base
    decimalDigits: 2,
  );

  // Formato numérico general
  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('es_CL');

  /// Formatea un número como moneda con símbolo y separadores
  /// Si no se especifica moneda, se usa CLP por defecto
  static String formatCurrency(double amount, {String currency = 'CLP'}) {
    final format = _currencyFormats[currency];
    if (format != null) {
      return format.format(amount);
    }
    // Fallback al formato CLP si la moneda no está soportada
    return _currencyFormats['CLP']!.format(amount);
  }

  /// Formatea un número como moneda compacta (ej. $1.5K)
  /// Para CLP no usamos decimales, para otras monedas sí
  static String formatCompactCurrency(double amount, {String currency = 'CLP'}) {
    if (currency == 'CLP') {
      return _compactCurrencyFormatCLP.format(amount);
    }
    return _compactCurrencyFormat.format(amount);
  }

  /// Formatea un número con separadores de miles
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  /// Formatea un número como porcentaje
  static String formatPercentage(double value) {
    final percentFormat = NumberFormat.percentPattern('es_CL');
    return percentFormat.format(value);
  }

  /// Formatea un número con decimales fijos
  static String formatDecimal(double value, {int decimalDigits = 2}) {
    final decimalFormat = NumberFormat()
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return decimalFormat.format(value);
  }
  
  /// Obtiene el código de moneda actual (CLP por defecto)
  static String getCurrentCurrency() {
    return 'CLP';
  }
}