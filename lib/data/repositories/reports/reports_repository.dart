import 'package:sqflite/sqflite.dart';
import '../../../domain/reports/work_location_report_models.dart';
import '../../database/database_helper.dart';
import '../../../domain/reports/report_models.dart';
import '../../../domain/entities/category.dart' as entity;

class ReportsRepository {
  final dbProvider = DatabaseHelper.instance;

  /// Get expenses by category for a given user
  Future<List<CategoryExpense>> getCategoryExpenses(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'expense'
      GROUP BY c.id
      ORDER BY total DESC
    ''', [userId]);

    return result.map((row) {
      return CategoryExpense(
        categoryName: row['name'] as String,
        amount: row['total'] as double,
        color: row['color'] as String? ?? '#CCCCCC',
      );
    }).toList();
  }

  /// Get income by category for a given user
  Future<List<CategoryIncome>> getCategoryIncome(int userId) async {
    final db = await dbProvider.db;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'income'
      GROUP BY c.id
      ORDER BY total DESC
    ''', [userId]);

    return result.map((row) {
      return CategoryIncome(
        categoryName: row['name'] as String,
        amount: row['total'] as double,
        color: row['color'] as String? ?? '#CCCCCC',
      );
    }).toList();
  }

  /// Get income vs expense data for a given period
  Future<IncomeVsExpense> getIncomeVsExpense(
      int userId, DateTime start, DateTime end) async {
    final db = await dbProvider.db;
    
    // Get total income
    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE user_id = ? AND type = 'income' AND date BETWEEN ? AND ?
    ''', [userId, start.toIso8601String(), end.toIso8601String()]);
    
    final income = incomeResult[0]['total'] as double? ?? 0.0;
    
    // Get total expenses
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM transactions
      WHERE user_id = ? AND type = 'expense' AND date BETWEEN ? AND ?
    ''', [userId, start.toIso8601String(), end.toIso8601String()]);
    
    final expense = expenseResult[0]['total'] as double? ?? 0.0;
    
    return IncomeVsExpense(
      income: income,
      expense: expense,
      periodStart: start,
      periodEnd: end,
    );
  }

  /// Get balance evolution over time
  Future<List<BalanceEvolutionPoint>> getBalanceEvolution(int userId) async {
    final db = await dbProvider.db;
    
    // Get all transactions ordered by date
    final List<Map<String, dynamic>> transactions = await db.rawQuery('''
      SELECT date, amount, type
      FROM transactions
      WHERE user_id = ?
      ORDER BY date ASC
    ''', [userId]);
    
    List<BalanceEvolutionPoint> points = [];
    double runningBalance = 0.0;
    
    for (var transaction in transactions) {
      final amount = transaction['amount'] as double;
      final type = transaction['type'] as String;
      final date = DateTime.parse(transaction['date'] as String);
      
      if (type == 'income') {
        runningBalance += amount;
      } else {
        runningBalance -= amount;
      }
      
      points.add(BalanceEvolutionPoint(
        date: date,
        balance: runningBalance,
      ));
    }
    
    return points;
  }

  /// Get financial summary
  Future<FinancialSummary> getFinancialSummary(int userId) async {
    final db = await dbProvider.db;
    
    // Get total income
    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total, COUNT(*) as count
      FROM transactions
      WHERE user_id = ? AND type = 'income'
    ''', [userId]);
    
    final totalIncome = incomeResult[0]['total'] as double? ?? 0.0;
    final incomeCount = incomeResult[0]['count'] as int? ?? 1;
    final averageIncome = totalIncome / (incomeCount == 0 ? 1 : incomeCount);
    
    // Get total expenses
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total, COUNT(*) as count
      FROM transactions
      WHERE user_id = ? AND type = 'expense'
    ''', [userId]);
    
    final totalExpense = expenseResult[0]['total'] as double? ?? 0.0;
    final expenseCount = expenseResult[0]['count'] as int? ?? 1;
    final averageExpense = totalExpense / (expenseCount == 0 ? 1 : expenseCount);
    
    final balance = totalIncome - totalExpense;
    
    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      averageIncome: averageIncome,
      averageExpense: averageExpense,
    );
  }

  /// Get work location frequency data for a given period
  Future<WorkLocationReportData> getWorkLocationReport(
      int userId, DateTime start, DateTime end) async {
    final db = await dbProvider.db;
    
    // Get all work locations for the user within the date range
    final List<Map<String, dynamic>> locations = await db.rawQuery('''
      SELECT name, date
      FROM work_locations
      WHERE user_id = ? AND date BETWEEN ? AND ?
      ORDER BY date ASC
    ''', [userId, start.toIso8601String(), end.toIso8601String()]);
    
    // Group by name and calculate frequency, first and last visit
    final Map<String, List<DateTime>> locationDates = {};
    for (var location in locations) {
      final name = location['name'] as String;
      final date = DateTime.parse(location['date'] as String);
      
      if (!locationDates.containsKey(name)) {
        locationDates[name] = [];
      }
      locationDates[name]!.add(date);
    }
    
    // Convert to WorkLocationFrequency objects
    final locationFrequencies = locationDates.entries.map((entry) {
      final dates = entry.value;
      dates.sort();
      
      return WorkLocationFrequency(
        locationName: entry.key,
        frequency: dates.length,
        firstVisit: dates.first,
        lastVisit: dates.last,
      );
    }).toList();
    
    // Sort by frequency (most frequent first)
    locationFrequencies.sort((a, b) => b.frequency.compareTo(a.frequency));
    
    return WorkLocationReportData(
      locations: locationFrequencies,
      startDate: start,
      endDate: end,
      totalVisits: locations.length,
    );
  }
}