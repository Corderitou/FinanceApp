import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  DeleteTransactionUseCase({
    required this.transactionRepository,
    required this.accountRepository,
  });

  Future<bool> execute(int transactionId, int accountId, double amount, String type) async {
    try {
      // Delete the transaction
      final result = await transactionRepository.deleteTransaction(transactionId);
      
      if (result > 0) {
        // Reverse the account balance update
        await transactionRepository.updateAccountBalance(
          accountId,
          amount,
          type == 'income' ? 'expense' : 'income', // Reverse the operation
        );
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}