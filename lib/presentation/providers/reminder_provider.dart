import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reminder.dart';
import '../../data/models/reminder.dart';
import '../../data/repositories/reminder_repository.dart';

class ReminderState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  ReminderState({
    required this.reminders,
    required this.isLoading,
    this.error,
    required this.isSubmitting,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  static ReminderState initial() {
    return ReminderState(
      reminders: [],
      isLoading: false,
      isSubmitting: false,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderRepository _reminderRepository;

  ReminderNotifier({required ReminderRepository reminderRepository})
      : _reminderRepository = reminderRepository,
        super(ReminderState.initial());

  Future<void> loadReminders(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reminders = await _reminderRepository.getRemindersByUser(userId);
      state = state.copyWith(
        reminders: reminders,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los recordatorios: ${e.toString()}',
      );
    }
  }

  Future<bool> createReminder(Reminder reminder) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _reminderRepository.insertReminder(reminder);
      
      // Reload reminders
      await loadReminders(reminder.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al crear el recordatorio: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateReminder(Reminder reminder) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _reminderRepository.updateReminder(reminder);
      
      // Reload reminders
      await loadReminders(reminder.userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al actualizar el recordatorio: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteReminder(int reminderId, int userId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _reminderRepository.deleteReminder(reminderId);
      
      // Reload reminders
      await loadReminders(userId);
      
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Error al eliminar el recordatorio: ${e.toString()}',
      );
      return false;
    }
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  // This will be overridden when the provider is created with a repository
  throw UnimplementedError();
});