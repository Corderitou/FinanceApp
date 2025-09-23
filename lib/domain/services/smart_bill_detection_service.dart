import '../../domain/entities/transaction.dart';
import '../../domain/entities/bill.dart';

class SmartBillDetectionService {
  /// Detects potential bills from transactions based on patterns
  List<Bill> detectBillsFromTransactions(List<Transaction> transactions) {
    final potentialBills = <Bill>[];
    
    // Group transactions by description patterns
    final transactionGroups = <String, List<Transaction>>{};
    
    for (var transaction in transactions) {
      if (transaction.description != null) {
        // Normalize description by removing numbers and special characters
        final normalizedDesc = _normalizeDescription(transaction.description!);
        
        if (transactionGroups.containsKey(normalizedDesc)) {
          transactionGroups[normalizedDesc]!.add(transaction);
        } else {
          transactionGroups[normalizedDesc] = [transaction];
        }
      }
    }
    
    // Identify potential recurring bills
    transactionGroups.forEach((description, transList) {
      // Check if this looks like a recurring bill
      if (_isPotentialBill(transList)) {
        final averageAmount = _calculateAverageAmount(transList);
        final likelyDay = _getMostCommonDay(transList);
        
        // Create a potential bill
        final bill = Bill(
          userId: transList.first.userId,
          name: description,
          description: 'Potential bill detected from transactions',
          amount: averageAmount,
          dayOfMonth: likelyDay,
          frequency: 'monthly',
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        potentialBills.add(bill);
      }
    });
    
    return potentialBills;
  }
  
  /// Normalizes a description by removing numbers and special characters
  String _normalizeDescription(String description) {
    // Remove numbers, special characters, and extra whitespace
    return description
        .toLowerCase()
        .replaceAll(RegExp(r'[0-9]'), '') // Remove numbers
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
  }
  
  /// Determines if a list of transactions represents a potential bill
  bool _isPotentialBill(List<Transaction> transactions) {
    // Must have at least 3 transactions to establish a pattern
    if (transactions.length < 3) return false;
    
    // Check if transactions occur at regular intervals (monthly)
    final dates = transactions.map((t) => t.date).toList()..sort();
    
    // Calculate average days between transactions
    int totalDays = 0;
    for (int i = 1; i < dates.length; i++) {
      totalDays += dates[i].difference(dates[i-1]).inDays;
    }
    
    final averageDays = totalDays / (dates.length - 1);
    
    // If average is roughly monthly (25-35 days), consider it a potential bill
    return averageDays >= 25 && averageDays <= 35;
  }
  
  /// Calculates the average amount of transactions
  double _calculateAverageAmount(List<Transaction> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total / transactions.length;
  }
  
  /// Gets the most common day of month for transactions
  int _getMostCommonDay(List<Transaction> transactions) {
    final dayCounts = <int, int>{};
    
    for (var transaction in transactions) {
      final day = transaction.date.day;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    
    // Find the day with the highest count
    int mostCommonDay = transactions.first.date.day;
    int highestCount = 0;
    
    dayCounts.forEach((day, count) {
      if (count > highestCount) {
        mostCommonDay = day;
        highestCount = count;
      }
    });
    
    return mostCommonDay;
  }
}