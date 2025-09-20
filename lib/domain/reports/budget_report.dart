class BudgetReport {
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentage;
  final DateTime periodStart;
  final DateTime periodEnd;

  BudgetReport({
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentage,
    required this.periodStart,
    required this.periodEnd,
  });
}