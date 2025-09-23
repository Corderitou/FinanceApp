import '../../domain/entities/transaction.dart';
import '../../domain/entities/bill.dart';

class PaymentHistoryService {
  /// Links a transaction to a bill payment
  Map<String, dynamic> createBillPaymentLink(int billId, int transactionId) {
    return {
      'bill_id': billId,
      'transaction_id': transactionId,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Gets payment history for a specific bill
  List<Transaction> getPaymentHistoryForBill(List<Transaction> allTransactions, Bill bill) {
    // In a real implementation, this would join with a bill_payments table
    // For now, we'll filter transactions that match the bill's criteria
    return allTransactions.where((transaction) {
      // Match by description pattern
      if (bill.name.isNotEmpty && transaction.description != null) {
        return transaction.description!.toLowerCase().contains(bill.name.toLowerCase());
      }
      return false;
    }).toList();
  }

  /// Calculates payment statistics for a bill
  BillPaymentStats calculatePaymentStats(List<Transaction> paymentHistory) {
    if (paymentHistory.isEmpty) {
      return BillPaymentStats(
        totalPayments: 0,
        averageAmount: 0.0,
        onTimePayments: 0,
        latePayments: 0,
        averageDaysLate: 0.0,
      );
    }

    double totalAmount = 0.0;
    int onTime = 0;
    int late = 0;
    int totalDaysLate = 0;

    for (var payment in paymentHistory) {
      totalAmount += payment.amount;
      
      // In a real implementation, we would compare payment date to due date
      // For now, we'll just mark all as on-time
      onTime++;
    }

    return BillPaymentStats(
      totalPayments: paymentHistory.length,
      averageAmount: totalAmount / paymentHistory.length,
      onTimePayments: onTime,
      latePayments: late,
      averageDaysLate: paymentHistory.isEmpty ? 0.0 : totalDaysLate / paymentHistory.length,
    );
  }

  /// Forecasts next payment amount based on history
  double forecastNextPaymentAmount(List<Transaction> paymentHistory) {
    if (paymentHistory.isEmpty) return 0.0;
    
    // Simple average of last 3 payments
    final recentPayments = paymentHistory.length > 3 
        ? paymentHistory.sublist(paymentHistory.length - 3) 
        : paymentHistory;
    
    double total = 0.0;
    for (var payment in recentPayments) {
      total += payment.amount;
    }
    
    return total / recentPayments.length;
  }

  /// Forecasts next payment date
  DateTime? forecastNextPaymentDate(Bill bill) {
    final now = DateTime.now();
    
    if (bill.dueDate != null) {
      // If it's a one-time bill and due date is in the past, no future payment
      if (bill.frequency == 'once' && bill.dueDate!.isBefore(now)) {
        return null;
      }
      
      // If due date is in the future, that's our next payment date
      if (bill.dueDate!.isAfter(now)) {
        return bill.dueDate;
      }
      
      // For recurring bills, calculate next occurrence
      return _calculateNextDueDate(bill, bill.dueDate!);
    } else if (bill.dayOfMonth != null) {
      // Calculate next due date based on day of month
      return _calculateNextDueDateByDay(bill, now);
    }
    
    return null;
  }

  /// Calculate next due date for a recurring bill
  DateTime _calculateNextDueDate(Bill bill, DateTime lastDueDate) {
    switch (bill.frequency) {
      case 'monthly':
        return DateTime(lastDueDate.year, lastDueDate.month + 1, lastDueDate.day);
      case 'quarterly':
        return DateTime(lastDueDate.year, lastDueDate.month + 3, lastDueDate.day);
      case 'yearly':
        return DateTime(lastDueDate.year + 1, lastDueDate.month, lastDueDate.day);
      default:
        return lastDueDate.add(const Duration(days: 30));
    }
  }

  /// Calculate next due date by day of month
  DateTime _calculateNextDueDateByDay(Bill bill, DateTime now) {
    final dayOfMonth = bill.dayOfMonth!;
    
    // Create date for this month
    var scheduledDate = DateTime(now.year, now.month, dayOfMonth);
    
    // If this month's date is in the past, use next month
    if (scheduledDate.isBefore(now)) {
      var nextMonth = now.month + 1;
      var nextYear = now.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      scheduledDate = DateTime(nextYear, nextMonth, dayOfMonth);
    }
    
    return scheduledDate;
  }
}

class BillPaymentStats {
  final int totalPayments;
  final double averageAmount;
  final int onTimePayments;
  final int latePayments;
  final double averageDaysLate;

  BillPaymentStats({
    required this.totalPayments,
    required this.averageAmount,
    required this.onTimePayments,
    required this.latePayments,
    required this.averageDaysLate,
  });
}