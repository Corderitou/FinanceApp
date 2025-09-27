import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanzapp/domain/entities/savings_goal.dart';
import 'package:finanzapp/presentation/providers/savings_goal_provider.dart';
import 'package:finanzapp/presentation/utils/number_formatter.dart';

class SavingsGoalFormScreen extends ConsumerStatefulWidget {
  final int userId;
  final SavingsGoal? savingsGoal; // If provided, we're editing an existing savings goal

  const SavingsGoalFormScreen({
    Key? key,
    required this.userId,
    this.savingsGoal,
  }) : super(key: key);

  @override
  ConsumerState<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends ConsumerState<SavingsGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late DateTime _selectedTargetDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _targetAmountController = TextEditingController();
    _currentAmountController = TextEditingController();
    
    // Set default target date to 30 days from now
    _selectedTargetDate = DateTime.now().add(const Duration(days: 30));
    
    // If editing an existing savings goal, populate fields
    if (widget.savingsGoal != null) {
      _nameController.text = widget.savingsGoal!.name;
      _descriptionController.text = widget.savingsGoal!.description ?? '';
      _targetAmountController.text = NumberFormatter.formatDecimal(widget.savingsGoal!.targetAmount);
      _currentAmountController.text = NumberFormatter.formatDecimal(widget.savingsGoal!.currentAmount);
      _selectedTargetDate = widget.savingsGoal!.targetDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years from now
    );
    
    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  void _saveSavingsGoal() {
    if (_formKey.currentState!.validate()) {
      // Parse amounts
      final targetAmount = double.tryParse(_targetAmountController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      final currentAmount = double.tryParse(_currentAmountController.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
      
      final savingsGoal = SavingsGoal(
        id: widget.savingsGoal?.id,
        userId: widget.userId,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _selectedTargetDate,
        isCompleted: targetAmount > 0 && currentAmount >= targetAmount,
        createdAt: widget.savingsGoal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final isEditing = widget.savingsGoal != null;
      
      if (isEditing) {
        ref.read(savingsGoalProvider.notifier).updateSavingsGoal(savingsGoal);
      } else {
        ref.read(savingsGoalProvider.notifier).createSavingsGoal(savingsGoal);
      }

      // Navigate back
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.savingsGoal != null;
    final savingsGoalState = ref.watch(savingsGoalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Meta de Ahorro' : 'Nueva Meta de Ahorro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: savingsGoalState.isSubmitting ? null : _saveSavingsGoal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre para la meta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Target amount field
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto objetivo';
                  }
                  final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingrese un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Current amount field
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto actual (opcional)',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              
              // Target date selector
              ListTile(
                title: const Text('Fecha límite'),
                subtitle: Text('${_selectedTargetDate.day}/${_selectedTargetDate.month}/${_selectedTargetDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectTargetDate(context),
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: savingsGoalState.isSubmitting ? null : _saveSavingsGoal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: savingsGoalState.isSubmitting
                      ? const CircularProgressIndicator()
                      : Text(
                          isEditing ? 'Actualizar Meta' : 'Crear Meta',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}