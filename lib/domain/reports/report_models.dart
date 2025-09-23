class CategoryExpense {
  final String categoryName;
  final double amount;
  final String color;

  CategoryExpense({
    required this.categoryName,
    required this.amount,
    required this.color,
  });
}

class CategoryIncome {
  final String categoryName;
  final double amount;
  final String color;

  CategoryIncome({
    required this.categoryName,
    required this.amount,
    required this.color,
  });
}

class IncomeVsExpense {
  final double income;
  final double expense;
  final DateTime periodStart;
  final DateTime periodEnd;

  IncomeVsExpense({
    required this.income,
    required this.expense,
    required this.periodStart,
    required this.periodEnd,
  });
}

class BalanceEvolutionPoint {
  final DateTime date;
  final double balance;

  BalanceEvolutionPoint({
    required this.date,
    required this.balance,
  });
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double averageIncome;
  final double averageExpense;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.averageIncome,
    required this.averageExpense,
  });
}