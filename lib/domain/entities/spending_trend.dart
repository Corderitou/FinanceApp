class SpendingTrend {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final Map<String, double> categoryBreakdown; // Category name to amount

  SpendingTrend({
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.categoryBreakdown,
  });

  double get savingsRate => totalIncome > 0 ? (totalIncome - totalExpenses) / totalIncome : 0;

  @override
  String toString() {
    return 'SpendingTrend(period: $periodStart to $periodEnd, income: $totalIncome, expenses: $totalExpenses, net: $netAmount)';
  }
}