import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/work_location.dart';
import '../../data/models/work_location.dart';
import '../../data/repositories/work_location_repository.dart';
import '../../domain/usecases/work_location/create_work_location_usecase.dart';
import '../../domain/usecases/work_location/get_work_locations_usecase.dart';
import '../../domain/usecases/work_location/update_work_location_usecase.dart';
import '../../domain/usecases/work_location/delete_work_location_usecase.dart';
import '../../domain/usecases/work_location/get_work_location_by_id_usecase.dart';
import '../../domain/usecases/work_location/get_frequent_work_locations_usecase.dart';

class WorkLocationState {
  final List<WorkLocation> workLocations;
  final List<WorkLocation> frequentWorkLocations;
  final bool isLoading;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;
  final String? nameError;
  final String? locationError;

  WorkLocationState({
    required this.workLocations,
    required this.frequentWorkLocations,
    required this.isLoading,
    required this.isSubmitting,
    this.submitError,
    required this.submitSuccess,
    this.nameError,
    this.locationError,
  });

  WorkLocationState copyWith({
    List<WorkLocation>? workLocations,
    List<WorkLocation>? frequentWorkLocations,
    bool? isLoading,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
    String? nameError,
    String? locationError,
  }) {
    return WorkLocationState(
      workLocations: workLocations ?? this.workLocations,
      frequentWorkLocations: frequentWorkLocations ?? this.frequentWorkLocations,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      nameError: nameError ?? this.nameError,
      locationError: locationError ?? this.locationError,
    );
  }

  static WorkLocationState initial() {
    return WorkLocationState(
      workLocations: [],
      frequentWorkLocations: [],
      isLoading: false,
      isSubmitting: false,
      submitSuccess: false,
    );
  }
}

class WorkLocationNotifier extends StateNotifier<WorkLocationState> {
  final WorkLocationRepository _workLocationRepository;

  WorkLocationNotifier({required WorkLocationRepository workLocationRepository})
      : _workLocationRepository = workLocationRepository,
        super(WorkLocationState.initial());

  Future<void> loadWorkLocations(int userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final getWorkLocationsUsecase = GetWorkLocationsUsecase(_workLocationRepository);
      final workLocations = await getWorkLocationsUsecase.execute(userId);
      state = state.copyWith(
        workLocations: workLocations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        submitError: 'Error al cargar los lugares de trabajo: $e',
        isLoading: false,
      );
    }
  }

  Future<void> loadFrequentWorkLocations(int userId, {int limit = 5}) async {
    state = state.copyWith(isLoading: true);
    try {
      final getFrequentWorkLocationsUsecase =
          GetFrequentWorkLocationsUsecase(_workLocationRepository);
      final frequentWorkLocations =
          await getFrequentWorkLocationsUsecase.execute(userId, limit: limit);
      state = state.copyWith(
        frequentWorkLocations: frequentWorkLocations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        submitError: 'Error al cargar los lugares frecuentes: $e',
        isLoading: false,
      );
    }
  }

  Future<WorkLocation?> getWorkLocationById(int id) async {
    try {
      final getWorkLocationByIdUsecase =
          GetWorkLocationByIdUsecase(_workLocationRepository);
      return await getWorkLocationByIdUsecase.execute(id);
    } catch (e) {
      state = state.copyWith(submitError: 'Error al obtener el lugar de trabajo: $e');
      return null;
    }
  }

  Future<bool> createWorkLocation(WorkLocation workLocation) async {
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final createWorkLocationUsecase =
          CreateWorkLocationUsecase(_workLocationRepository);
      await createWorkLocationUsecase.execute(workLocation);

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      );

      // Reload the list
      await loadWorkLocations(workLocation.userId);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Error al guardar el lugar de trabajo: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateWorkLocation(WorkLocation workLocation) async {
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final updatedWorkLocation = workLocation.copyWith(
        updatedAt: DateTime.now(),
      );

      final updateWorkLocationUsecase =
          UpdateWorkLocationUsecase(_workLocationRepository);
      await updateWorkLocationUsecase.execute(updatedWorkLocation);

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      );

      // Reload the list
      await loadWorkLocations(workLocation.userId);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Error al actualizar el lugar de trabajo: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteWorkLocation(int id, int userId) async {
    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final deleteWorkLocationUsecase =
          DeleteWorkLocationUsecase(_workLocationRepository);
      await deleteWorkLocationUsecase.execute(id);

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      );

      // Reload the list
      await loadWorkLocations(userId);

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: 'Error al eliminar el lugar de trabajo: ${e.toString()}',
      );
      return false;
    }
  }

  void setName(String name) {
    state = state.copyWith(
      nameError: name.isEmpty ? 'El nombre es requerido' : null,
    );
  }

  void setLocation(double? latitude, double? longitude) {
    // Location is optional, so no validation error is needed
    state = state.copyWith(locationError: null);
  }

  void setSelectedDate(DateTime date) {
    // No state update needed for date selection
  }

  bool validateForm(String name) {
    final nameError = name.isEmpty ? 'El nombre es requerido' : null;
    state = state.copyWith(nameError: nameError);
    return nameError == null;
  }

  void resetForm() {
    state = state.copyWith(
      nameError: null,
      locationError: null,
      submitError: null,
      submitSuccess: false,
    );
  }
}

final workLocationProvider =
    StateNotifierProvider<WorkLocationNotifier, WorkLocationState>((ref) {
  // This will be overridden when the provider is created with a repository
  throw UnimplementedError();
});