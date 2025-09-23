import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_provider.dart';
import 'bill_form_screen.dart';

class BillsListScreen extends ConsumerStatefulWidget {
  const BillsListScreen({Key? key}) : super(key: key);

  @override
  _BillsListScreenState createState() => _BillsListScreenState();
}

class _BillsListScreenState extends ConsumerState<BillsListScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(billProvider.notifier).loadBills(1); // TODO: Use actual user ID
  }

  @override
  Widget build(BuildContext context) {
    final billsState = ref.watch(billProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BillFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: billsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : billsState.bills.isEmpty
              ? const Center(
                  child: Text('No bills yet'),
                )
              : ListView.builder(
                  itemCount: billsState.bills.length,
                  itemBuilder: (context, index) {
                    final bill = billsState.bills[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(bill.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bill.amount != null)
                              Text(
                                '\$${bill.amount!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${bill.frequency.capitalize()} bill',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (bill.dayOfMonth != null)
                              Text(
                                'Due on day ${bill.dayOfMonth}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Switch(
                          value: bill.isActive,
                          onChanged: (value) {
                            final updated = bill.copyWith(
                              isActive: value,
                              updatedAt: DateTime.now(),
                            );
                            ref.read(billProvider.notifier).updateBill(updated);
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BillFormScreen(bill: bill),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(context, bill);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Bill'),
          content: Text('Are you sure you want to delete "${bill.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(billProvider.notifier).deleteBill(
                      bill.id!,
                      bill.userId,
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