import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';
import '../entities/transaction.dart' as entity;

class UpdateTransactionUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  UpdateTransactionUseCase({
    required this.transactionRepository,
    required this.accountRepository,
  });

  Future<entity.Transaction> execute(Transaction transaction) async {
    try {
      // Get the existing transaction to calculate balance difference
      final existingTransaction = await transactionRepository.getTransactionsByUser(transaction.userId)
          .then((transactions) => transactions.firstWhere((t) => t.id == transaction.id));
      
      // Update the transaction
      await transactionRepository.updateTransaction(transaction);
      
      // Calculate balance difference
      double balanceDifference = 0;
      if (existingTransaction.type == transaction.type) {
        // Same type - just difference in amount
        if (transaction.type == 'income') {
          balanceDifference = transaction.amount - existingTransaction.amount;
        } else {
          balanceDifference = existingTransaction.amount - transaction.amount;
        }
      } else {
        // Different type - remove old amount and add new amount
        if (existingTransaction.type == 'income') {
          balanceDifference -= existingTransaction.amount;
        } else {
          balanceDifference += existingTransaction.amount;
        }
        
        if (transaction.type == 'income') {
          balanceDifference += transaction.amount;
        } else {
          balanceDifference -= transaction.amount;
        }
      }
      
      // Update account balance
      if (balanceDifference != 0) {
        final db = await transactionRepository.dbProvider.db;
        final List<Map<String, dynamic>> accountMaps = await db.query(
          'accounts',
          where: 'id = ?',
          whereArgs: [transaction.accountId],
        );
        
        if (accountMaps.isNotEmpty) {
          double currentBalance = accountMaps[0]['balance'] as double;
          double newBalance = currentBalance + balanceDifference;
          
          await db.update(
            'accounts',
            {'balance': newBalance},
            where: 'id = ?',
            whereArgs: [transaction.accountId],
          );
        }
      }
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
}