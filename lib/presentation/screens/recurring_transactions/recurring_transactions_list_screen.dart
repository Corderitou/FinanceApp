import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import 'recurring_transaction_form_screen.dart';

class RecurringTransactionsListScreen extends ConsumerStatefulWidget {
  const RecurringTransactionsListScreen({Key? key}) : super(key: key);

  @override
  _RecurringTransactionsListScreenState createState() => _RecurringTransactionsListScreenState();
}

class _RecurringTransactionsListScreenState extends ConsumerState<RecurringTransactionsListScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(recurringTransactionProvider.notifier).loadRecurringTransactions(1); // TODO: Use actual user ID
  }

  @override
  Widget build(BuildContext context) {
    final recurringTransactionsState = ref.watch(recurringTransactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecurringTransactionFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: recurringTransactionsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : recurringTransactionsState.recurringTransactions.isEmpty
              ? const Center(
                  child: Text('No recurring transactions yet'),
                )
              : ListView.builder(
                  itemCount: recurringTransactionsState.recurringTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recurringTransactionsState.recurringTransactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(transaction.description ?? 'No description'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: transaction.type == 'income' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transaction.frequency.capitalize()} starting ${transaction.startDate.toString().split(' ').first}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (transaction.endDate != null)
                              Text(
                                'Ends ${transaction.endDate.toString().split(' ').first}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Switch(
                          value: transaction.isActive,
                          onChanged: (value) {
                            final updated = transaction.copyWith(
                              isActive: value,
                              updatedAt: DateTime.now(),
                            );
                            ref.read(recurringTransactionProvider.notifier).updateRecurringTransaction(updated);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RecurringTransactionFormScreen(transaction: transaction),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context, transaction);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, RecurringTransaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recurring Transaction'),
          content: Text('Are you sure you want to delete "${transaction.description}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(recurringTransactionProvider.notifier).deleteRecurringTransaction(
                      transaction.id!,
                      transaction.userId,
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

extension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}