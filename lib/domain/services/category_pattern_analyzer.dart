import 'dart:math';
import '../domain/entities/transaction.dart';
import '../domain/entities/category_pattern.dart';

class CategoryPatternAnalyzer {
  /// Analyze spending patterns by category
  List<CategoryPattern> analyzeCategoryPatterns(List<Transaction> transactions, DateTime startDate, DateTime endDate) {
    // Filter transactions by date range
    final filteredTransactions = transactions.where((t) => 
      t.date.isAfter(startDate) && t.date.isBefore(endDate)
    ).toList();

    // Group transactions by category
    final categoryTransactions = <int, List<Transaction>>{};
    for (var transaction in filteredTransactions) {
      if (categoryTransactions.containsKey(transaction.categoryId)) {
        categoryTransactions[transaction.categoryId]!.add(transaction);
      } else {
        categoryTransactions[transaction.categoryId] = [transaction];
      }
    }

    // Calculate patterns for each category
    final patterns = <CategoryPattern>[];
    final totalAmount = filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

    categoryTransactions.forEach((categoryId, transactions) {
      // Calculate basic stats
      final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
      final count = transactions.length;
      final average = count > 0 ? total / count : 0;
      final percentage = totalAmount > 0 ? (total / totalAmount) * 100 : 0;

      // Calculate monthly amounts for the last 12 months
      final monthlyAmounts = _calculateMonthlyAmounts(transactions, startDate, endDate);

      // Calculate trend (simplified linear regression)
      final trend = _calculateTrend(monthlyAmounts);

      // Get category name (in a real implementation, this would come from a category repository)
      final categoryName = _getCategoryName(categoryId);

      patterns.add(CategoryPattern(
        categoryId: categoryId,
        categoryName: categoryName,
        averageAmount: average,
        percentageOfTotal: percentage,
        transactionCount: count,
        monthlyAmounts: monthlyAmounts,
        trend: trend,
      ));
    });

    return patterns;
  }

  /// Calculate monthly amounts for the past 12 months
  List<double> _calculateMonthlyAmounts(List<Transaction> transactions, DateTime startDate, DateTime endDate) {
    final monthlyAmounts = List<double>.filled(12, 0.0);
    
    // Group transactions by month
    final monthlyTransactions = <DateTime, List<Transaction>>{};
    for (var transaction in transactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      if (monthlyTransactions.containsKey(monthKey)) {
        monthlyTransactions[monthKey]!.add(transaction);
      } else {
        monthlyTransactions[monthKey] = [transaction];
      }
    }

    // Calculate amounts for each month
    for (int i = 0; i < 12; i++) {
      final month = DateTime(endDate.year, endDate.month - i);
      final monthKey = DateTime(month.year, month.month);
      
      if (monthlyTransactions.containsKey(monthKey)) {
        final monthTotal = monthlyTransactions[monthKey]!
            .fold(0.0, (sum, t) => sum + t.amount);
        monthlyAmounts[11 - i] = monthTotal;
      }
    }

    return monthlyAmounts;
  }

  /// Calculate trend using simplified linear regression
  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    // Simple linear regression calculation
    final n = values.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;

    for (int i = 0; i < values.length; i++) {
      final x = i.toDouble();
      final y = values[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final numerator = n * sumXY - sumX * sumY;
    final denominator = n * sumXX - sumX * sumX;

    if (denominator == 0) return 0.0;

    return numerator / denominator;
  }

  /// Get category name (in a real implementation, this would come from a category repository)
  String _getCategoryName(int categoryId) {
    // This is a placeholder implementation
    final categoryNames = {
      1: 'Salary',
      2: 'Food',
      3: 'Transport',
      4: 'Entertainment',
      5: 'Utilities',
      6: 'Healthcare',
      7: 'Shopping',
      8: 'Travel',
      9: 'Education',
      10: 'Other'
    };

    return categoryNames[categoryId] ?? 'Unknown Category';
  }
}