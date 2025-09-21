import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingresos_costos_app/domain/entities/reminder.dart';
import 'package:ingresos_costos_app/presentation/providers/reminder_provider.dart';

class ReminderFormScreen extends ConsumerStatefulWidget {
  final int userId;
  final Reminder? reminder; // If provided, we're editing an existing reminder

  const ReminderFormScreen({
    Key? key,
    required this.userId,
    this.reminder,
  }) : super(key: key);

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TimeOfDay _selectedTime;
  
  // Frequency options
  final List<String> _frequencies = ['daily', 'weekly', 'monthly', 'yearly'];
  String _selectedFrequency = 'daily';
  
  // Days of week
  final List<String> _daysOfWeek = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  int? _selectedDayOfWeek;
  
  // Days of month
  final List<int> _daysOfMonth = List.generate(31, (index) => index + 1);
  int? _selectedDayOfMonth;
  
  // Months
  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // Set default time to current time
    final now = TimeOfDay.now();
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    
    // If editing an existing reminder, populate fields
    if (widget.reminder != null) {
      _nameController.text = widget.reminder!.name;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedFrequency = widget.reminder!.frequency;
      _selectedDayOfWeek = widget.reminder!.dayOfWeek;
      _selectedDayOfMonth = widget.reminder!.dayOfMonth;
      _selectedMonth = widget.reminder!.month;
      
      // Parse time
      final parts = widget.reminder!.time.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        id: widget.reminder?.id,
        userId: widget.userId,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        frequency: _selectedFrequency,
        dayOfWeek: _selectedFrequency == 'weekly' ? _selectedDayOfWeek : null,
        dayOfMonth: _selectedFrequency == 'monthly' || _selectedFrequency == 'yearly' ? _selectedDayOfMonth : null,
        month: _selectedFrequency == 'yearly' ? _selectedMonth : null,
        time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final isEditing = widget.reminder != null;
      
      if (isEditing) {
        ref.read(reminderProvider.notifier).updateReminder(reminder);
      } else {
        ref.read(reminderProvider.notifier).createReminder(reminder);
      }

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReminder,
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
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Frequency selector
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia',
                  border: OutlineInputBorder(),
                ),
                items: _frequencies.map((frequency) {
                  String label = '';
                  switch (frequency) {
                    case 'daily':
                      label = 'Diario';
                      break;
                    case 'weekly':
                      label = 'Semanal';
                      break;
                    case 'monthly':
                      label = 'Mensual';
                      break;
                    case 'yearly':
                      label = 'Anual';
                      break;
                  }
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFrequency = value;
                      
                      // Reset specific fields when frequency changes
                      if (value != 'weekly') {
                        _selectedDayOfWeek = null;
                      }
                      if (value != 'monthly' && value != 'yearly') {
                        _selectedDayOfMonth = null;
                      }
                      if (value != 'yearly') {
                        _selectedMonth = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Day of week selector (only for weekly)
              if (_selectedFrequency == 'weekly')
                DropdownButtonFormField<int>(
                  value: _selectedDayOfWeek,
                  decoration: const InputDecoration(
                    labelText: 'Día de la semana',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(7, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_daysOfWeek[index]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedDayOfWeek = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedFrequency == 'weekly' && value == null) {
                      return 'Por favor seleccione un día de la semana';
                    }
                    return null;
                  },
                ),
              if (_selectedFrequency == 'weekly') const SizedBox(height: 16),
              
              // Day of month selector (for monthly and yearly)
              if (_selectedFrequency == 'monthly' || _selectedFrequency == 'yearly')
                DropdownButtonFormField<int>(
                  value: _selectedDayOfMonth,
                  decoration: const InputDecoration(
                    labelText: 'Día del mes',
                    border: OutlineInputBorder(),
                  ),
                  items: _daysOfMonth.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDayOfMonth = value;
                    });
                  },
                  validator: (value) {
                    if ((_selectedFrequency == 'monthly' || _selectedFrequency == 'yearly') && value == null) {
                      return 'Por favor seleccione un día del mes';
                    }
                    return null;
                  },
                ),
              if (_selectedFrequency == 'monthly' || _selectedFrequency == 'yearly') const SizedBox(height: 16),
              
              // Month selector (only for yearly)
              if (_selectedFrequency == 'yearly')
                DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Mes',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(_months[index]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedFrequency == 'yearly' && value == null) {
                      return 'Por favor seleccione un mes';
                    }
                    return null;
                  },
                ),
              if (_selectedFrequency == 'yearly') const SizedBox(height: 16),
              
              // Time selector
              ListTile(
                title: const Text('Hora'),
                subtitle: Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}