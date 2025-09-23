class BudgetForecast {
  final DateTime forecastDate;
  final double predictedIncome;
  final double predictedExpenses;
  final double predictedSavings;
  final Map<String, double> categoryPredictions;
  final double confidence; // 0.0 to 1.0

  BudgetForecast({
    required this.forecastDate,
    required this.predictedIncome,
    required this.predictedExpenses,
    required this.predictedSavings,
    required this.categoryPredictions,
    required this.confidence,
  });

  double get savingsRate => predictedIncome > 0 ? predictedSavings / predictedIncome : 0;

  @override
  String toString() {
    return 'BudgetForecast(date: $forecastDate, income: $predictedIncome, expenses: $predictedExpenses, savings: $predictedSavings, confidence: $confidence)';
  }
}