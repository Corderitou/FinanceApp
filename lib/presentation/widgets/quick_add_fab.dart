import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';

class QuickAddFab extends StatelessWidget {
  final VoidCallback onQuickAddIncome;
  final VoidCallback onQuickAddExpense;
  final VoidCallback onAddTransaction;

  const QuickAddFab({
    Key? key,
    required this.onQuickAddIncome,
    required this.onQuickAddExpense,
    required this.onAddTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.green),
                    title: const Text('Quick Add Income'),
                    onTap: () {
                      Navigator.pop(context);
                      onQuickAddIncome();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.remove, color: Colors.red),
                    title: const Text('Quick Add Expense'),
                    onTap: () {
                      Navigator.pop(context);
                      onQuickAddExpense();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Add Transaction'),
                    onTap: () {
                      Navigator.pop(context);
                      onAddTransaction();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class SmartDefaultsService {
  /// Get smart defaults for a new transaction based on user history
  Future<TransactionDefaults> getSmartDefaults(int userId) async {
    // In a real implementation, this would analyze the user's transaction history
    // For now, we'll return mock defaults
    
    // Simulate data analysis
    await Future.delayed(const Duration(milliseconds: 300));
    
    return TransactionDefaults(
      accountId: 1, // Most used account
      categoryId: 2, // Most common category
      amount: 25.0, // Average transaction amount
      type: 'expense',
    );
  }

  /// Learn from user input to improve future defaults
  void learnFromTransaction(Transaction transaction) {
    // In a real implementation, this would update the user's preference model
    // For now, this is a placeholder
    print('Learning from transaction: ${transaction.description}');
  }
}

class TransactionDefaults {
  final int accountId;
  final int categoryId;
  final double amount;
  final String type;

  TransactionDefaults({
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
  });
}

class QuickTransactionDialog extends StatefulWidget {
  final TransactionDefaults defaults;
  final Function(Transaction) onTransactionCreated;

  const QuickTransactionDialog({
    Key? key,
    required this.defaults,
    required this.onTransactionCreated,
  }) : super(key: key);

  @override
  _QuickTransactionDialogState createState() => _QuickTransactionDialogState();
}

class _QuickTransactionDialogState extends State<QuickTransactionDialog> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late int _selectedAccountId;
  late int _selectedCategoryId;
  late String _type;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.defaults.amount.toString());
    _descriptionController = TextEditingController();
    _selectedAccountId = widget.defaults.accountId;
    _selectedCategoryId = widget.defaults.categoryId;
    _type = widget.defaults.type;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTransaction() {
    if (_amountController.text.isNotEmpty) {
      final transaction = Transaction(
        userId: 1, // TODO: Get actual user ID
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        type: _type,
        description: _descriptionController.text,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onTransactionCreated(transaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Add Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTransaction,
          child: const Text('Add'),
        ),
      ],
    );
  }
}