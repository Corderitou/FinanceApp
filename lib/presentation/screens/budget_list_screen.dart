import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../providers/budget_riverpod_provider.dart';
import 'budget_form_screen.dart';
import '../widgets/budget_progress_widget.dart';

class BudgetListScreen extends ConsumerStatefulWidget {
  final int userId;
  final List<Category> categories;

  const BudgetListScreen({
    Key? key,
    required this.userId,
    required this.categories,
  }) : super(key: key);

  @override
  _BudgetListScreenState createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends ConsumerState<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).loadBudgets(widget.userId);
    });
  }

  void _navigateToBudgetForm([Budget? budget]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetFormScreen(
          budget: budget,
          categories: widget.categories,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      // Refresh the budget list after returning from the form
      ref.read(budgetProvider.notifier).loadBudgets(widget.userId);
    });
  }

  void _deleteBudget(int budgetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro de que desea eliminar este presupuesto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                ref.read(budgetProvider.notifier).deleteBudget(budgetId, widget.userId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToBudgetForm(),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final budgetState = ref.watch(budgetProvider);
          
          if (budgetState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetState.budgetProgressList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay presupuestos',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToBudgetForm(),
                    child: const Text('Crear primer presupuesto'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgetState.budgetProgressList.length,
            itemBuilder: (context, index) {
              final budgetProgress = budgetState.budgetProgressList[index];
              return BudgetProgressWidget(budgetProgress: budgetProgress);
            },
          );
        },
      ),
    );
  }
}