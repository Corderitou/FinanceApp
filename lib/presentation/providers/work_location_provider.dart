import 'package:flutter/material.dart';
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
import '../../data/database/database_helper.dart';

final workLocationProvider = ChangeNotifierProvider<WorkLocationProvider>((ref) {
  return WorkLocationProvider(
    workLocationRepository: WorkLocationRepositoryImpl(dbHelper: DatabaseHelper.instance),
  );
});

class WorkLocationProvider extends ChangeNotifier {
  final WorkLocationRepository _workLocationRepository;

  WorkLocationProvider({
    required WorkLocationRepository workLocationRepository,
  }) : _workLocationRepository = workLocationRepository;

  // Form fields
  String _name = '';
  double? _latitude;
  double? _longitude;
  DateTime _selectedDate = DateTime.now();

  // Form errors
  String? _nameError;
  String? _locationError;

  // Data lists
  List<WorkLocation> _workLocations = [];
  List<WorkLocation> _frequentWorkLocations = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _submitError;
  bool _submitSuccess = false;

  // Getters
  String get name => _name;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  DateTime get selectedDate => _selectedDate;

  String? get nameError => _nameError;
  String? get locationError => _locationError;

  List<WorkLocation> get workLocations => _workLocations;
  List<WorkLocation> get frequentWorkLocations => _frequentWorkLocations;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get submitSuccess => _submitSuccess;

  // Setters
  void setName(String name) {
    _name = name;
    _nameError = name.isEmpty ? 'El nombre es requerido' : null;
    notifyListeners();
  }

  void setLocation(double? latitude, double? longitude) {
    _latitude = latitude;
    _longitude = longitude;
    
    // Location is optional, so no validation error is needed
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Load data
  Future<void> loadWorkLocations(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final getWorkLocationsUsecase = GetWorkLocationsUsecase(_workLocationRepository);
      _workLocations = await getWorkLocationsUsecase.execute(userId);
    } catch (e) {
      _submitError = 'Error al cargar los lugares de trabajo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFrequentWorkLocations(int userId, {int limit = 5}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final getFrequentWorkLocationsUsecase = GetFrequentWorkLocationsUsecase(_workLocationRepository);
      _frequentWorkLocations = await getFrequentWorkLocationsUsecase.execute(userId, limit: limit);
    } catch (e) {
      _submitError = 'Error al cargar los lugares frecuentes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validation
  bool validateForm() {
    _nameError = _name.isEmpty ? 'El nombre es requerido' : null;
    // Location is optional, so no validation error is needed

    notifyListeners();

    return _nameError == null;
  }

  // Submit form
  Future<bool> submitForm(int userId) async {
    if (!validateForm()) {
      return false;
    }

    _isSubmitting = true;
    _submitError = null;
    _submitSuccess = false;
    notifyListeners();

    try {
      final workLocation = WorkLocation(
        userId: userId,
        name: _name,
        latitude: _latitude,
        longitude: _longitude,
        date: _selectedDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createWorkLocationUsecase = CreateWorkLocationUsecase(_workLocationRepository);
      await createWorkLocationUsecase.execute(workLocation);
      
      _submitSuccess = true;
      _resetForm();
      
      // Reload the list
      await loadWorkLocations(userId);
      
      return true;
    } catch (e) {
      _submitError = 'Error al guardar el lugar de trabajo: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<WorkLocation?> getWorkLocationById(int id) async {
    try {
      final getWorkLocationByIdUsecase = GetWorkLocationByIdUsecase(_workLocationRepository);
      return await getWorkLocationByIdUsecase.execute(id);
    } catch (e) {
      _submitError = 'Error al obtener el lugar de trabajo: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateWorkLocation(WorkLocation workLocation) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final updatedWorkLocation = workLocation.copyWith(
        updatedAt: DateTime.now(),
      );

      final updateWorkLocationUsecase = UpdateWorkLocationUsecase(_workLocationRepository);
      await updateWorkLocationUsecase.execute(updatedWorkLocation);
      
      _submitSuccess = true;
      
      // Reload the list
      await loadWorkLocations(workLocation.userId);
      
      return true;
    } catch (e) {
      _submitError = 'Error al actualizar el lugar de trabajo: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWorkLocation(int id, int userId) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final deleteWorkLocationUsecase = DeleteWorkLocationUsecase(_workLocationRepository);
      await deleteWorkLocationUsecase.execute(id);
      
      _submitSuccess = true;
      
      // Reload the list
      await loadWorkLocations(userId);
      
      return true;
    } catch (e) {
      _submitError = 'Error al eliminar el lugar de trabajo: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    _name = '';
    _latitude = null;
    _longitude = null;
    _selectedDate = DateTime.now();
    _nameError = null;
    _locationError = null;
    notifyListeners();
  }

  void resetForm() {
    _resetForm();
  }
}