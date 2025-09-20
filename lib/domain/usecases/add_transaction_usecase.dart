import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/account_repository.dart';
import '../entities/transaction.dart' as entity;

class AddTransactionUseCase {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  AddTransactionUseCase({
    required this.transactionRepository,
    required this.accountRepository,
  });

  Future<entity.Transaction> execute(Transaction transaction) async {
    try {
      // Insert the transaction
      final id = await transactionRepository.insertTransaction(transaction);
      
      // Update account balance
      await transactionRepository.updateAccountBalance(
        transaction.accountId,
        transaction.amount,
        transaction.type,
      );
      
      // Return the transaction with the new ID
      return transaction.copyWith(id: id);
    } catch (e) {
      // Handle error appropriately
      throw Exception('Failed to add transaction: $e');
    }
  }
}