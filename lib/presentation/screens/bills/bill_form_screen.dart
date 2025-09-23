import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_provider.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final Bill? bill;

  const BillFormScreen({Key? key, this.bill}) : super(key: key);

  @override
  _BillFormScreenState createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _frequency;
  late int? _dayOfMonth;
  late DateTime? _dueDate;
  late DateTime _startDate;
  late DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      _nameController = TextEditingController(text: widget.bill!.name);
      _amountController = TextEditingController(text: widget.bill!.amount?.toString());
      _descriptionController = TextEditingController(text: widget.bill!.description);
      _frequency = widget.bill!.frequency;
      _dayOfMonth = widget.bill!.dayOfMonth;
      _dueDate = widget.bill!.dueDate;
      _startDate = widget.bill!.startDate;
      _endDate = widget.bill!.endDate;
      _isActive = widget.bill!.isActive;
    } else {
      _nameController = TextEditingController();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _frequency = 'monthly';
      _dayOfMonth = DateTime.now().day;
      _dueDate = null;
      _startDate = DateTime.now();
      _endDate = null;
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState!.validate()) {
      final bill = Bill(
        id: widget.bill?.id,
        userId: 1, // TODO: Get actual user ID
        name: _nameController.text,
        description: _descriptionController.text,
        amount: _amountController.text.isNotEmpty ? double.parse(_amountController.text) : null,
        dayOfMonth: _dayOfMonth,
        dueDate: _dueDate,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        createdAt: widget.bill?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = widget.bill == null
          ? await ref.read(billProvider.notifier).createBill(bill)
          : await ref.read(billProvider.notifier).updateBill(bill);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bill == null ? 'Bill created successfully' : 'Bill updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save bill')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill == null ? 'New Bill' : 'Edit Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
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
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bill Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bill name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
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
                  DropdownMenuItem(value: 'once', child: Text('One Time')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Day of month selector (for recurring bills)
              if (_frequency != 'once')
                DropdownButtonFormField<int?>(
                  value: _dayOfMonth,
                  decoration: const InputDecoration(
                    labelText: 'Due Day of Month',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(31, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text('Day $day'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _dayOfMonth = value;
                    });
                  },
                ),
              const SizedBox(height: 16),

              // Specific due date (for one-time bills)
              if (_frequency == 'once')
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(_dueDate?.toString().split(' ').first ?? 'Select date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                      });
                    }
                  },
                ),
              const Divider(),

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