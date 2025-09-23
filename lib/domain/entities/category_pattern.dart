class CategoryPattern {
  final int categoryId;
  final String categoryName;
  final double averageAmount;
  final double percentageOfTotal;
  final int transactionCount;
  final List<double> monthlyAmounts; // Last 12 months of spending
  final double trend; // Positive = increasing, negative = decreasing

  CategoryPattern({
    required this.categoryId,
    required this.categoryName,
    required this.averageAmount,
    required this.percentageOfTotal,
    required this.transactionCount,
    required this.monthlyAmounts,
    required this.trend,
  });

  bool get isIncreasing => trend > 0;
  bool get isDecreasing => trend < 0;
  bool get isStable => trend == 0;

  @override
  String toString() {
    return 'CategoryPattern(name: $categoryName, average: $averageAmount, trend: $trend)';
  }
}