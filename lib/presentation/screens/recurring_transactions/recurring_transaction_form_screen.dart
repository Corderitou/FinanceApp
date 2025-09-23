import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/recurring_transaction_provider.dart';

class RecurringTransactionFormScreen extends ConsumerStatefulWidget {
  final RecurringTransaction? transaction;

  const RecurringTransactionFormScreen({Key? key, this.transaction}) : super(key: key);

  @override
  _RecurringTransactionFormScreenState createState() => _RecurringTransactionFormScreenState();
}

class _RecurringTransactionFormScreenState extends ConsumerState<RecurringTransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late int _selectedAccountId;
  late int _selectedCategoryId;
  late String _type;
  late String _frequency;
  late DateTime _startDate;
  late DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController = TextEditingController(text: widget.transaction!.description);
      _amountController = TextEditingController(text: widget.transaction!.amount.toString());
      _selectedAccountId = widget.transaction!.accountId ?? 0;
      _selectedCategoryId = widget.transaction!.categoryId ?? 0;
      _type = widget.transaction!.type;
      _frequency = widget.transaction!.frequency;
      _startDate = widget.transaction!.startDate;
      _endDate = widget.transaction!.endDate;
      _isActive = widget.transaction!.isActive;
    } else {
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      _selectedAccountId = 0;
      _selectedCategoryId = 0;
      _type = 'expense';
      _frequency = 'monthly';
      _startDate = DateTime.now();
      _endDate = null;
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveRecurringTransaction() async {
    if (_formKey.currentState!.validate()) {
      final recurringTransaction = RecurringTransaction(
        id: widget.transaction?.id,
        userId: 1, // TODO: Get actual user ID
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        type: _type,
        description: _descriptionController.text,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.transaction == null
          ? await ref.read(recurringTransactionProvider.notifier).createRecurringTransaction(recurringTransaction)
          : await ref.read(recurringTransactionProvider.notifier).updateRecurringTransaction(recurringTransaction);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaction == null
                ? 'Recurring transaction created successfully'
                : 'Recurring transaction updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save recurring transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountProvider).accounts;
    final categories = ref.watch(categoryProvider).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'New Recurring Transaction' : 'Edit Recurring Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecurringTransaction,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account selector
              DropdownButtonFormField<int>(
                value: _selectedAccountId == 0 && accounts.isNotEmpty ? accounts.first.id : _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                items: accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an account';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category selector
              DropdownButtonFormField<int>(
                value: _selectedCategoryId == 0 && categories.isNotEmpty ? categories.first.id : _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type selector
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Frequency selector
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Start date picker
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate.toString().split(' ').first),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),
              const Divider(),

              // End date picker
              SwitchListTile(
                title: const Text('Has End Date'),
                value: _endDate != null,
                onChanged: (value) {
                  setState(() {
                    _endDate = value ? DateTime.now() : null;
                  });
                },
              ),
              if (_endDate != null)
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(_endDate.toString().split(' ').first),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                ),
              const Divider(),

              // Active switch
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}