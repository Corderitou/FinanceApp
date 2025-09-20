import 'package:flutter/material.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../data/models/budget.dart';
import '../providers/budget_provider.dart';
import 'package:provider/provider.dart';

class BudgetFormScreen extends StatefulWidget {
  final Budget? budget;
  final List<Category> categories;
  final int userId;

  const BudgetFormScreen({
    Key? key,
    this.budget,
    required this.categories,
    required this.userId,
  }) : super(key: key);

  @override
  _BudgetFormScreenState createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  Category? _selectedCategory;
  String _period = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amount = widget.budget!.amount;
      _selectedCategory = widget.categories
          .firstWhere((cat) => cat.id == widget.budget!.categoryId, orElse: () => widget.categories.first);
      _period = widget.budget!.period;
      _startDate = widget.budget!.startDate;
      _endDate = widget.budget!.endDate;
    } else {
      _amount = 0.0;
      _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : null;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Update end date based on period
        if (_period == 'monthly') {
          _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
        } else if (_period == 'weekly') {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor seleccione una categoría')),
        );
        return;
      }

      final now = DateTime.now();
      final budget = Budget(
        id: widget.budget?.id,
        userId: widget.userId,
        categoryId: _selectedCategory!.id!,
        amount: _amount,
        period: _period,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: widget.budget?.createdAt ?? now,
        updatedAt: now,
      );

      Provider.of<BudgetProvider>(context, listen: false).createBudget(budget);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Nuevo Presupuesto' : 'Editar Presupuesto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: widget.budget == null ? null : _amount.toString(),
                decoration: const InputDecoration(
                  labelText: 'Monto del Presupuesto',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un monto';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Por favor ingrese un monto válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                ),
                items: widget.categories
                    .where((cat) => cat.type == 'expense') // Only expense categories for budgets
                    .map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _period,
                decoration: const InputDecoration(
                  labelText: 'Período',
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensual')),
                  DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                  DropdownMenuItem(value: 'custom', child: Text('Personalizado')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _period = newValue!;
                    // Update end date based on period
                    if (_period == 'monthly') {
                      _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
                    } else if (_period == 'weekly') {
                      _endDate = _startDate.add(const Duration(days: 7));
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fecha de Inicio'),
                subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectStartDate(context),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fecha de Fin'),
                subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text(widget.budget == null ? 'Crear Presupuesto' : 'Actualizar Presupuesto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}