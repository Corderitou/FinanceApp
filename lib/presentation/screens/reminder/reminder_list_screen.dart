import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finanzapp/domain/entities/reminder.dart';
import 'package:finanzapp/presentation/providers/reminder_provider.dart';
import 'package:finanzapp/services/notification_service.dart';
import 'reminder_form_screen.dart';

class ReminderListScreen extends ConsumerStatefulWidget {
  final int userId;

  const ReminderListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends ConsumerState<ReminderListScreen> {
  @override
  void initState() {
    super.initState();
    // Load reminders when the screen is initialized
    ref.read(reminderProvider.notifier).loadReminders(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final reminderState = ref.watch(reminderProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: _checkPermissions,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _showTestNotification,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReminderFormScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: reminderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminderState.error != null
              ? Center(child: Text('Error: ${reminderState.error}'))
              : reminderState.reminders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay recordatorios',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Presiona el botón + para agregar uno',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: reminderState.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminderState.reminders[index];
                        return _ReminderListItem(
                          reminder: reminder,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ReminderFormScreen(
                                  userId: widget.userId,
                                  reminder: reminder,
                                ),
                              ),
                            );
                          },
                          onDelete: () {
                            _confirmDelete(context, reminder);
                          },
                        );
                      },
                    ),
    );
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar recordatorio'),
          content: Text(
              '¿Estás seguro de que quieres eliminar el recordatorio "${reminder.name}"?'),
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
                    .read(reminderProvider.notifier)
                    .deleteReminder(reminder.id!, widget.userId);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showTestNotification() {
    final notificationService = NotificationService();
    notificationService.showImmediateNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación de prueba enviada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _checkPermissions() async {
    final notificationService = NotificationService();
    
    // Check notification permissions
    final notificationPermission = await notificationService.requestNotificationPermissions();
    
    // Request exact alarm permissions
    await notificationService.requestExactAlarmsPermission();
    
    String message = 'Permisos de notificación: ' + (notificationPermission ? 'Otorgados' : 'No otorgados') + '\n';
    message += 'Permisos de alarmas exactas: Solicitados';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderListItem({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Format frequency for display
    String frequencyText = '';
    switch (reminder.frequency) {
      case 'daily':
        frequencyText = 'Diario';
        break;
      case 'weekly':
        final daysOfWeek = [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo'
        ];
        frequencyText =
            'Semanal, ${reminder.dayOfWeek != null ? daysOfWeek[reminder.dayOfWeek! - 1] : ''}';
        break;
      case 'monthly':
        frequencyText =
            'Mensual, día ${reminder.dayOfMonth ?? ''}';
        break;
      case 'yearly':
        final months = [
          'Enero',
          'Febrero',
          'Marzo',
          'Abril',
          'Mayo',
          'Junio',
          'Julio',
          'Agosto',
          'Septiembre',
          'Octubre',
          'Noviembre',
          'Diciembre'
        ];
        frequencyText =
            'Anual, ${reminder.dayOfMonth != null ? 'día ${reminder.dayOfMonth}' : ''} de ${reminder.month != null ? months[reminder.month! - 1] : ''}';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(reminder.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description != null && reminder.description!.isNotEmpty)
              Text(reminder.description!),
            const SizedBox(height: 4),
            Text(
              '$frequencyText a las ${reminder.time}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}