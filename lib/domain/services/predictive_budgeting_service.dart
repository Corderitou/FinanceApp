import 'dart:math';
import '../domain/entities/transaction.dart';
import '../domain/entities/budget_forecast.dart';

class PredictiveBudgetingService {
  /// Generate budget forecasts based on historical data
  List<BudgetForecast> generateForecasts(List<Transaction> transactions, int monthsAhead) {
    final forecasts = <BudgetForecast>[];
    
    // Group transactions by month
    final monthlyData = _groupTransactionsByMonth(transactions);
    
    // Get the most recent month as baseline
    final sortedMonths = monthlyData.keys.toList()..sort();
    if (sortedMonths.isEmpty) return forecasts;
    
    final latestMonth = sortedMonths.last;
    final baselineData = monthlyData[latestMonth]!;
    
    // Calculate baseline averages
    double avgIncome = 0, avgExpenses = 0;
    final categoryAverages = <String, double>{};
    
    for (var data in baselineData) {
      if (data.type == 'income') {
        avgIncome += data.amount;
      } else {
        avgExpenses += data.amount;
      }
      
      // Add to category averages
      final categoryName = data.categoryName;
      if (categoryAverages.containsKey(categoryName)) {
        categoryAverages[categoryName] = categoryAverages[categoryName]! + data.amount;
      } else {
        categoryAverages[categoryName] = data.amount;
      }
    }
    
    // Average the category amounts
    categoryAverages.updateAll((key, value) => value / baselineData.length);
    
    // Generate forecasts for each month ahead
    for (int i = 1; i <= monthsAhead; i++) {
      final forecastDate = DateTime(latestMonth.year, latestMonth.month + i);
      
      // Apply some randomness to make forecasts more realistic
      final incomeVariation = 1.0 + (Random().nextDouble() * 0.2 - 0.1); // ±10%
      final expenseVariation = 1.0 + (Random().nextDouble() * 0.3 - 0.15); // ±15%
      
      final predictedIncome = avgIncome * incomeVariation;
      final predictedExpenses = avgExpenses * expenseVariation;
      final predictedSavings = predictedIncome - predictedExpenses;
      
      // Apply category variations
      final categoryPredictions = <String, double>{};
      categoryAverages.forEach((category, average) {
        final variation = 1.0 + (Random().nextDouble() * 0.2 - 0.1); // ±10%
        categoryPredictions[category] = average * variation;
      });
      
      // Confidence decreases with time (simplified model)
      final confidence = max(0.5, 1.0 - (i * 0.1));
      
      forecasts.add(BudgetForecast(
        forecastDate: forecastDate,
        predictedIncome: predictedIncome,
        predictedExpenses: predictedExpenses,
        predictedSavings: predictedSavings,
        categoryPredictions: categoryPredictions,
        confidence: confidence,
      ));
    }
    
    return forecasts;
  }
  
  /// Group transactions by month
  Map<DateTime, List<_MonthlyTransactionData>> _groupTransactionsByMonth(List<Transaction> transactions) {
    final grouped = <DateTime, List<_MonthlyTransactionData>>{};
    
    for (var transaction in transactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      final data = _MonthlyTransactionData(
        amount: transaction.amount,
        type: transaction.type,
        categoryName: transaction.description ?? 'Uncategorized', // Simplified
      );
      
      if (grouped.containsKey(monthKey)) {
        grouped[monthKey]!.add(data);
      } else {
        grouped[monthKey] = [data];
      }
    }
    
    return grouped;
  }
}

/// Helper class for monthly transaction data
class _MonthlyTransactionData {
  final double amount;
  final String type; // 'income' or 'expense'
  final String categoryName;
  
  _MonthlyTransactionData({
    required this.amount,
    required this.type,
    required this.categoryName,
  });
}