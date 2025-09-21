import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingresos_costos_app/domain/entities/savings_goal.dart';
import 'package:ingresos_costos_app/presentation/providers/savings_goal_provider.dart';
import 'savings_goal_form_screen.dart';
import 'package:ingresos_costos_app/presentation/utils/number_formatter.dart';

class SavingsGoalListScreen extends ConsumerStatefulWidget {
  final int userId;

  const SavingsGoalListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<SavingsGoalListScreen> createState() => _SavingsGoalListScreenState();
}

class _SavingsGoalListScreenState extends ConsumerState<SavingsGoalListScreen> {
  @override
  void initState() {
    super.initState();
    // Load savings goals when the screen is initialized
    ref.read(savingsGoalProvider.notifier).loadSavingsGoals(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final savingsGoalState = ref.watch(savingsGoalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Ahorro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SavingsGoalFormScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: savingsGoalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : savingsGoalState.error != null
              ? Center(child: Text('Error: ${savingsGoalState.error}'))
              : savingsGoalState.savingsGoals.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.savings,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay metas de ahorro',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Presiona el botón + para agregar una',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: savingsGoalState.savingsGoals.length,
                      itemBuilder: (context, index) {
                        final savingsGoal = savingsGoalState.savingsGoals[index];
                        return _SavingsGoalListItem(
                          savingsGoal: savingsGoal,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SavingsGoalFormScreen(
                                  userId: widget.userId,
                                  savingsGoal: savingsGoal,
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            _confirmDelete(context, savingsGoal);
                          },
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SavingsGoalFormScreen(userId: widget.userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavingsGoal savingsGoal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar meta de ahorro'),
          content: Text(
              '¿Estás seguro de que quieres eliminar la meta de ahorro "${savingsGoal.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(savingsGoalProvider.notifier)
                    .deleteSavingsGoal(savingsGoal.id!, widget.userId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

class _SavingsGoalListItem extends StatelessWidget {
  final SavingsGoal savingsGoal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavingsGoalListItem({
    required this.savingsGoal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    final progress = savingsGoal.targetAmount > 0 
        ? (savingsGoal.currentAmount / savingsGoal.targetAmount).clamp(0.0, 1.0) 
        : 0.0;
    
    // Format dates
    final formattedTargetDate = '${savingsGoal.targetDate.day}/${savingsGoal.targetDate.month}/${savingsGoal.targetDate.year}';
    
    // Calculate days remaining
    final daysRemaining = savingsGoal.targetDate.difference(DateTime.now()).inDays;
    final daysText = daysRemaining > 0 
        ? '$daysRemaining días restantes' 
        : daysRemaining < 0 
            ? 'Fecha vencida' 
            : 'Hoy es la fecha límite';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    savingsGoal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            if (savingsGoal.description != null && savingsGoal.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  savingsGoal.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% completado',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  daysText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormatter.formatCurrency(savingsGoal.currentAmount, currency: NumberFormatter.getCurrentCurrency()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'de ${NumberFormatter.formatCurrency(savingsGoal.targetAmount, currency: NumberFormatter.getCurrentCurrency())}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Fecha límite: $formattedTargetDate',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}